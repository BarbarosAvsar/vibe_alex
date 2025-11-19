import SwiftUI

struct MetalsView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @State private var showConsultationForm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    currencySelector
                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { snapshot in
                        VStack(spacing: 24) {
                            ForEach(snapshot.metals) { asset in
                                MetalCard(asset: asset)
                            }

                            DashboardSection("Warum physische Edelmetalle?", subtitle: "Regelbasiert aus den aktuellen Daten") {
                                VStack(alignment: .leading, spacing: 12) {
                                    bullet(icon: "checkmark.circle.fill", text: "Inflationsschutz: \(snapshot.macroOverview.indicators.first(where: { $0.id == .inflation })?.formattedValue ?? "–")")
                                    bullet(icon: "checkmark.circle.fill", text: "Konjunkturdiversifikation über reale Werte")
                                    bullet(icon: "checkmark.circle.fill", text: "Unabhängig vom Finanzsystem dank physischer Lagerung")
                                }
                                .cardStyle()
                            }

                            PrimaryCTAButton(action: { showConsultationForm = true })
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Edelmetalle")
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
            .navigationDestination(isPresented: $showConsultationForm) {
                ConsultationFormView()
            }
        }
    }

    private var currencySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Währung")
                .font(.headline)
            Picker("Währung", selection: Binding(get: {
                currencySettings.selectedCurrency
            }, set: { currencySettings.selectedCurrency = $0 })) {
                ForEach(DisplayCurrency.allCases) { currency in
                    Text(currency.title).tag(currency)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func bullet(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
            Text(text)
                .font(.subheadline)
        }
    }
}
