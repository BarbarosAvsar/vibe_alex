import SwiftUI

struct BennerCycleView: View {
    let entries: [BennerCycleEntry]
    @Environment(LanguageSettings.self) private var languageSettings

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
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        let language = languageSettings.selectedLanguage
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Localization.format("benner_entry_summary", language: language, entry.year, entry.phase.localizedSubtitle(language: language)))
                        .font(.headline)
                    Text(entry.phase.localizedGuidance(language: language))
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(entry.year)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(entry.phase.tint)
                    Text(statusLabel(language: language))
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
        entry.phase.localizedGuidance(language: languageSettings.selectedLanguage)
    }

    private func statusLabel(language: AppLanguage) -> String {
        if entry.phase == .panic {
            return entry.phase.localizedTitle(language: language)
        }
        return entry.year >= currentYear
            ? Localization.text("comparison_mode_forecast", language: language)
            : Localization.text("comparison_mode_history", language: language)
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
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        let language = languageSettings.selectedLanguage
        VStack(alignment: .leading, spacing: 8) {
            Text("\(entry.year)")
                .font(.headline)
            Text(entry.phase.localizedTitle(language: language))
                .font(.subheadline.weight(.semibold))
            Text(entry.phase.localizedSubtitle(language: language))
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
            Spacer(minLength: 0)
            Text(progressText(language: language))
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

    private func progressText(language: AppLanguage) -> String {
        entry.phase.localizedSubtitle(language: language)
    }
}

extension BennerCycleEntry {
    var progress: Double {
        guard phaseLength > 0 else { return 1 }
        return Double(orderInPhase) / Double(phaseLength)
    }
}

extension BennerPhase {
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
