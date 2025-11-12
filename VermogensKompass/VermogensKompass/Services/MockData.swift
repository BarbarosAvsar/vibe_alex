import Foundation

enum MockData {
    static let snapshot: DashboardSnapshot = {
        let metals = [
            MetalAsset(
                id: "XAU",
                name: "Gold",
                symbol: "XAU",
                price: 4131.0,
                dailyChangePercentage: 0.52,
                currency: "USD",
                lastUpdated: Date(),
                insights: [
                    MetalInsight(icon: "arrow.triangle.2.circlepath", label: "24h", value: "0.52%"),
                    MetalInsight(icon: "chart.line.uptrend.xyaxis", label: "YTD", value: "+12.3%")
                ],
                dataSource: .goldPrice
            ),
            MetalAsset(
                id: "XAG",
                name: "Silber",
                symbol: "XAG",
                price: 51.6,
                dailyChangePercentage: 1.45,
                currency: "USD",
                lastUpdated: Date(),
                insights: [
                    MetalInsight(icon: "arrow.triangle.2.circlepath", label: "24h", value: "1.45%"),
                    MetalInsight(icon: "chart.line.uptrend.xyaxis", label: "YTD", value: "+8.9%")
                ],
                dataSource: .goldPrice
            )
        ]

        let indicators = MacroIndicatorKind.allCases.map {
            MacroIndicator(
                id: $0,
                title: $0.title,
                latestValue: Double.random(in: -1...8),
                previousValue: Double.random(in: -1...8),
                unit: $0.unit,
                description: $0.explanation,
                source: .worldBank
            )
        }

        let macroOverview = MacroOverview(indicators: indicators)
        let macroSeries = indicators.map { indicator in
            MacroSeries(
                kind: indicator.id,
                points: (0..<6).map { offset in
                    MacroDataPoint(year: 2019 + offset, value: Double.random(in: -1...8))
                }
            )
        }

        let crises = (0..<4).map { index in
            CrisisEvent(
                id: "mock-\(index)",
                title: "Ereignis #\(index + 1)",
                magnitude: Double.random(in: 3...6),
                region: "Europa",
                occurredAt: Date().addingTimeInterval(Double(-index) * 8_000),
                detailURL: nil,
                source: .usgs,
                category: .seismic
            )
        }

        return DashboardSnapshot(
            metals: metals,
            macroOverview: macroOverview,
            macroSeries: macroSeries,
            crises: crises
        )
    }()
}
