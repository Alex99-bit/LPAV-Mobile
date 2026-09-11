package com.lpav.market.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.lpav.market.ui.auth.LoginScreen
import com.lpav.market.ui.auth.RegisterScreen
import com.lpav.market.ui.auth.OnboardingQuestionnaireScreen
import com.lpav.market.ui.auth.AgencyAuthScreen
import com.lpav.market.ui.auth.AgencyRegisterScreen
import com.lpav.market.ui.home.HomeScreen
import com.lpav.market.ui.home.PackageDetailScreen
import com.lpav.market.ui.home.WishlistScreen
import com.lpav.market.ui.chat.ChatListScreen
import com.lpav.market.ui.chat.ChatScreen
import com.lpav.market.ui.checkout.CartScreen
import com.lpav.market.ui.checkout.CheckoutScreen
import com.lpav.market.ui.checkout.OrdersScreen
import com.lpav.market.ui.profile.ProfileScreen
import com.lpav.market.ui.profile.PointsWalletScreen
import com.lpav.market.ui.agency.AgencyDashboardScreen
import com.lpav.market.ui.agency.AgencyFlyersScreen
import com.lpav.market.ui.agency.AgencyCRMScreen
import com.lpav.market.ui.agency.AgencyFinanceScreen
import com.lpav.market.ui.agency.AgencyLogisticsScreen
import com.lpav.market.ui.agency.AgencySettingsScreen
import com.lpav.market.ui.home.HomeViewModel

@Composable
fun NavGraph() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    val bottomNavVisible = Screen.bottomNavItems.any { it.route == currentRoute } ||
        currentRoute in listOf("wishlist")

    Scaffold(
        bottomBar = {
            BottomNavBar(
                navController = navController,
                visible = bottomNavVisible
            )
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Home.route) {
                val viewModel: HomeViewModel = hiltViewModel()
                HomeScreen(
                    navController = navController,
                    viewModel = viewModel
                )
            }

            composable(Screen.Search.route) {
                HomeScreen(navController = navController, viewModel = hiltViewModel())
            }

            composable(Screen.Cart.route) {
                CartScreen(navController = navController)
            }

            composable(Screen.Chat.route) {
                ChatListScreen(navController = navController)
            }

            composable(Screen.Profile.route) {
                ProfileScreen(navController = navController)
            }

            composable(
                route = "package/{packageId}",
                arguments = listOf(navArgument("packageId") { type = NavType.StringType })
            ) { backStackEntry ->
                val packageId = backStackEntry.arguments?.getString("packageId") ?: ""
                PackageDetailScreen(
                    navController = navController,
                    packageId = packageId
                )
            }

            composable(Screen.Wishlist.route) {
                WishlistScreen(navController = navController)
            }

            composable(Screen.Login.route) {
                LoginScreen(navController = navController)
            }

            composable(Screen.Register.route) {
                RegisterScreen(navController = navController)
            }

            composable(Screen.Onboarding.route) {
                OnboardingQuestionnaireScreen(navController = navController)
            }

            composable(Screen.AgencyAuth.route) {
                AgencyAuthScreen(navController = navController)
            }

            composable(Screen.AgencyRegister.route) {
                AgencyRegisterScreen(navController = navController)
            }

            composable(Screen.Checkout.route) {
                CheckoutScreen(navController = navController)
            }

            composable(Screen.Orders.route) {
                OrdersScreen(navController = navController)
            }

            composable(Screen.PointsWallet.route) {
                PointsWalletScreen(navController = navController)
            }

            composable(Screen.AgencyDashboard.route) {
                AgencyDashboardScreen(navController = navController)
            }

            composable(Screen.AgencyFlyers.route) {
                AgencyFlyersScreen(navController = navController)
            }

            composable(Screen.AgencyCRM.route) {
                AgencyCRMScreen(navController = navController)
            }

            composable(Screen.AgencyFinance.route) {
                AgencyFinanceScreen(navController = navController)
            }

            composable(Screen.AgencyLogistics.route) {
                AgencyLogisticsScreen(navController = navController)
            }

            composable(Screen.AgencySettings.route) {
                AgencySettingsScreen(navController = navController)
            }

            composable(
                route = "chat/{conversationId}",
                arguments = listOf(navArgument("conversationId") { type = NavType.StringType })
            ) { backStackEntry ->
                val conversationId = backStackEntry.arguments?.getString("conversationId") ?: ""
                ChatScreen(
                    navController = navController,
                    conversationId = conversationId
                )
            }
        }
    }
}
