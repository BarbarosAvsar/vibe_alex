import SwiftUI

struct AdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private let spacing: CGFloat
    private let horizontalAlignment: VerticalAlignment
    private let verticalAlignment: HorizontalAlignment
    private let content: () -> Content

    init(
        spacing: CGFloat = 24,
        horizontalAlignment: VerticalAlignment = .top,
        verticalAlignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.content = content
    }

    var body: some View {
        let primary = AnyLayout(prefersHorizontal
            ? HStackLayout(alignment: horizontalAlignment, spacing: spacing)
            : VStackLayout(alignment: verticalAlignment, spacing: spacing)
        )
        let fallback = AnyLayout(prefersHorizontal
            ? VStackLayout(alignment: verticalAlignment, spacing: spacing)
            : HStackLayout(alignment: horizontalAlignment, spacing: spacing)
        )

        ViewThatFits(in: .horizontal) {
            primary { content() }
            fallback { content() }
        }
    }

    private var prefersHorizontal: Bool {
        if let horizontalSizeClass {
            return horizontalSizeClass == .regular
        }
        if let verticalSizeClass {
            return verticalSizeClass != .compact
        }
        return true
    }
}

enum AdaptiveToolbarPlacement {
    static var leading: ToolbarItemPlacement {
        #if os(macOS)
        return .navigation
        #elseif os(watchOS)
        return .automatic
        #else
        return .topBarLeading
        #endif
    }

    static var trailing: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #elseif os(watchOS)
        return .automatic
        #else
        return .topBarTrailing
        #endif
    }
}
