import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let palette = Gradient(colors: [
                Color(red: 0.02, green: 0.04, blue: 0.18),
                Color(red: 0.06, green: 0.15, blue: 0.42),
                Color(red: 0.16, green: 0.12, blue: 0.34)
            ])

            LinearGradient(gradient: palette, startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay(
                    AngularGradient(
                        colors: [
                            Theme.accent.opacity(0.45),
                            Color.purple.opacity(0.3),
                            .clear
                        ],
                        center: .center
                    )
                    .blur(radius: 80)
                )
                .overlay(
                    RadialGradient(
                        colors: [Theme.accent.opacity(0.2), .clear],
                        center: .topTrailing,
                        startRadius: 40,
                        endRadius: max(proxy.size.width, proxy.size.height)
                    )
                )
                .blur(radius: 50)
                .ignoresSafeArea()
        }
    }
}

struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .ultraThinMaterial.opacity(0.85),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }
}
