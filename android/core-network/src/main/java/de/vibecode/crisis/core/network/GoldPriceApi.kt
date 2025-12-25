package de.vibecode.crisis.core.network

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import retrofit2.http.GET

interface GoldPriceApi {
    @GET("dbXRates/USD")
    suspend fun fetchRates(): GoldPricePayload
}

@Serializable
data class GoldPricePayload(
    val ts: Double,
    val items: List<GoldPriceItem>
)

@Serializable
data class GoldPriceItem(
    val curr: String,
    val xauPrice: Double,
    val xagPrice: Double,
    val chgXau: Double,
    val chgXag: Double,
    val pcXau: Double,
    val pcXag: Double
)
