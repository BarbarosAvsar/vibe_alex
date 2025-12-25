import Foundation

struct DashboardRepository {
    private let metalService: MetalPriceService
    private let macroService: MacroIndicatorService
    private let crisisService: CrisisMonitorService
    private let staticSnapshot: DashboardSnapshot?

    init(
        metalService: MetalPriceService = MetalPriceService(),
        macroService: MacroIndicatorService = MacroIndicatorService(),
        crisisService: CrisisMonitorService = CrisisMonitorService(),
        mockData: DashboardSnapshot? = nil
    ) {
        self.metalService = metalService
        self.macroService = macroService
        self.crisisService = crisisService
        self.staticSnapshot = mockData
    }

    func makeSnapshot() async throws -> DashboardSnapshot {
        if let staticSnapshot {
            return staticSnapshot
        }

        async let metalsTask = metalService.fetchAssets()
        async let inflationTask = macroService.fetchIndicator(.inflation)
        async let growthTask = macroService.fetchIndicator(.growth)
        async let defenseTask = macroService.fetchIndicator(.defense)
        async let crisisTask = crisisService.fetchEvents()

        let metals = try await metalsTask
        let (inflation, inflationSeries) = try await inflationTask
        let (growth, growthSeries) = try await growthTask
        let (defense, defenseSeries) = try await defenseTask
        let crises = try await crisisTask

        let macroOverview = MacroOverview(indicators: [inflation, growth, defense])
        let macroSeries = [inflationSeries, growthSeries, defenseSeries]

        return DashboardSnapshot(
            metals: metals,
            macroOverview: macroOverview,
            macroSeries: macroSeries,
            crises: crises
        )
    }
}
