import SwiftUI

struct MetricCard: View {
    let indicator: MacroIndicator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(indicator.title)
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text(indicator.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(indicator.formattedValue)
                .font(.largeTitle.weight(.semibold))
            Text(indicator.deltaDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(indicator.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}
