package de.vibecode.crisis.core.model

data class CrisisSettings(
    val thresholdProfile: CrisisThresholdProfile,
    val geopoliticalWatchlist: Set<String>,
    val financialWatchlist: Set<String>
)

enum class CrisisThresholdProfile(
    val id: String,
    val highRiskSeverityScore: Double,
    val governanceCutoff: Double,
    val recessionCutoff: Double
) {
    STANDARD("standard", 5.0, -0.5, 0.0),
    SENSITIVE("sensitive", 4.5, -0.3, 0.5),
    CONSERVATIVE("conservative", 5.5, -0.7, -0.5);

    companion object {
        fun fromId(id: String?): CrisisThresholdProfile {
            return entries.firstOrNull { it.id == id } ?: STANDARD
        }
    }
}

data class WatchlistCountry(
    val code: String,
    val name: String
)

object CrisisWatchlists {
    val geopolitical = listOf(
        WatchlistCountry("UKR", "Ukraine"),
        WatchlistCountry("ISR", "Israel"),
        WatchlistCountry("TWN", "Taiwan"),
        WatchlistCountry("ZAF", "South Africa"),
        WatchlistCountry("DEU", "Germany")
    )

    val financial = listOf(
        WatchlistCountry("DEU", "Germany"),
        WatchlistCountry("USA", "United States"),
        WatchlistCountry("GBR", "United Kingdom"),
        WatchlistCountry("JPN", "Japan"),
        WatchlistCountry("CHN", "China")
    )
}
