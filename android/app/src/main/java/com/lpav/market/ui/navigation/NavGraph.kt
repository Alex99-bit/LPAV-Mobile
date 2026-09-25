package com.lpav.market.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
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
import com.lpav.market.ui.home.HomeScreen
import com.lpav.market.ui.home.HomeViewModel
import com.lpav.market.ui.cart.CartScreen
import com.lpav.market.ui.chat.ChatScreen
import com.lpav.market.ui.checkout.CheckoutScreen
import com.lpav.market.ui.orders.OrdersScreen
import com.lpav.market.ui.packagedetail.PackageDetailScreen
import com.lpav.market.ui.notifications.NotificationsScreen
import com.lpav.market.ui.wallet.WalletScreen
import com.lpav.market.ui.profile.AgencyProfileScreen

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
                HomeScreen(
                    onPackageClick = { packageId -> navController.navigate("package/$packageId") },
                    onCartClick = { navController.navigate(Screen.Cart.route) },
                    onNotificationsClick = { navController.navigate("notifications") },
                    onAgencyClick = { agencyId -> navController.navigate("agency/$agencyId") },
                    onLogout = { navController.navigate(Screen.Login.route) { popUpTo(Screen.Home.route) { inclusive = true } } }
                )
            }

            composable(Screen.Search.route) {
                HomeScreen(
                    onPackageClick = { packageId -> navController.navigate("package/$packageId") },
                    onCartClick = { navController.navigate(Screen.Cart.route) },
                    onNotificationsClick = { navController.navigate("notifications") },
                    onAgencyClick = { agencyId -> navController.navigate("agency/$agencyId") },
                    onLogout = { navController.navigate(Screen.Login.route) { popUpTo(Screen.Home.route) { inclusive = true } } }
                )
            }

            composable(Screen.Cart.route) {
                CartScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onCheckout = { navController.navigate(Screen.Checkout.route) },
                    onPackageClick = { packageId -> navController.navigate("package/$packageId") }
                )
            }

            composable(Screen.Chat.route) {
                Text("Chat List - TODO")
            }

            composable(Screen.Profile.route) {
                Text("Profile - TODO")
            }

            composable(
                route = "package/{packageId}",
                arguments = listOf(navArgument("packageId") { type = NavType.StringType })
            ) { backStackEntry ->
                val packageId = backStackEntry.arguments?.getString("packageId") ?: ""
                PackageDetailScreen(
                    packageId = packageId,
                    onNavigateBack = { navController.popBackStack() },
                    onAddToCart = { navController.navigate(Screen.Cart.route) },
                    onAgencyClick = { agencyId -> navController.navigate("agency/$agencyId") }
                )
            }

            composable(Screen.Wishlist.route) {
                Text("Wishlist - TODO")
            }

            composable(Screen.Login.route) {
                LoginScreen(
                    onNavigateToRegister = { navController.navigate(Screen.Register.route) },
                    onNavigateToHome = { navController.navigate(Screen.Home.route) { popUpTo(Screen.Login.route) { inclusive = true } } }
                )
            }

            composable(Screen.Register.route) {
                RegisterScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onNavigateToHome = { navController.navigate(Screen.Home.route) { popUpTo(Screen.Register.route) { inclusive = true } } }
                )
            }

            composable(Screen.Onboarding.route) {
                Text("Onboarding - TODO")
            }

            composable(Screen.AgencyAuth.route) {
                Text("Agency Auth - TODO")
            }

            composable(Screen.AgencyRegister.route) {
                Text("Agency Register - TODO")
            }

            composable(Screen.Checkout.route) {
                CheckoutScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onOrderComplete = { navController.navigate(Screen.Orders.route) { popUpTo(Screen.Checkout.route) { inclusive = true } } }
                )
            }

            composable(Screen.Orders.route) {
                OrdersScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onPackageClick = { packageId -> navController.navigate("package/$packageId") }
                )
            }

            composable(Screen.PointsWallet.route) {
                WalletScreen(
                    onNavigateBack = { navController.popBackStack() }
                )
            }

            composable(
                route = "chat/{conversationId}",
                arguments = listOf(navArgument("conversationId") { type = NavType.StringType })
            ) { backStackEntry ->
                val conversationId = backStackEntry.arguments?.getString("conversationId") ?: ""
                ChatScreen(
                    conversationId = conversationId,
                    onNavigateBack = { navController.popBackStack() }
                )
            }

            composable(
                route = "notifications"
            ) {
                NotificationsScreen(
                    onNavigateBack = { navController.popBackStack() }
                )
            }

            composable(
                route = "agency/{agencyId}",
                arguments = listOf(navArgument("agencyId") { type = NavType.StringType })
            ) { backStackEntry ->
                val agencyId = backStackEntry.arguments?.getString("agencyId") ?: ""
                AgencyProfileScreen(
                    agencyId = agencyId,
                    onNavigateBack = { navController.popBackStack() },
                    onPackageClick = { packageId -> navController.navigate("package/$packageId") }
                )
            }
        }
    }
}
