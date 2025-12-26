package de.vibecode.crisis.core.network

import kotlinx.serialization.json.Json
import okhttp3.CertificatePinner
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.create
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import java.io.IOException
import java.util.concurrent.TimeUnit

object NetworkClient {
    val json: Json = Json {
        ignoreUnknownKeys = true
    }

    private val httpClient: OkHttpClient by lazy { buildOkHttpClient() }

    private fun buildOkHttpClient(): OkHttpClient {
        val logging = HttpLoggingInterceptor()
        logging.level = if (BuildConfig.DEBUG) HttpLoggingInterceptor.Level.BASIC else HttpLoggingInterceptor.Level.NONE
        val httpsOnlyInterceptor = Interceptor { chain ->
            val request = chain.request()
            if (request.url.scheme != "https") {
                throw IOException("Cleartext HTTP is not permitted.")
            }
            chain.proceed(request)
        }
        val builder = OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS)
            .callTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(httpsOnlyInterceptor)
            .addInterceptor(logging)
        val pins = NetworkPins.hostPins
        if (pins.isNotEmpty()) {
            val pinner = CertificatePinner.Builder().apply {
                pins.forEach { (host, hostPins) ->
                    hostPins.forEach { add(host, it) }
                }
            }.build()
            builder.certificatePinner(pinner)
        }
        return builder.build()
    }

    private fun retrofit(baseUrl: String): Retrofit {
        return Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(httpClient)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    fun goldPriceApi(): GoldPriceApi = retrofit("https://data-asg.goldprice.org/").create()

    fun newsApi(): NewsApi = retrofit("https://newsapi.org/").create()

    fun httpClient(): OkHttpClient = httpClient
}
