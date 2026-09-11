package com.lpav.market.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.Chat
import androidx.compose.material.icons.outlined.Explore
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.ShoppingCart
import androidx.compose.material.icons.outlined.Star
import androidx.compose.ui.graphics.vector.ImageVector

sealed class Screen(
    val route: String,
    val title: String = "",
    val selectedIcon: ImageVector? = null,
    val unselectedIcon: ImageVector? = null
) {
    data object Home : Screen("home", "Inicio", Icons.Filled.Home, Icons.Outlined.Home)
    data object Search : Screen("search", "Explorar", Icons.Filled.Explore, Icons.Outlined.Explore)
    data object Cart : Screen("cart", "Carrito", Icons.Filled.ShoppingCart, Icons.Outlined.ShoppingCart)
    data object Chat : Screen("chat", "Chat", Icons.Filled.Chat, Icons.Outlined.Chat)
    data object Profile : Screen("profile", "Perfil", Icons.Filled.Person, Icons.Outlined.Person)

    data object PackageDetail : Screen("package/{packageId}", "Detalle")
    data object Itinerary : Screen("package/{packageId}/itinerary", "Itinerario")
    data object Wishlist : Screen("wishlist", "Favoritos", Icons.Filled.Star, Icons.Outlined.Star)
    data object Login : Screen("login", "Iniciar Sesión")
    data object Register : Screen("register", "Registrarse")
    data object AgencyAuth : Screen("agency/auth", "Acceso Agencia")
    data object AgencyRegister : Screen("agency/register", "Registro Agencia")
    data object Onboarding : Screen("onboarding", "Bienvenido")
    data object Checkout : Screen("checkout", "Pagar")
    data object Orders : Screen("orders", "Pedidos")
    data object PointsWallet : Screen("wallet", "Billetera")

    data object AgencyDashboard : Screen("agency/dashboard", "Dashboard")
    data object AgencyFlyers : Screen("agency/flyers", "Flyers")
    data object AgencyCRM : Screen("agency/crm", "CRM")
    data object AgencyFinance : Screen("agency/finance", "Finanzas")
    data object AgencyLogistics : Screen("agency/logistics", "Logística")
    data object AgencySettings : Screen("agency/settings", "Configuración")

    data object ChatDetail : Screen("chat/{conversationId}", "Conversación")

    companion object {
        val bottomNavItems = listOf(Home, Search, Cart, Chat, Profile)
    }
}
