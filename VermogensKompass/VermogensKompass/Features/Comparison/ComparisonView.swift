import SwiftUI
import Charts
#if canImport(Accessibility)
import Accessibility
#endif

struct ComparisonView: View {
    @Environment(AppState.self) private var appState
    private let insightEngine = MacroChartInsightEngine()

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        DashboardSection("Makro-Vergleich", subtitle: "World Bank Zeitreihen") {
                            let annotation = insightEngine.makeAnnotation(from: snapshot.macroSeries)
                            Chart {
                                ForEach(snapshot.macroSeries) { series in
                                    ForEach(series.points) { point in
                                        LineMark(
                                            x: .value("Jahr", point.year),
                                            y: .value(series.kind.title, point.value)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(by: .value("Indikator", series.kind.title))
                                    }
                                }
                                if let annotation {
                                    RuleMark(x: .value("Jahr", annotation.focusYear))
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        .foregroundStyle(Theme.accent)
                                        .annotation(position: .topLeading) {
                                            MacroChartAnnotationView(annotation: annotation)
                                        }
                                }
                            }
                            .frame(height: 220)
                            .chartXAxisLabel("Jahr")
                            .chartYAxisLabel("%")
                            .chartLegend(.visible)
#if canImport(Accessibility)
                            .accessibilityChartDescriptor(MacroChartDescriptor(series: snapshot.macroSeries))
#endif
                            .cardStyle()

                            if let annotation {
                                MacroChartInsightCard(annotation: annotation)
                            }
                        }

                        DashboardSection("Interpretation", subtitle: "Automatisierte Auswertung") {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(snapshot.macroOverview.indicators) { indicator in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: icon(for: indicator.id))
                                            .foregroundStyle(Theme.accent)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(indicator.title)
                                                .font(.headline)
                                            Text(indicator.deltaDescription)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            Text(indicator.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .cardStyle()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Vergleich")
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
        }
    }

    private func icon(for kind: MacroIndicatorKind) -> String {
        switch kind {
        case .inflation: return "flame.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .defense: return "shield.fill"
        }
    }
}

private struct MacroChartAnnotationView: View {
    let annotation: MacroChartAnnotation

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: annotation.symbol)
                .foregroundStyle(annotation.delta >= 0 ? .green : .red)
            Text(annotation.message)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(3)
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.9), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 4, x: 0, y: 2)
    }
}

private struct MacroChartInsightCard: View {
    let annotation: MacroChartAnnotation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Apple Intelligence Vorschau")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: annotation.symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(annotation.delta >= 0 ? .green : .red)
                VStack(alignment: .leading, spacing: 4) {
                    Text(annotation.indicator.title)
                        .font(.headline)
                    Text(annotation.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
    }
}

#if canImport(Accessibility)
@available(iOS 16.0, *)
struct MacroChartDescriptor: AXChartDescriptorRepresentable {
    let series: [MacroSeries]

    func makeChartDescriptor() -> AXChartDescriptor {
        let years = series.flatMap { $0.points.map(\.year) }
        let values = series.flatMap { $0.points.map(\.value) }
        let xRange = Double(years.min() ?? 0)...Double(years.max() ?? 0)
        let yRange = (values.min() ?? 0)...(values.max() ?? 0)

        let xAxis = AXNumericDataAxisDescriptor(title: "Jahr", range: xRange) { value in
            String(Int(value))
        }
        let yAxis = AXNumericDataAxisDescriptor(title: "Prozent", range: yRange) { value in
            value.formatted(.number.precision(.fractionLength(1))) + "%"
        }

        let dataSeries = series.map { macroSeries -> AXDataSeriesDescriptor in
            let dataPoints = macroSeries.points.map { point in
                AXDataPoint(
                    x: Double(point.year),
                    y: point.value,
                    label: "\(point.year)",
                    valueDescription: point.value.formatted(.number.precision(.fractionLength(1))) + macroSeries.kind.unit
                )
            }
            return AXDataSeriesDescriptor(name: macroSeries.kind.title, isContinuous: true, dataPoints: dataPoints)
        }

        return AXChartDescriptor(
            title: "Makro-Vergleich",
            summary: AXChartSummary("Verlauf von Inflation, Wachstum und Verteidigungsausgaben."),
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: dataSeries
        )
    }
}
#endif
