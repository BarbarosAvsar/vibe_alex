package de.vibecode.crisis.core.data

import android.content.Context
import de.vibecode.crisis.core.model.DashboardSnapshot
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import java.io.File

class DashboardCache(
    context: Context,
    private val json: Json
) {
    private val file = File(context.cacheDir, "dashboard-cache.json")

    suspend fun persist(snapshot: DashboardSnapshot) {
        withContext(Dispatchers.IO) {
            runCatching {
                file.writeText(json.encodeToString(DashboardSnapshot.serializer(), snapshot))
            }
        }
    }

    suspend fun load(): DashboardSnapshot? {
        return withContext(Dispatchers.IO) {
            if (!file.exists()) return@withContext null
            runCatching {
                json.decodeFromString(DashboardSnapshot.serializer(), file.readText())
            }.getOrNull()
        }
    }
}
