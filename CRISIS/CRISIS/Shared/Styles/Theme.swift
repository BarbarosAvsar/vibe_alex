import SwiftUI

enum Theme {
    private static let baseBackground = Color("BrandPrimary")
    private static let baseWarm = Color("BrandWarm")
    private static let baseCool = Color("BrandCool")

    static let background = baseBackground
    static let surface = baseCool.opacity(0.15)
    static let border = baseCool.opacity(0.35)

    static let accent = baseWarm
    static let accentStrong = baseWarm.opacity(0.9)
    static let accentInfo = baseCool

    static let textPrimary = baseWarm
    static let textSecondary = baseWarm.opacity(0.8)
    static let textMuted = baseCool.opacity(0.7)
    static let textOnAccent = baseBackground
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
