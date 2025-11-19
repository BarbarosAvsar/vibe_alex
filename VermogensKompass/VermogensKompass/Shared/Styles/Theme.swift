import SwiftUI

enum Theme {
    static let background = Color("BrandBackground")
    static let surface = Color("BrandSurface")
    static let accent = Color("BrandAccent")
    static let accentStrong = Color("BrandAccentStrong")
    static let textPrimary = Color("BrandTextPrimary")
    static let textSecondary = Color("BrandTextSecondary")
    static let textMuted = Color("BrandMuted")
    static let textOnAccent = Color("BrandTextOnAccent")
    static let border = Color("BrandBorder")
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
