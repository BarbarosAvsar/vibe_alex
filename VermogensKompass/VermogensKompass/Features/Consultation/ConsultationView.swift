import SwiftUI

struct ConsultationView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            ConsultationFormView()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ToolbarStatusControl(lastUpdated: appState.lastUpdated) {
                            showSettings = true
                        }
                    }
                }
        }
    }
}
