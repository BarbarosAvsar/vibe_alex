import SwiftUI

struct BennerCycleView: View {
    let entries: [BennerCycleEntry]

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        VStack(spacing: 16) {
            if let focusEntry = focusEntry {
                BennerCycleFocusCard(entry: focusEntry, currentYear: currentYear)
            }

            BennerCycleTimeline(entries: timelineEntries, currentYear: currentYear)
        }
    }

    private var focusEntry: BennerCycleEntry? {
        if let exact = entries.first(where: { $0.year == currentYear }) {
            return exact
        }
        return entries.first(where: { $0.year > currentYear })
    }

    private var timelineEntries: [BennerCycleEntry] {
        let window = (currentYear - 4)...(currentYear + 16)
        let filtered = entries.filter { window.contains($0.year) }
        return filtered.isEmpty ? Array(entries.prefix(12)) : filtered
    }
}

private struct BennerCycleFocusCard: View {
    let entry: BennerCycleEntry
    let currentYear: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.summary)
                        .font(.headline)
                    Text(entry.phase.guidance)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(entry.year)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(entry.phase.tint)
                    Text(entry.phase == .panic ? "Panik" : (entry.year >= currentYear ? "Ausblick" : "Historie"))
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                }
            }

            ProgressView(value: entry.progress)
                .tint(entry.phase.tint)
                .padding(.vertical, 4)

            Text(progressLabel)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
    }

    private var progressLabel: String {
        switch entry.phase {
        case .panic:
            return "Panikjahre markieren Wendepunkte im ca. 54-jährigen Benner-Zyklus."
        case .goodTimes:
            return "Good Times Jahr \(entry.orderInPhase) von \(entry.phaseLength) nach dem letzten Panikjahr."
        case .hardTimes:
            return "Hard Times Jahr \(entry.orderInPhase) von \(entry.phaseLength) – traditionell Kaufgelegenheiten."
        }
    }
}

private struct BennerCycleTimeline: View {
    let entries: [BennerCycleEntry]
    let currentYear: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(entries) { entry in
                    BennerCyclePill(entry: entry, isCurrent: entry.year == currentYear)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct BennerCyclePill: View {
    let entry: BennerCycleEntry
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(entry.year)")
                .font(.headline)
            Text(entry.phase.title)
                .font(.subheadline.weight(.semibold))
            Text(entry.phase.subtitle)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
            Spacer(minLength: 0)
            Text(progressText)
                .font(.caption2)
                .foregroundStyle(Theme.textMuted)
        }
        .padding()
        .frame(width: 180, alignment: .leading)
        .background(
            entry.phase.tint.opacity(isCurrent ? 0.18 : 0.12),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(entry.phase.tint.opacity(isCurrent ? 0.8 : 0.35), lineWidth: isCurrent ? 1.5 : 1)
        )
    }

    private var progressText: String {
        switch entry.phase {
        case .panic:
            return "Phase A"
        case .goodTimes:
            return "Phase B • \(entry.orderInPhase)/\(entry.phaseLength)"
        case .hardTimes:
            return "Phase C • \(entry.orderInPhase)/\(entry.phaseLength)"
        }
    }
}

private extension BennerCycleEntry {
    var progress: Double {
        guard phaseLength > 0 else { return 1 }
        return Double(orderInPhase) / Double(phaseLength)
    }
}

private extension BennerPhase {
    var tint: Color {
        switch self {
        case .panic:
            return Theme.accentStrong
        case .goodTimes:
            return Theme.accent
        case .hardTimes:
            return Theme.border
        }
    }
}
