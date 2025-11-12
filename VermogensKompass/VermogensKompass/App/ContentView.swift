import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var showMailSheet = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            TabView {
                OverviewView(showMailSheet: $showMailSheet)
                    .tabItem { Label("Übersicht", systemImage: "house.fill") }

                ComparisonView()
                    .tabItem { Label("Vergleich", systemImage: "chart.bar.doc.horizontal") }

                MetalsView(showMailSheet: $showMailSheet)
                    .tabItem { Label("Edelmetalle", systemImage: "rhombus.fill") }

                CrisisView()
                    .tabItem { Label("Krisen", systemImage: "exclamationmark.triangle.fill") }

                ConsultationView(showMailSheet: $showMailSheet)
                    .tabItem { Label("Beratung", systemImage: "person.text.rectangle") }
            }
            .sheet(isPresented: $showMailSheet) {
                EmailComposerView(configuration: AppConfig.contactEmail)
            }
        }
        .task {
            guard appState.hasLoadedOnce == false else { return }
            await appState.refreshDashboard(force: true)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                BackgroundRefreshManager.shared.schedule()
            }
        }
    }
}

#Preview("Root view") {
    ContentView()
        .environment(AppState(repository: DashboardRepository(mockData: MockData.snapshot)))
}
