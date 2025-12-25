import SwiftUI

struct VisionContentView: View {
    @State private var showConsultationSheet = false

    var body: some View {
        NavigationStack {
            PlatformDashboardView {
                showConsultationSheet = true
            }
            .navigationTitle("CRISIS")
            .toolbar {
                ToolbarItem(placement: AdaptiveToolbarPlacement.trailing) {
                    Button("Beratung") {
                        showConsultationSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showConsultationSheet) {
            ConsultationPanelView()
                .frame(minWidth: 500, minHeight: 500)
        }
    }
}
