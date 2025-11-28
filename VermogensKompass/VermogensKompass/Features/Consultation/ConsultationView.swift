import SwiftUI

struct ConsultationView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    ConsultationFormView()
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    LogoMark()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarStatusControl {
                        showSettings = true
                    }
                }
            }
            .background(Theme.background)
        }
    }
}
