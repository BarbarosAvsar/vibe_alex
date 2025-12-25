package de.vibecode.crisis

import android.app.Application

class CrisisApp : Application() {
    lateinit var container: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()
        container = AppContainer(this)
        container.notificationHelper.ensureChannel()
    }
}
