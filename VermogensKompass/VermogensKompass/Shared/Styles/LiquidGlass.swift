import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let gradient = Gradient(colors: [
                Color(red: 0.07, green: 0.08, blue: 0.18),
                Color(red: 0.05, green: 0.16, blue: 0.34),
                Color(red: 0.09, green: 0.09, blue: 0.18)
            ])

            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay(
                    RadialGradient(colors: [Color.orange.opacity(0.35), .clear], center: .topTrailing, startRadius: 20, endRadius: max(proxy.size.width, proxy.size.height))
                )
                .blur(radius: 40)
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
                .ultraThinMaterial.opacity(0.8),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

extension View {
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }
}
