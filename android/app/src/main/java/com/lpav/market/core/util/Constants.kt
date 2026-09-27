package com.lpav.market.core.util

object Constants {
    const val DATASTORE_NAME = "lpav_market_prefs"
    const val CART_KEY = "guest_cart"
    const val WISHLIST_KEY = "wishlist_ids"
    const val USER_ID_KEY = "user_id"
    const val TOKEN_KEY = "jwt_token"
    const val REFRESH_TOKEN_KEY = "refresh_token"
    const val ONBOARDING_COMPLETED_KEY = "onboarding_completed"
    const val THEME_MODE_KEY = "theme_mode"
    const val AGENCY_MODE_KEY = "is_agency_mode"

    const val PAGE_SIZE = 20
    const val MAX_CART_ITEMS = 99
    const val MAX_IMAGE_SIZE_MB = 10
    const val CHAT_PAGE_LIMIT = 50

    const val PACKAGES_TABLE = "packages"
    const val LEADS_TABLE = "crm_leads"
    const val ORDERS_TABLE = "orders"
    const val PROFILES_TABLE = "profiles"
    const val CHAT_MESSAGES_TABLE = "chat_messages"
    const val CONVERSATIONS_TABLE = "conversations"
    const val REVIEWS_TABLE = "reviews"
    const val NOTIFICATIONS_TABLE = "notifications"
    const val TENANTS_TABLE = "tenants"

    const val AVIMO_SCHEME = "avimo://"
    const val DEEP_LINK_PACKAGE = "avimo://package/"
    const val DEEP_LINK_ORDER = "avimo://order/"
    const val DEEP_LINK_CHAT = "avimo://chat/"

    const val ERROR_NETWORK = "Error de conexión"
    const val ERROR_UNAUTHORIZED = "Sesión expirada"
    const val ERROR_SERVER = "Error del servidor"
    const val ERROR_UNKNOWN = "Error inesperado"
}
