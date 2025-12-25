package de.vibecode.crisis

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import de.vibecode.crisis.core.data.UserPreferences
import de.vibecode.crisis.core.domain.CrisisThresholds
import de.vibecode.crisis.core.model.CrisisEvent
import kotlinx.coroutines.flow.first

class NotificationHelper(
    private val context: Context,
    private val preferences: UserPreferences
) {
    private val channelId = "crisis_alerts"

    fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                context.getString(R.string.crisis_notification_channel),
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = context.getString(R.string.notification_onboarding_body)
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    fun currentStatus(): NotificationAuthorizationState {
        val manager = NotificationManagerCompat.from(context)
        val enabled = manager.areNotificationsEnabled()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return if (enabled) NotificationAuthorizationState.AUTHORIZED else NotificationAuthorizationState.DENIED
        }
        val permission = ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
        return when {
            permission == android.content.pm.PackageManager.PERMISSION_GRANTED && enabled -> NotificationAuthorizationState.AUTHORIZED
            permission == android.content.pm.PackageManager.PERMISSION_GRANTED -> NotificationAuthorizationState.DENIED
            else -> NotificationAuthorizationState.NOT_DETERMINED
        }
    }

    suspend fun processHighPriorityAlert(events: List<CrisisEvent>) {
        if (currentStatus() != NotificationAuthorizationState.AUTHORIZED) return
        val event = events.maxByOrNull { it.severityScore } ?: return
        if (event.severityScore < CrisisThresholds.HIGH_RISK_SEVERITY_SCORE) return

        val lastNotified = preferences.lastNotifiedIdFlow.first()
        if (lastNotified == event.id) return
        preferences.setLastNotifiedId(event.id)

        sendNotification(event)
    }

    private fun sendNotification(event: CrisisEvent) {
        val category = when (event.category) {
            de.vibecode.crisis.core.model.CrisisCategory.FINANCIAL -> context.getString(R.string.crisis_category_financial)
            de.vibecode.crisis.core.model.CrisisCategory.GEOPOLITICAL -> context.getString(R.string.crisis_category_geopolitical)
        }
        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(context.getString(R.string.crisis_notification_title, event.title))
            .setContentText(context.getString(R.string.crisis_notification_body, event.region, category))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(context).notify(event.id.hashCode(), notification)
    }
}

enum class NotificationAuthorizationState {
    UNKNOWN,
    NOT_DETERMINED,
    DENIED,
    AUTHORIZED;

    val requiresOnboarding: Boolean
        get() = this != AUTHORIZED
}
