import SwiftUI

struct CrisisView: View {
    @Environment(AppState.self) private var appState
    private let summaryGenerator = CrisisSummaryGenerator()

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 16) {
                        if let summary = summaryGenerator.summarize(events: snapshot.crises) {
                            DashboardSection("Kurzüberblick", subtitle: "On-Device Zusammenfassung") {
                                CrisisSummaryCard(summary: summary)
                            }
                        }
                        ForEach(snapshot.crises) { event in
                            CrisisCard(event: event)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Krisen")
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
        }
    }
}

struct CrisisCard: View {
    let event: CrisisEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.severityBadge)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor, in: Capsule())
            }
            HStack {
                Text(event.region)
                    .font(.subheadline)
                Spacer()
                Text(event.category.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.border.opacity(0.25), in: Capsule())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let summary = event.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            Text(event.occurredAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Quelle: \(event.sourceName ?? event.source.rawValue)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var badgeColor: Color {
        switch event.severityBadge {
        case "Hoch": return Theme.accentStrong.opacity(0.85)
        case "Moderat": return Theme.accent.opacity(0.85)
        default: return Theme.border.opacity(0.7)
        }
    }
}

struct CrisisSummaryCard: View {
    let summary: CrisisSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary.headline)
                .font(.headline)
            ForEach(summary.highlights, id: \.self) { highlight in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.accent)
                    Text(highlight)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
    }
}
