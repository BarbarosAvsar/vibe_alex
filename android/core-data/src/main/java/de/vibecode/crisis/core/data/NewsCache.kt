package de.vibecode.crisis.core.data

import android.content.Context
import de.vibecode.crisis.core.model.CrisisEvent
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.io.File

class NewsCache(
    context: Context,
    private val json: Json
) {
    private val file = File(context.cacheDir, "news-cache.json")

    suspend fun load(): NewsCacheSnapshot? {
        return withContext(Dispatchers.IO) {
            if (!file.exists()) return@withContext null
            runCatching {
                json.decodeFromString(NewsCacheSnapshot.serializer(), file.readText())
            }.getOrNull()
        }
    }

    suspend fun persist(events: List<CrisisEvent>) {
        withContext(Dispatchers.IO) {
            runCatching {
                val snapshot = NewsCacheSnapshot(events, Clock.System.now())
                file.writeText(json.encodeToString(NewsCacheSnapshot.serializer(), snapshot))
            }
        }
    }
}

@Serializable
data class NewsCacheSnapshot(
    val events: List<CrisisEvent>,
    val updatedAt: Instant
)
