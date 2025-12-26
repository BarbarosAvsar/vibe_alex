package de.vibecode.crisis.ui

import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.automirrored.filled.ShowChart
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.windowsizeclass.WindowSizeClass
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import de.vibecode.crisis.MainViewModel
import de.vibecode.crisis.NotificationAuthorizationState
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.components.LiquidGlassBackground
import de.vibecode.crisis.ui.components.NotificationPermissionBanner
import de.vibecode.crisis.ui.components.SyncStatusBanner
import de.vibecode.crisis.ui.screens.ComparisonScreen
import de.vibecode.crisis.ui.screens.ConsultationScreen
import de.vibecode.crisis.ui.screens.CrisisScreen
import de.vibecode.crisis.ui.screens.MetalsScreen
import de.vibecode.crisis.ui.screens.OverviewScreen
import de.vibecode.crisis.ui.screens.PrivacyPolicyScreen
import de.vibecode.crisis.ui.screens.SettingsSheet
import de.vibecode.crisis.ui.screens.NotificationOnboardingDialog

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun AppRoot(
    viewModel: MainViewModel,
    windowSizeClass: WindowSizeClass
) {
    val context = LocalContext.current
    val navController = rememberNavController()

    val dashboardState by viewModel.dashboardState.collectAsStateWithLifecycle()
    val syncNotice by viewModel.syncNotice.collectAsStateWithLifecycle()
    val notificationStatus by viewModel.notificationStatus.collectAsStateWithLifecycle()
    val selectedCurrency by viewModel.selectedCurrency.collectAsStateWithLifecycle()
    val exchangeRates by viewModel.exchangeRates.collectAsStateWithLifecycle()
    val onboardingCompleted by viewModel.onboardingCompleted.collectAsStateWithLifecycle()

    var showSettings by remember { mutableStateOf(false) }
    var showOnboarding by remember { mutableStateOf(false) }

    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { granted ->
        viewModel.refreshNotificationStatus()
        if (granted) {
            viewModel.markOnboardingCompleted()
            showOnboarding = false
        }
    }

    val openNotificationSettings: () -> Unit = {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
        }
        context.startActivity(intent)
    }

    val requestNotifications: () -> Unit = {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissionLauncher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
        } else {
            viewModel.refreshNotificationStatus()
            viewModel.markOnboardingCompleted()
            showOnboarding = false
        }
    }

    LaunchedEffect(Unit) {
        viewModel.refreshRates()
        viewModel.refreshNotificationStatus()
        if (dashboardState is de.vibecode.crisis.core.model.AsyncState.Idle) {
            viewModel.refreshDashboard(force = true)
        }
    }

    LaunchedEffect(notificationStatus, onboardingCompleted) {
        if (!onboardingCompleted && notificationStatus.requiresOnboarding) {
            showOnboarding = true
        }
    }

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    LiquidGlassBackground {
        Scaffold(
            modifier = Modifier.fillMaxSize(),
            bottomBar = {
                NavigationBar(containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.8f)) {
                    TopLevelDestination.entries.forEach { destination ->
                        NavigationBarItem(
                            selected = currentRoute == destination.route,
                            onClick = {
                                navController.navigate(destination.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = {
                                destination.icon()
                            },
                            label = {
                                Text(text = stringResource(destination.label))
                            }
                        )
                    }
                }
            }
        ) { padding ->
            Column(modifier = Modifier.padding(padding)) {
                if (syncNotice != null) {
                    Box(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
                        SyncStatusBanner(notice = syncNotice!!)
                    }
                }
                if (notificationStatus.requiresOnboarding) {
                    Box(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
                        NotificationPermissionBanner(status = notificationStatus) {
                            when (notificationStatus) {
                                NotificationAuthorizationState.DENIED -> openNotificationSettings()
                                NotificationAuthorizationState.NOT_DETERMINED -> {
                                    showOnboarding = true
                                }
                                else -> Unit
                            }
                        }
                    }
                }

                NavHost(
                    navController = navController,
                    startDestination = TopLevelDestination.Overview.route,
                    modifier = Modifier.fillMaxSize()
                ) {
                    composable(TopLevelDestination.Overview.route) {
                        OverviewScreen(
                            dashboardState = dashboardState,
                            bennerEntries = viewModel.bennerEntries,
                            windowSizeClass = windowSizeClass,
                            selectedCurrency = selectedCurrency,
                            exchangeRates = exchangeRates,
                            onRefresh = { viewModel.refreshDashboard(force = true) },
                            onOpenSettings = { showSettings = true },
                            onOpenConsultation = { navController.navigate(TopLevelDestination.Consultation.route) }
                        )
                    }
                    composable(TopLevelDestination.Comparison.route) {
                        ComparisonScreen(
                            dashboardState = dashboardState,
                            bennerEntries = viewModel.bennerEntries,
                            windowSizeClass = windowSizeClass,
                            onRefresh = { viewModel.refreshDashboard(force = true) },
                            onOpenSettings = { showSettings = true }
                        )
                    }
                    composable(TopLevelDestination.Metals.route) {
                        MetalsScreen(
                            dashboardState = dashboardState,
                            bennerEntries = viewModel.bennerEntries,
                            windowSizeClass = windowSizeClass,
                            selectedCurrency = selectedCurrency,
                            exchangeRates = exchangeRates,
                            onRefresh = { viewModel.refreshDashboard(force = true) },
                            onOpenSettings = { showSettings = true },
                            onOpenConsultation = { navController.navigate(TopLevelDestination.Consultation.route) }
                        )
                    }
                    composable(TopLevelDestination.Crisis.route) {
                        CrisisScreen(
                            dashboardState = dashboardState,
                            onRefresh = { viewModel.refreshDashboard(force = true) },
                            onOpenSettings = { showSettings = true },
                            windowSizeClass = windowSizeClass
                        )
                    }
                    composable(TopLevelDestination.Consultation.route) {
                        ConsultationScreen(
                            onOpenSettings = { showSettings = true }
                        )
                    }
                    composable("privacy") {
                        PrivacyPolicyScreen(onClose = { navController.popBackStack() })
                    }
                }
            }

            if (showSettings) {
                ModalBottomSheet(onDismissRequest = { showSettings = false }) {
                    SettingsSheet(
                        selectedCurrency = selectedCurrency,
                        notificationStatus = notificationStatus,
                        onCurrencySelected = { viewModel.setSelectedCurrency(it) },
                        onNotificationAction = { status ->
                            when (status) {
                                NotificationAuthorizationState.DENIED,
                                NotificationAuthorizationState.AUTHORIZED -> openNotificationSettings()
                                NotificationAuthorizationState.NOT_DETERMINED,
                                NotificationAuthorizationState.UNKNOWN -> requestNotifications()
                            }
                        },
                        onOpenPrivacyPolicy = {
                            showSettings = false
                            navController.navigate("privacy")
                        },
                        onClose = { showSettings = false }
                    )
                }
            }

            if (showOnboarding) {
                NotificationOnboardingDialog(
                    status = notificationStatus,
                    onDismiss = {
                        viewModel.markOnboardingCompleted()
                        showOnboarding = false
                    },
                    onEnable = {
                        if (notificationStatus == NotificationAuthorizationState.DENIED) {
                            openNotificationSettings()
                        } else {
                            requestNotifications()
                        }
                    }
                )
            }
        }
    }
}

enum class TopLevelDestination(val route: String, val label: Int, val icon: @Composable () -> Unit) {
    Overview("overview", R.string.tab_overview, { androidx.compose.material3.Icon(Icons.Default.Home, null) }),
    Comparison("comparison", R.string.tab_comparison, { androidx.compose.material3.Icon(Icons.AutoMirrored.Filled.ShowChart, null) }),
    Metals("metals", R.string.tab_metals, { de.vibecode.crisis.ui.components.BrilliantDiamondIcon(iconSize = 20.dp) }),
    Crisis("crisis", R.string.tab_crisis, { androidx.compose.material3.Icon(Icons.Default.Warning, null) }),
    Consultation("consultation", R.string.tab_consultation, { androidx.compose.material3.Icon(Icons.Default.Person, null) });
}
