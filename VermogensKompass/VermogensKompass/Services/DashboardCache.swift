import Foundation

struct DashboardCache {
    private let url: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileName: String = "dashboard-cache.json") {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        url = directory.appendingPathComponent(fileName)
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func persist(_ snapshot: DashboardSnapshot) {
        do {
            let data = try encoder.encode(snapshot)
            try data.write(to: url, options: .atomic)
        } catch {
            #if DEBUG
            print("Failed to persist snapshot", error)
            #endif
        }
    }

    func load() -> DashboardSnapshot? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(DashboardSnapshot.self, from: data)
        } catch {
            #if DEBUG
            print("Failed to load cached snapshot", error)
            #endif
            return nil
        }
    }
}
