package com.lpav.market.core.util

import android.content.Context
import android.content.Intent
import android.net.Uri
import java.text.NumberFormat
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

fun String.toSlug(): String = lowercase()
    .replace(Regex("[^a-z0-9]+"), "-")
    .trim('-')

fun Double.formatCurrency(currency: String = "USD"): String {
    return try {
        val formatter = NumberFormat.getCurrencyInstance(Locale.US)
        formatter.currency = java.util.Currency.getInstance(currency)
        formatter.format(this)
    } catch (e: Exception) {
        "$${String.format("%.2f", this)}"
    }
}

fun Long.formatCurrency(currency: String = "USD"): String = toDouble().formatCurrency(currency)

fun String.toLocalDateTime(): LocalDateTime? {
    return try {
        val instant = Instant.parse(this)
        LocalDateTime.ofInstant(instant, ZoneId.systemDefault())
    } catch (e: Exception) {
        try {
            LocalDateTime.parse(this, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        } catch (e2: Exception) {
            null
        }
    }
}

fun LocalDateTime.formatDisplay(): String {
    val formatter = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.getDefault())
    return format(formatter)
}

fun LocalDateTime.formatFull(): String {
    val formatter = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm", Locale.getDefault())
    return format(formatter)
}

fun String.isValidEmail(): Boolean {
    return matches(Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"))
}

fun String.maskEmail(): String {
    val parts = split("@")
    if (parts.size != 2) return this
    val name = parts[0]
    return if (name.length <= 2) {
        "${name[0]}***@${parts[1]}"
    } else {
        "${name.take(2)}***@${parts[1]}"
    }
}

fun Context.openUrl(url: String) {
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    startActivity(intent)
}

fun Int.formatPoints(): String {
    val formatter = NumberFormat.getNumberInstance(Locale.US)
    return formatter.format(this)
}

sealed class Resource<out T> {
    data object Loading : Resource<Nothing>()
    data class Success<T>(val data: T) : Resource<T>()
    data class Error(val message: String, val code: Int = -1) : Resource<Nothing>()
}
