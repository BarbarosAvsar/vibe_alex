import SwiftUI

struct MetalCard: View {
    let asset: MetalAsset
    @Environment(CurrencySettings.self) private var currencySettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(asset.name)
                        .font(.headline)
                    Text(asset.symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(displayPrice, format: .currency(code: currencySettings.selectedCurrency.code))
                    .font(.title3.bold())
            }

            HStack(spacing: 8) {
                Label {
                    Text(changeText)
                } icon: {
                    Image(systemName: asset.dailyChangePercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                }
                .font(.caption)
                .foregroundStyle(asset.dailyChangePercentage >= 0 ? .green : .red)

                Text(asset.lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider().opacity(0.2)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 8) {
                ForEach(asset.insights) { insight in
                    HStack {
                        Image(systemName: insight.icon)
                            .font(.caption)
                        Text(insight.label)
                            .font(.caption)
                        Spacer()
                        Text(insight.value)
                            .font(.caption.weight(.semibold))
                    }
                    .padding(8)
                    .background(
                        Theme.background,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
            }

            HStack {
                Text("Quelle: \(asset.dataSource.rawValue)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Link("Daten öffnen", destination: asset.dataSource.url)
                    .font(.caption2)
            }
        }
        .cardStyle()
    }

    private var changeText: String {
        let value = asset.dailyChangePercentage.formatted(.number.precision(.fractionLength(2)))
        return "\(value)% 24h"
    }

    private var displayPrice: Double {
        currencySettings.converter.convert(
            amount: asset.price,
            from: asset.currency,
            to: currencySettings.selectedCurrency
        )
    }
}
