package de.vibecode.crisis

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.material3.windowsizeclass.ExperimentalMaterial3WindowSizeClassApi
import androidx.compose.material3.windowsizeclass.calculateWindowSizeClass
import de.vibecode.crisis.ui.AppRoot
import de.vibecode.crisis.ui.theme.CrisisTheme

class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels()

    @OptIn(ExperimentalMaterial3WindowSizeClassApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        DashboardRefreshWorker.schedule(applicationContext)
        setContent {
            val windowSizeClass = calculateWindowSizeClass(this)
            CrisisTheme {
                AppRoot(viewModel = viewModel, windowSizeClass = windowSizeClass)
            }
        }
    }
}
