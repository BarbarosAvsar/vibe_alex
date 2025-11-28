import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let warmOpacity = 0.22
            let coolOpacity = 0.18
            let primaryOpacity = 0.18
            let base = Theme.background

            LinearGradient(
                colors: [
                    base.opacity(0.98),
                    base.opacity(0.94),
                    base.opacity(0.9)
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
                .background(base)
                .ignoresSafeArea()
                .compositingGroup()
        }
    }
}

struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                shape
                    .fill(Theme.surface)
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.14),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(shape)
                    }
                    .overlay {
                        LinearGradient(
                            colors: [
                                Theme.accent.opacity(0.12),
                                Theme.accentInfo.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(shape)
                    }
            )
            .overlay(
                shape
                    .strokeBorder(Theme.border.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: Theme.accent.opacity(0.14), radius: 18, x: 0, y: 8)
            .compositingGroup()
    }
}

extension View {
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }
}
