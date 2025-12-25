import SwiftUI

#if DEBUG
@testable import CRISIS

#Preview("Root view") {
    ContentView()
        .environment(AppState(repository: DashboardRepository(mockData: MockData.snapshot)))
}
#endif
