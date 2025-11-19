import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let gradient = Gradient(colors: [
                Theme.background,
                Theme.background.opacity(0.95),
                Theme.surface
            ])

            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay {
                    RadialGradient(
                        colors: [
                            Theme.accent.opacity(0.35),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 32,
                        endRadius: max(proxy.size.width, proxy.size.height)
                    )
                    .blur(radius: 80)
                }
                .overlay {
                    RadialGradient(
                        colors: [
                            Theme.accentStrong.opacity(0.2),
                            .clear
                        ],
                        center: .bottomLeading,
                        startRadius: 24,
                        endRadius: max(proxy.size.width, proxy.size.height)
                    )
                    .blur(radius: 120)
                }
                .ignoresSafeArea()
        }
    }
}

struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Theme.surface,
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Theme.border.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Theme.textPrimary.opacity(0.08), radius: 18, x: 0, y: 8)
    }
}

extension View {
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }
}
