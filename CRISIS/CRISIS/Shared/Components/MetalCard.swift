import SwiftUI

@MainActor
struct MetalCard: View {
    let asset: MetalAsset
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(asset.localizedName(language: languageSettings.selectedLanguage))
                        .font(.headline)
                    Text(asset.symbol)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
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
                    .foregroundStyle(Theme.textMuted)
            }

            Divider().opacity(0.2)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 8) {
                ForEach(asset.insights) { insight in
                    HStack {
                        Image(systemName: insight.icon)
                            .font(.caption)
                        Text(insight.localizedLabel(language: languageSettings.selectedLanguage))
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

            Text(Localization.format("metal_source_label", language: languageSettings.selectedLanguage, asset.dataSource.rawValue))
                .font(.caption2)
                .foregroundStyle(Theme.textMuted)
        }
        .cardStyle()
    }

    private var changeText: String {
        let formatter = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(2))
            .locale(languageSettings.selectedLanguage.locale)
        let value = asset.dailyChangePercentage.formatted(formatter)
        let label = Localization.text("metal_insight_24h", language: languageSettings.selectedLanguage)
        return "\(value)% \(label)"
    }

    private var displayPrice: Double {
        currencySettings.converter.convert(
            amount: asset.price,
            from: asset.currency,
            to: currencySettings.selectedCurrency
        )
    }
}
