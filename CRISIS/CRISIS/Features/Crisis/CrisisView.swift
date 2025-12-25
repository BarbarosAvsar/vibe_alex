import Foundation
import SwiftUI

struct CrisisView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    private let summaryGenerator = CrisisSummaryGenerator()

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { snapshot in
                        AdaptiveStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 24) {
                                overviewSection(snapshot.crises)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 24) {
                                crisisFeedSection(snapshot.crises)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Krisen")
            .toolbar {
                ToolbarItem(placement: AdaptiveToolbarPlacement.leading) {
                    LogoMark()
                }
                ToolbarItem(placement: AdaptiveToolbarPlacement.trailing) {
                    ToolbarStatusControl {
                        showSettings = true
                    }
                }
            }
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
            .background(Theme.background)
        }
    }

    @ViewBuilder
    private func overviewSection(_ events: [CrisisEvent]) -> some View {
        DashboardSection("Krisenlage", subtitle: "Aktuelle Hinweise aus externen Quellen") {
            if let summary = summaryGenerator.summarize(events: events) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(summary.headline)
                        .font(.headline)
                    ForEach(summary.highlights, id: \.self) { highlight in
                        Text(highlight)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Theme.surface,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            } else {
                Text("Keine aktuellen Hinweise.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Theme.surface,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
        }
    }

    @ViewBuilder
    private func crisisFeedSection(_ events: [CrisisEvent]) -> some View {
        DashboardSection("Krisen-Feed", subtitle: "Meldungen aus NewsAPI und World Bank") {
            if events.isEmpty {
                Text("Keine aktuellen Krisenmeldungen.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(events) { event in
                        CrisisEventCard(event: event)
                    }
                }
            }
        }
    }
}

private struct CrisisEventCard: View {
    let event: CrisisEvent

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.severityBadge)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeTint.opacity(0.2), in: Capsule())
            }

            if let summary = event.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            HStack {
                Label(event.region, systemImage: "globe.europe.africa")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                Text(Self.formatter.string(from: event.occurredAt))
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }

            HStack(spacing: 8) {
                Text(categoryLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryTint.opacity(0.2), in: Capsule())
                Text(event.sourceName ?? event.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding()
        .background(
            Theme.surface.opacity(0.6),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.border.opacity(0.3), lineWidth: 1)
        )
    }

    private var categoryLabel: String {
        switch event.category {
        case .financial:
            return "Finanzen"
        case .geopolitical:
            return "Geopolitik"
        }
    }

    private var categoryTint: Color {
        switch event.category {
        case .financial:
            return Theme.accent
        case .geopolitical:
            return Theme.accentInfo
        }
    }

    private var badgeTint: Color {
        switch event.severityScore {
        case ..<4:
            return Theme.accentInfo
        case 4..<6:
            return Theme.accent
        default:
            return Theme.accentStrong
        }
    }
}
