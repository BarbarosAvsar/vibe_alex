import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var showMailSheet = false
    @State private var showPrivacyPolicy = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(spacing: 0) {
                if let notice = appState.syncNotice {
                    SyncStatusBanner(notice: notice)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
                TabView {
                    OverviewView(showMailSheet: $showMailSheet)
                        .tabItem { Label("Übersicht", systemImage: "house.fill") }

                    ComparisonView()
                        .tabItem { Label("Vergleich", systemImage: "chart.bar.doc.horizontal") }

                    MetalsView(showMailSheet: $showMailSheet)
                        .tabItem { Label("Edelmetalle", systemImage: "rhombus.fill") }

                    CrisisView()
                        .tabItem { Label("Krisen", systemImage: "exclamationmark.triangle.fill") }

                    ConsultationView(showMailSheet: $showMailSheet, showPrivacyPolicy: $showPrivacyPolicy)
                        .tabItem { Label("Beratung", systemImage: "person.text.rectangle") }
                }
            }
            .sheet(isPresented: $showMailSheet) {
                EmailComposerView(configuration: AppConfig.contactEmail)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .animation(.easeInOut(duration: 0.25), value: appState.syncNotice)
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
