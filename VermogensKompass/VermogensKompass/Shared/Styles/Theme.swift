import SwiftUI

enum Theme {
    static let background = Color("BrandDark")
    static let accent = Color("BrandOrange")
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
