package de.vibecode.crisis.core.model

import kotlinx.serialization.Serializable

@Serializable
enum class DataSource(val label: String, val url: String) {
    GOLD_PRICE("GoldPrice.org", "https://data-asg.goldprice.org"),
    WORLD_BANK("World Bank", "https://data.worldbank.org"),
    WORLD_BANK_GOVERNANCE("World Bank Governance", "https://data.worldbank.org/indicator/PV.PSR.PIND"),
    WORLD_BANK_FINANCE("World Bank Finance", "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG"),
    NEWS_API("NewsAPI.org", "https://newsapi.org");
}
