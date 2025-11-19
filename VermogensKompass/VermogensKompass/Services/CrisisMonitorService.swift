import Foundation

protocol CrisisFeedService: Sendable {
    func fetchEvents() async throws -> [CrisisEvent]
}

struct CrisisMonitorService {
    private let feeds: [any CrisisFeedService]

    init(feeds: [any CrisisFeedService]? = nil, client: HTTPClienting = HTTPClient()) {
        if let feeds {
            self.feeds = feeds
        } else {
            self.feeds = [
                PoliticalFinancialNewsFeed(client: client, apiKey: AppConfig.newsAPIKey),
                GeopoliticalAlertCrisisFeed(client: client),
                FinancialStressCrisisFeed(client: client)
            ]
        }
    }

    func fetchEvents(limit: Int = 12) async throws -> [CrisisEvent] {
        var aggregated: [CrisisEvent] = []
        try await withThrowingTaskGroup(of: [CrisisEvent].self) { group in
            for feed in feeds {
                group.addTask {
                    try await feed.fetchEvents()
                }
            }

            for try await events in group {
                aggregated.append(contentsOf: events)
            }
        }

        let sorted = aggregated.sorted { $0.occurredAt > $1.occurredAt }
        return Array(sorted.prefix(limit))
    }
}

struct PoliticalFinancialNewsFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let apiKey: String?
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(client: HTTPClienting = HTTPClient(), apiKey: String?) {
        self.client = client
        self.apiKey = apiKey
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        guard let apiKey, apiKey.isEmpty == false else {
            return []
        }

        async let financialHeadlines = fetchTopHeadlines(category: "business", label: .financial, apiKey: apiKey)
        async let politicalHeadlines = fetchPoliticalNews(apiKey: apiKey)

        let (financial, political) = try await (financialHeadlines, politicalHeadlines)
        let merged = financial + political
        var unique: [CrisisEvent] = []
        var seenIDs = Set<String>()

        for event in merged {
            if seenIDs.insert(event.id).inserted {
                unique.append(event)
            }
        }

        // Preserve the order in which the different feeds were combined so that we keep
        // the expected "financial first, geopolitical second" layout that the UI (and tests)
        // rely on. The articles are already returned in descending order per feed.
        return Array(unique.prefix(10))
    }

    private func fetchTopHeadlines(category: String, label: CrisisCategory, apiKey: String) async throws -> [CrisisEvent] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/top-headlines"
        components.queryItems = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "pageSize", value: "6"),
            URLQueryItem(name: "category", value: category)
        ]
        guard let request = makeRequest(from: components, apiKey: apiKey) else { return [] }
        let data = try await client.send(request)
        let response = try decoder.decode(NewsAPIResponse.self, from: data)
        return mapArticles(response.articles, category: label)
    }

    private func fetchPoliticalNews(apiKey: String) async throws -> [CrisisEvent] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/everything"
        components.queryItems = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "pageSize", value: "6"),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "q", value: "geopolitics OR government OR election OR crisis OR war")
        ]
        guard let request = makeRequest(from: components, apiKey: apiKey) else { return [] }
        let data = try await client.send(request)
        let response = try decoder.decode(NewsAPIResponse.self, from: data)
        return mapArticles(response.articles, category: .geopolitical)
    }

    private func makeRequest(from components: URLComponents, apiKey: String) -> URLRequest? {
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        return request
    }

    private func mapArticles(_ articles: [NewsAPIArticle], category: CrisisCategory) -> [CrisisEvent] {
        articles.compactMap { article in
            guard let title = article.title else { return nil }
            let publishedAt = article.publishedAt ?? Date()
            let identifier = "\(category.rawValue)-\(title.hashValue)"
            return CrisisEvent(
                id: "news-\(identifier)",
                title: title,
                summary: article.description ?? article.content,
                region: article.source.name ?? "Weltweit",
                occurredAt: publishedAt,
                publishedAt: article.publishedAt,
                detailURL: nil,
                sourceName: article.source.name,
                source: .newsAPI,
                category: category,
                severityScore: severityScore(for: article.publishedAt)
            )
        }
    }

    private func severityScore(for date: Date?) -> Double {
        guard let date else { return 4 }
        let hours = Date().timeIntervalSince(date) / 3600
        switch hours {
        case ..<24: return 6
        case ..<72: return 5
        default: return 4
        }
    }
}

struct GeopoliticalAlertCrisisFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let decoder = JSONDecoder()
    private let watchList: [(name: String, code: String)]

    init(
        client: HTTPClienting = HTTPClient(),
        watchList: [(String, String)] = [("Ukraine", "UKR"), ("Israel", "ISR"), ("Taiwan", "TWN"), ("South Africa", "ZAF"), ("Germany", "DEU")]
    ) {
        self.client = client
        self.watchList = watchList
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        try await withThrowingTaskGroup(of: CrisisEvent?.self) { group in
            for entry in watchList {
                group.addTask {
                    try await self.fetchGovernanceAlert(for: entry)
                }
            }

            var events: [CrisisEvent] = []
            for try await result in group {
                if let event = result {
                    events.append(event)
                }
            }
            return events
        }
    }

    private func fetchGovernanceAlert(for entry: (name: String, code: String)) async throws -> CrisisEvent? {
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(entry.code)/indicator/PV.PSR.PIND?format=json&per_page=2") else {
            return nil
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(WorldBankValueResponse.self, from: data),
              let latest = response.entries.first(where: { $0.value != nil }),
              let value = latest.value,
              value < CrisisThresholds.politicalInstabilityCutoff else {
            return nil
        }

        let yearDate = makeYearDate(from: latest.date)

        return CrisisEvent(
            id: "geo-\(entry.code)",
            title: "Politische Instabilität \(entry.name)",
            summary: "Governance-Index \(value.formatted(.number.precision(.fractionLength(2))))",
            region: entry.name,
            occurredAt: yearDate,
            publishedAt: yearDate,
            detailURL: URL(string: "https://data.worldbank.org/indicator/PV.PSR.PIND"),
            sourceName: "World Bank",
            source: .worldBankGovernance,
            category: .geopolitical,
            severityScore: abs(value) * 2
        )
    }
}

struct FinancialStressCrisisFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let decoder = JSONDecoder()
    private let watchList: [(name: String, code: String)]

    init(
        client: HTTPClienting = HTTPClient(),
        watchList: [(String, String)] = [("Germany", "DEU"), ("United States", "USA"), ("United Kingdom", "GBR"), ("Japan", "JPN"), ("China", "CHN")]
    ) {
        self.client = client
        self.watchList = watchList
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        try await withThrowingTaskGroup(of: CrisisEvent?.self) { group in
            for entry in watchList {
                group.addTask {
                    try await self.fetchAlert(for: entry)
                }
            }

            var events: [CrisisEvent] = []
            for try await result in group {
                if let event = result {
                    events.append(event)
                }
            }
            return events
        }
    }

    private func fetchAlert(for entry: (name: String, code: String)) async throws -> CrisisEvent? {
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(entry.code)/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2") else {
            return nil
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(WorldBankValueResponse.self, from: data),
              let latest = response.entries.first(where: { $0.value != nil }),
              let value = latest.value,
              value < CrisisThresholds.recessionGrowthCutoff else {
            return nil
        }

        let yearDate = makeYearDate(from: latest.date)

        return CrisisEvent(
            id: "finance-\(entry.code)",
            title: "Rezession \(entry.name)",
            summary: "Reales BIP-Wachstum \(value.formatted(.number.precision(.fractionLength(1))))%",
            region: entry.name,
            occurredAt: yearDate,
            publishedAt: yearDate,
            detailURL: URL(string: "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG"),
            sourceName: "World Bank",
            source: .worldbankFinance,
            category: .financial,
            severityScore: abs(value)
        )
    }
}

private struct NewsAPIResponse: Decodable {
    let articles: [NewsAPIArticle]
}

private struct NewsAPIArticle: Decodable {
    struct Source: Decodable {
        let name: String?
    }

    let title: String?
    let description: String?
    let content: String?
    let source: Source
    let publishedAt: Date?
    let url: URL?
}

private struct WorldBankValueResponse: Decodable {
    struct Entry: Decodable {
        let date: String
        let value: Double?
    }

    let entries: [Entry]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try? container.decode(DecodableIgnored.self)
        entries = try container.decode([Entry].self)
    }
}

private struct DecodableIgnored: Decodable { }

private extension String {
    var severityScore: Int {
        switch lowercased() {
        case "extreme": return 6
        case "severe": return 5
        case "moderate": return 4
        case "minor": return 3
        default: return 2
        }
    }
}

private func makeYearDate(from year: String) -> Date {
    Calendar.current.date(from: DateComponents(year: Int(year) ?? 2024)) ?? Date()
}
