package de.vibecode.crisis

import android.content.Context
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import kotlinx.datetime.Clock
import java.util.concurrent.TimeUnit

class DashboardRefreshWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {
    override suspend fun doWork(): Result {
        val container = (applicationContext as CrisisApp).container
        return try {
            val snapshot = container.dashboardRepository.makeSnapshot()
            container.dashboardCache.persist(snapshot)
            val now = Clock.System.now()
            container.userPreferences.setLastSuccessfulSync(now)
            container.userPreferences.setLastSyncError(null)
            container.notificationHelper.processHighPriorityAlert(snapshot.crises)
            Result.success()
        } catch (error: Exception) {
            container.userPreferences.setLastSyncError(error.message ?: "Fehler beim Hintergrund-Update")
            Result.retry()
        }
    }

    companion object {
        private const val UNIQUE_NAME = "dashboard_refresh"

        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            val request = PeriodicWorkRequestBuilder<DashboardRefreshWorker>(6, TimeUnit.HOURS)
                .setConstraints(constraints)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                UNIQUE_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request
            )
        }
    }
}
