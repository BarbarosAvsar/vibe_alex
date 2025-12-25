package de.vibecode.crisis.core.data

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

@Serializable
data class ConsultationRequest(
    val name: String,
    val email: String,
    val phone: String,
    val message: String,
    val locale: String
)

class ConsultationService(
    private val client: OkHttpClient,
    private val json: Json,
    private val endpoint: String = AppConfig.CONSULTATION_ENDPOINT
) {
    suspend fun submit(request: ConsultationRequest) {
        val body = json.encodeToString(ConsultationRequest.serializer(), request)
        val requestBody = body.toRequestBody("application/json".toMediaType())
        val httpRequest = Request.Builder()
            .url(endpoint)
            .post(requestBody)
            .addHeader("Content-Type", "application/json")
            .build()

        withContext(Dispatchers.IO) {
            client.newCall(httpRequest).execute().use { response ->
                if (!response.isSuccessful) {
                    error("HTTP ${response.code}")
                }
            }
        }
    }
}
