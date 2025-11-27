import SwiftUI

enum Theme {
    // Dark-only palette (Farbcode RGB)
    static let background = Color("BrandPrimary")
    static let surface = Color("BrandPrimary").opacity(0.82)
    static let border = Color("BrandCool").opacity(0.25)

    static let accent = Color("BrandWarm")
    static let accentStrong = Color("BrandWarm")
    static let accentInfo = Color("BrandCool")

    static let textPrimary = Color("BrandCool")
    static let textSecondary = Color("BrandCool").opacity(0.85)
    static let textMuted = Color("BrandCool").opacity(0.65)
    static let textOnAccent = Color("BrandPrimary")
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
