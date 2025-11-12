import SwiftUI

struct AsyncStateView<Content: View, Value>: View {
    let state: AsyncState<Value>
    let retry: () -> Void
    @ViewBuilder var content: (Value) -> Content

    init(state: AsyncState<Value>, retry: @escaping () -> Void, @ViewBuilder content: @escaping (Value) -> Content) {
        self.state = state
        self.retry = retry
        self.content = content
    }

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView("Aktualisiere Daten…")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .failed(let message):
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                Text(message)
                    .multilineTextAlignment(.center)
                Button("Erneut versuchen", action: retry)
            }
            .padding()
            .frame(maxWidth: .infinity)
        case .loaded(let value):
            content(value)
        }
    }
}
