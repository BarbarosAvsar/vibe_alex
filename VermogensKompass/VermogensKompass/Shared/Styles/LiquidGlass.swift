import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let warmOpacity = 0.22
            let coolOpacity = 0.18
            let primaryOpacity = 0.12

            LinearGradient(
                colors: [
                    Theme.background.opacity(0.95),
                    Theme.background,
                    Theme.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .overlay {
                    RadialGradient(
                        colors: [
                            Theme.accentInfo.opacity(coolOpacity),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 32,
                        endRadius: max(proxy.size.width, proxy.size.height)
                    )
                    .blur(radius: 96)
                }
                .overlay {
                    RadialGradient(
                        colors: [
                            Theme.accentStrong.opacity(warmOpacity),
                            .clear
                        ],
                        center: .bottomLeading,
                        startRadius: 48,
                        endRadius: max(proxy.size.width, proxy.size.height)
                    )
                    .blur(radius: 128)
                }
                .overlay {
                    RadialGradient(
                        colors: [
                            Theme.accent.opacity(primaryOpacity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 64,
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
            .shadow(color: Theme.accent.opacity(0.12), radius: 18, x: 0, y: 8)
    }
}

extension View {
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }
}
