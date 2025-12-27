import SwiftUI

struct LogoMark: View {
    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(height: 26)
            .accessibilityLabel("CRISIS 2050 logo")
    }
}

#Preview {
    LogoMark()
        .padding()
        .background(Theme.background)
}
