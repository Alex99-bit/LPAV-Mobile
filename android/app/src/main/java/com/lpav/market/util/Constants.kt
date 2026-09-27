package com.lpav.market.util

object Constants {
    const val TABLE_PROFILES = "profiles"
    const val TABLE_PACKAGES = "travel_packages"
    const val TABLE_ORDERS = "transaction_orders"
    const val TABLE_CART = "cart_items"
    const val TABLE_CHAT_MESSAGES = "chat_messages"
    const val TABLE_NOTIFICATIONS = "notifications"
    const val TABLE_INSTALLMENTS = "installment_schedules"
    const val TABLE_REVIEWS = "package_reviews"
    const val TABLE_AGENCIES = "agency_tenants"
    const val TABLE_CONVERSATIONS = "conversations"

    const val FUNCTION_PROCESS_CHECKOUT = "process-checkout"
    const val FUNCTION_CALCULATE_INSTALLMENTS = "calculate-installments"
    const val FUNCTION_CONFIRM_PAYMENT = "confirm-payment"
    const val FUNCTION_CHAT_REPLY = "chat-reply"

    const val CHANNEL_ORDERS = "orders-updates"
    const val CHANNEL_CHAT = "chat-messages"
    const val CHANNEL_NOTIFICATIONS = "notifications-updates"

    const val IVA_RATE = 0.16
    const val DEPOSIT_RATIO = 0.30

    const val STRIPE_PUBLISHABLE_KEY = ""

    const val DATE_FORMAT = "dd/MM/yyyy"
    const val DATETIME_FORMAT = "dd/MM/yyyy HH:mm"

    const val PAGINATION_LIMIT = 20

    const val SPLASH_TIMEOUT = 2000L
}
