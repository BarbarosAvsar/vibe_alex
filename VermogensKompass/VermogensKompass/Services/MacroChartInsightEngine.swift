import Foundation

struct MacroChartInsightEngine {
    func makeAnnotation(from series: [MacroSeries]) -> MacroChartAnnotation? {
        let candidates = series.compactMap { annotation(for: $0) }
        guard let top = candidates.sorted(by: { abs($0.delta) > abs($1.delta) }).first else {
            return nil
        }
        return top
    }

    private func annotation(for series: MacroSeries) -> MacroChartAnnotation? {
        guard let latest = series.points.last,
              let previous = series.points.dropLast().last else {
            return nil
        }
        let delta = latest.value - previous.value
        let direction = delta >= 0 ? "gestiegen" : "gefallen"
        let descriptor = "\(series.kind.title) ist \(direction) um \(delta.formatted(.number.precision(.fractionLength(1))))\(series.kind.unit) seit \(previous.year)."
        return MacroChartAnnotation(
            indicator: series.kind,
            focusYear: latest.year,
            delta: delta,
            message: descriptor
        )
    }
}

struct MacroChartAnnotation: Equatable {
    let indicator: MacroIndicatorKind
    let focusYear: Int
    let delta: Double
    let message: String

    var symbol: String {
        delta >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill"
    }
}
