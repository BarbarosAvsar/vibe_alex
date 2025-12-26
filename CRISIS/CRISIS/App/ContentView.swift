import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(LanguageSettings.self) private var languageSettings
    @State private var selectedTab: Tab = .overview
    @State private var showSettings = false
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
                let language = languageSettings.selectedLanguage
                TabView(selection: $selectedTab) {
                    OverviewView(showSettings: $showSettings, onRequestConsultation: openConsultation)
                        .tabItem { Label(Localization.text("tab_overview", language: language), systemImage: "house.fill") }
                        .tag(Tab.overview)

                    ComparisonView(showSettings: $showSettings)
                        .tabItem { Label(Localization.text("tab_comparison", language: language), systemImage: "chart.bar.fill") }
                        .tag(Tab.comparison)

                    MetalsView(showSettings: $showSettings, onRequestConsultation: openConsultation)
                        .tabItem {
                            VStack {
                                BrilliantDiamondIcon(size: 22)
                                Text(Localization.text("tab_metals", language: language))
                            }
                        }
                        .tag(Tab.metals)

                    CrisisView(showSettings: $showSettings)
                        .tabItem { Label(Localization.text("tab_crisis", language: language), systemImage: "exclamationmark.triangle.fill") }
                        .tag(Tab.crisis)

                    ConsultationView(showSettings: $showSettings)
                        .tabItem { Label(Localization.text("tab_consultation", language: language), systemImage: "person.text.rectangle") }
                        .tag(Tab.consultation)
                }
                .tint(Theme.accent)
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
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .presentationDetents([.medium, .large])
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
        .background(Theme.background)
    }

    private func openConsultation() {
        selectedTab = .consultation
    }
}

extension ContentView {
    enum Tab: Hashable {
        case overview
        case comparison
        case metals
        case crisis
        case consultation
    }
}

