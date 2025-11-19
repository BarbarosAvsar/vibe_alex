import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @State private var showPrivacyPolicy = false
    @State private var showNotificationOnboarding = false
    @AppStorage("notificationOnboardingCompleted") private var notificationOnboardingCompleted = false
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
                if appState.notificationStatus.requiresOnboarding {
                    NotificationPermissionBanner(status: appState.notificationStatus) {
                        if (appState.notificationStatus == .denied || appState.notificationStatus == .provisional),
                           let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        } else {
                            showNotificationOnboarding = true
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                TabView {
                    OverviewView()
                        .tabItem { Label("Übersicht", systemImage: "house.fill") }

                    ComparisonView()
                        .tabItem { Label("Vergleich", systemImage: "chart.bar.doc.horizontal") }

                    MetalsView()
                        .tabItem { Label("Edelmetalle", systemImage: "rhombus.fill") }

                    CrisisView()
                        .tabItem { Label("Krisen", systemImage: "exclamationmark.triangle.fill") }

                    ConsultationView(showPrivacyPolicy: $showPrivacyPolicy)
                        .tabItem { Label("Beratung", systemImage: "person.text.rectangle") }
                }
                .tint(Theme.accent)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .animation(.easeInOut(duration: 0.25), value: appState.syncNotice)
        }
        .task {
            await currencySettings.refreshRates()
            await appState.refreshNotificationAuthorizationStatus()
            guard appState.hasLoadedOnce == false else { return }
            await appState.refreshDashboard(force: true)
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                BackgroundRefreshManager.shared.schedule()
            case .active:
                Task { await appState.refreshNotificationAuthorizationStatus() }
            default:
                break
            }
        }
        .sheet(isPresented: $showNotificationOnboarding) {
            NotificationOnboardingView(status: appState.notificationStatus) {
                await appState.requestNotificationAccess()
            } skipAction: {
                notificationOnboardingCompleted = true
                showNotificationOnboarding = false
            } completion: { granted in
                if granted {
                    notificationOnboardingCompleted = true
                    showNotificationOnboarding = false
                }
            }
        }
        .onAppear {
            if notificationOnboardingCompleted == false {
                showNotificationOnboarding = true
            }
        }
    }
}

#Preview("Root view") {
    ContentView()
        .environment(AppState(repository: DashboardRepository(mockData: MockData.snapshot)))
}
