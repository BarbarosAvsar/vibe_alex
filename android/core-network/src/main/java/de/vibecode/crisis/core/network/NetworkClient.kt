package de.vibecode.crisis.core.network

import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.create
import retrofit2.converter.kotlinx.serialization.asConverterFactory

object NetworkClient {
    val json: Json = Json {
        ignoreUnknownKeys = true
    }

    private fun okHttpClient(): OkHttpClient {
        val logging = HttpLoggingInterceptor()
        logging.level = HttpLoggingInterceptor.Level.BASIC
        return OkHttpClient.Builder()
            .addInterceptor(logging)
            .build()
    }

    private fun retrofit(baseUrl: String): Retrofit {
        return Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(okHttpClient())
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    fun goldPriceApi(): GoldPriceApi = retrofit("https://data-asg.goldprice.org/").create()

    fun newsApi(): NewsApi = retrofit("https://newsapi.org/").create()

    fun httpClient(): OkHttpClient = okHttpClient()
}
