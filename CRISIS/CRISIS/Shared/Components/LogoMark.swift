import SwiftUI

struct LogoMark: View {
    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(height: 26)
            .accessibilityHidden(true)
    }
}

#Preview {
    LogoMark()
        .padding()
        .background(Theme.background)
}
