package com.lpav.market.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.lpav.market.ui.auth.LoginScreen
import com.lpav.market.ui.auth.RegisterScreen
import com.lpav.market.ui.home.HomeScreen
import com.lpav.market.ui.packagedetail.PackageDetailScreen
import com.lpav.market.ui.cart.CartScreen
import com.lpav.market.ui.checkout.CheckoutScreen
import com.lpav.market.ui.orders.OrdersScreen
import com.lpav.market.ui.wallet.WalletScreen
import com.lpav.market.ui.chat.ChatScreen
import com.lpav.market.ui.profile.AgencyProfileScreen
import com.lpav.market.ui.notifications.NotificationsScreen

object Routes {
    const val LOGIN = "login"
    const val REGISTER = "register"
    const val HOME = "home"
    const val PACKAGE_DETAIL = "package_detail/{packageId}"
    const val CART = "cart"
    const val CHECKOUT = "checkout"
    const val ORDERS = "orders"
    const val WALLET = "wallet"
    const val CHAT = "chat/{conversationId}"
    const val AGENCY_PROFILE = "agency_profile/{agencyId}"
    const val NOTIFICATIONS = "notifications"

    fun packageDetail(packageId: String) = "package_detail/$packageId"
    fun chat(conversationId: String) = "chat/$conversationId"
    fun agencyProfile(agencyId: String) = "agency_profile/$agencyId"
}

@Composable
fun LPAVNavGraph(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = Routes.LOGIN
    ) {
        composable(Routes.LOGIN) {
            LoginScreen(
                onNavigateToRegister = { navController.navigate(Routes.REGISTER) },
                onNavigateToHome = {
                    navController.navigate(Routes.HOME) {
                        popUpTo(Routes.LOGIN) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.REGISTER) {
            RegisterScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToHome = {
                    navController.navigate(Routes.HOME) {
                        popUpTo(Routes.LOGIN) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.HOME) {
            HomeScreen(
                onPackageClick = { packageId ->
                    navController.navigate(Routes.packageDetail(packageId))
                },
                onCartClick = { navController.navigate(Routes.CART) },
                onNotificationsClick = { navController.navigate(Routes.NOTIFICATIONS) },
                onAgencyClick = { agencyId ->
                    navController.navigate(Routes.agencyProfile(agencyId))
                },
                onLogout = {
                    navController.navigate(Routes.LOGIN) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }

        composable(
            route = Routes.PACKAGE_DETAIL,
            arguments = listOf(navArgument("packageId") { type = NavType.StringType })
        ) { backStackEntry ->
            val packageId = backStackEntry.arguments?.getString("packageId") ?: ""
            PackageDetailScreen(
                packageId = packageId,
                onNavigateBack = { navController.popBackStack() },
                onAddToCart = { navController.navigate(Routes.CART) },
                onAgencyClick = { agencyId ->
                    navController.navigate(Routes.agencyProfile(agencyId))
                }
            )
        }

        composable(Routes.CART) {
            CartScreen(
                onNavigateBack = { navController.popBackStack() },
                onCheckout = { navController.navigate(Routes.CHECKOUT) },
                onPackageClick = { packageId ->
                    navController.navigate(Routes.packageDetail(packageId))
                }
            )
        }

        composable(Routes.CHECKOUT) {
            CheckoutScreen(
                onNavigateBack = { navController.popBackStack() },
                onOrderComplete = {
                    navController.navigate(Routes.ORDERS) {
                        popUpTo(Routes.HOME)
                    }
                }
            )
        }

        composable(Routes.ORDERS) {
            OrdersScreen(
                onNavigateBack = { navController.popBackStack() },
                onPackageClick = { packageId ->
                    navController.navigate(Routes.packageDetail(packageId))
                }
            )
        }

        composable(Routes.WALLET) {
            WalletScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(
            route = Routes.CHAT,
            arguments = listOf(navArgument("conversationId") { type = NavType.StringType })
        ) { backStackEntry ->
            val conversationId = backStackEntry.arguments?.getString("conversationId") ?: ""
            ChatScreen(
                conversationId = conversationId,
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(
            route = Routes.AGENCY_PROFILE,
            arguments = listOf(navArgument("agencyId") { type = NavType.StringType })
        ) { backStackEntry ->
            val agencyId = backStackEntry.arguments?.getString("agencyId") ?: ""
            AgencyProfileScreen(
                agencyId = agencyId,
                onNavigateBack = { navController.popBackStack() },
                onPackageClick = { packageId ->
                    navController.navigate(Routes.packageDetail(packageId))
                }
            )
        }

        composable(Routes.NOTIFICATIONS) {
            NotificationsScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
