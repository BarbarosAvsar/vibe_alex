import SwiftUI

enum Theme {
    private static let baseBackground = Color("BrandPrimary")
    private static let baseWarm = Color("BrandWarm")
    private static let baseCool = Color("BrandCool")

    static let background = baseBackground
    static let surface = baseWarm.opacity(0.35)
    static let border = baseCool.opacity(0.2)

    static let accent = baseWarm
    static let accentStrong = baseWarm.opacity(0.9)
    static let accentInfo = baseWarm

    static let textPrimary = baseCool
    static let textSecondary = baseCool.opacity(0.8)
    static let textMuted = baseCool.opacity(0.6)
    static let textOnAccent = baseCool
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
