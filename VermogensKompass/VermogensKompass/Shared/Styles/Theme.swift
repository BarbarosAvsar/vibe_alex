import SwiftUI

enum Theme {
    // System-driven surfaces for automatic light/dark appearance
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let border = Color(.separator)

    // Brand accents (Farbcode RGB): Primary, Warm (CTA), Cool (Info)
    static let accent = Color("BrandPrimary")
    static let accentStrong = Color("BrandWarm")
    static let accentInfo = Color("BrandCool")

    // Text colors align to Apple system dynamic text
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textMuted = Color(.tertiaryLabel)
    static let textOnAccent = Color("BrandPrimary")
}

extension View {
    func cardStyle() -> some View {
        liquidGlassCard()
    }
}
