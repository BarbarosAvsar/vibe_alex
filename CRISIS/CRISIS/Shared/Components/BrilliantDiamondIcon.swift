import SwiftUI

struct BrilliantDiamondIcon: View {
    var size: CGFloat = 20

    var body: some View {
        GeometryReader { proxy in
            let s = min(proxy.size.width, proxy.size.height)
            let top = CGPoint(x: s * 0.5, y: s * 0.06)
            let leftTop = CGPoint(x: s * 0.18, y: s * 0.32)
            let rightTop = CGPoint(x: s * 0.82, y: s * 0.32)
            let left = CGPoint(x: s * 0.06, y: s * 0.36)
            let right = CGPoint(x: s * 0.94, y: s * 0.36)
            let bottom = CGPoint(x: s * 0.5, y: s * 0.96)
            let mid = CGPoint(x: s * 0.5, y: s * 0.6)

            let outline = Path { path in
                path.move(to: top)
                path.addLine(to: leftTop)
                path.addLine(to: left)
                path.addLine(to: bottom)
                path.addLine(to: right)
                path.addLine(to: rightTop)
                path.addLine(to: top)
            }

            let facets = Path { path in
                path.move(to: top)
                path.addLine(to: mid)
                path.move(to: left)
                path.addLine(to: mid)
                path.addLine(to: right)
                path.move(to: leftTop)
                path.addLine(to: CGPoint(x: s * 0.5, y: s * 0.34))
                path.addLine(to: rightTop)
                path.move(to: leftTop)
                path.addLine(to: rightTop)
            }

            ZStack {
                outline
                    .fill(
                        LinearGradient(
                            colors: [Theme.accent, Theme.accentInfo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        outline
                            .stroke(Theme.accentInfo.opacity(0.45), lineWidth: 1.2)
                    )
                facets
                    .stroke(Theme.accentInfo.opacity(0.6), lineWidth: 1)
            }
            .shadow(color: Theme.accent.opacity(0.25), radius: 4, x: 0, y: 2)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
