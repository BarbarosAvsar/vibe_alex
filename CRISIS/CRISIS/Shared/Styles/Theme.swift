import SwiftUI

enum Theme {
    // Light LiquidGlass palette
    private static let baseBackground = Color(red: 0.98, green: 0.95, blue: 0.97)
    private static let textBase = Color("BrandPrimary")

    static let background = baseBackground
    static let surface = Color.white.opacity(0.75)
    static let border = textBase.opacity(0.12)

    static let accent = Color("BrandWarm")
    static let accentStrong = Color("BrandWarm")
    static let accentInfo = Color("BrandCool")

    static let textPrimary = textBase
    static let textSecondary = textBase.opacity(0.8)
    static let textMuted = textBase.opacity(0.6)
    static let textOnAccent = textBase
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
