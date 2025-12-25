package de.vibecode.crisis.core.network

import kotlinx.serialization.Serializable
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Query

interface NewsApi {
    @GET("v2/top-headlines")
    suspend fun topHeadlines(
        @Query("category") category: String,
        @Query("language") language: String = "en",
        @Query("pageSize") pageSize: Int = 6,
        @Header("X-Api-Key") apiKey: String
    ): NewsApiResponse

    @GET("v2/everything")
    suspend fun everything(
        @Query("q") query: String,
        @Query("language") language: String = "en",
        @Query("pageSize") pageSize: Int = 6,
        @Query("sortBy") sortBy: String = "publishedAt",
        @Header("X-Api-Key") apiKey: String
    ): NewsApiResponse
}

@Serializable
data class NewsApiResponse(
    val articles: List<NewsApiArticle> = emptyList()
)

@Serializable
data class NewsApiArticle(
    val title: String? = null,
    val description: String? = null,
    val content: String? = null,
    val publishedAt: String? = null,
    val url: String? = null,
    val source: NewsApiSource = NewsApiSource()
)

@Serializable
data class NewsApiSource(
    val name: String? = null
)
