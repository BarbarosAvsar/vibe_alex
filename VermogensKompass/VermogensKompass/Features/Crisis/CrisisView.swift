import SwiftUI

struct CrisisView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 16) {
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
                    .background(Color.white.opacity(0.08), in: Capsule())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let magnitude = event.magnitude {
                Text("Magnitude \(magnitude.formatted(.number.precision(.fractionLength(1))))")
                    .font(.caption)
            }
            Text(event.occurredAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let link = event.detailURL {
                Link("Details", destination: link)
                    .font(.caption.bold())
                    .foregroundStyle(Theme.accent)
            }
            Text("Quelle: \(event.source.rawValue)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var badgeColor: Color {
        switch event.severityBadge {
        case "Hoch": return .red.opacity(0.7)
        case "Moderat": return .orange.opacity(0.7)
        default: return .green.opacity(0.7)
        }
    }
}
