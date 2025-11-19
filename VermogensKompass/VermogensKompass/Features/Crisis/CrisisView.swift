import SwiftUI

struct CrisisView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    private let summaryGenerator = CrisisSummaryGenerator()
    @State private var didScrollToCurrent = false

    private var timelineEntries: [BennerCycleEntry] {
        appState.bennerCycleEntries.sorted { $0.year > $1.year }
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var currentEntryID: Int? {
        timelineEntries.first(where: { $0.year >= currentYear })?.id
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        timelineSection

                        AsyncStateView(state: appState.dashboardState) {
                            Task { await appState.refreshDashboard(force: true) }
                        } content: { snapshot in
                            crisisOverviewSection(snapshot: snapshot)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollToCurrentIfNeeded(proxy: proxy)
                }
            }
            .navigationTitle("Krisen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarStatusControl(lastUpdated: appState.lastUpdated) {
                        showSettings = true
                    }
                }
            }
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
        }
    }

    private func scrollToCurrentIfNeeded(proxy: ScrollViewProxy) {
        guard didScrollToCurrent == false, let id = currentEntryID else { return }
        didScrollToCurrent = true
        DispatchQueue.main.async {
            proxy.scrollTo(id, anchor: .top)
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benner-Krisenpfad")
                .font(.title2.weight(.semibold))
            Text("Alle Ereignisse seit Beginn des Benner-Zyklus – nach oben scrollen für Prognosen bis 2150, nach unten für historische Krisen.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            LazyVStack(spacing: 12, pinnedViews: []) {
                ForEach(timelineEntries) { entry in
                    BennerTimelineRow(entry: entry, isCurrent: entry.year == currentYear)
                        .id(entry.id)
                }
            }
        }
    }

    @ViewBuilder
    private func crisisOverviewSection(snapshot: DashboardSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let summary = summaryGenerator.summarize(events: snapshot.crises) {
                DashboardSection("Kurzüberblick", subtitle: "On-Device Zusammenfassung") {
                    CrisisSummaryCard(summary: summary)
                }
            }
            if snapshot.crises.isEmpty == false {
                DashboardSection("Aktuelle Meldungen", subtitle: "Live-Ereignisse des Krisenmonitors") {
                    VStack(spacing: 16) {
                        ForEach(snapshot.crises) { event in
                            CrisisCard(event: event)
                        }
                    }
                }
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

private struct BennerTimelineRow: View {
    let entry: BennerCycleEntry
    let isCurrent: Bool

    private var isFuture: Bool {
        entry.year > Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                Text("\(entry.year)")
                    .font(.headline)
                Circle()
                    .fill(entry.phase.tint)
                    .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)
            }
            Rectangle()
                .fill(Theme.border.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.phase.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(isFuture ? "Prognose" : "Historie")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(entry.phase.guidance)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            entry.phase.tint.opacity(isCurrent ? 0.2 : 0.08),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(entry.phase.tint.opacity(isCurrent ? 0.9 : 0.3), lineWidth: isCurrent ? 2 : 1)
        )
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
