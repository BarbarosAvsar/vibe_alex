import SwiftUI

enum Theme {
    // Dark-only palette (Farbcode RGB)
    private static let baseBackground = Color(red: 0.059, green: 0.110, blue: 0.239) // #0f1c3d

    static let background = Color("BrandPrimary")
    static let surface = Color("BrandPrimary").opacity(0.68)
    static let border = Color.white.opacity(0.2)

    static let accent = Color("BrandWarm")
    static let accentStrong = Color("BrandWarm")
    static let accentInfo = Color("BrandCool")

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.9)
    static let textMuted = Color.white.opacity(0.72)
    static let textOnAccent = baseBackground
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
