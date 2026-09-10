package com.lpav.market.core.storage

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.lpav.market.core.model.CartItem
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.cartDataStore: DataStore<Preferences> by preferencesDataStore(name = "cart")

@Singleton
class CartStorage @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val gson = Gson()
    private val cartKey = stringPreferencesKey("cart_items")
    private val cartCountKey = intPreferencesKey("cart_count")

    suspend fun getCartItems(): List<CartItem> {
        val json = context.cartDataStore.data.map { prefs -> prefs[cartKey] ?: "[]" }.first()
        return try {
            val type = object : TypeToken<List<CartItem>>() {}.type
            gson.fromJson(json, type) ?: emptyList()
        } catch (_: Exception) {
            emptyList()
        }
    }

    suspend fun saveCartItems(items: List<CartItem>) {
        val json = gson.toJson(items)
        context.cartDataStore.edit { prefs ->
            prefs[cartKey] = json
            prefs[cartCountKey] = items.size
        }
    }

    suspend fun addToCart(item: CartItem) {
        val items = getCartItems().toMutableList()
        val existingIndex = items.indexOfFirst { it.packageId == item.packageId }
        if (existingIndex >= 0) {
            val existing = items[existingIndex]
            items[existingIndex] = existing.copy(quantity = existing.quantity + item.quantity)
        } else {
            items.add(item)
        }
        saveCartItems(items)
    }

    suspend fun removeFromCart(packageId: String) {
        val items = getCartItems().filter { it.packageId != packageId }
        saveCartItems(items)
    }

    suspend fun updateQuantity(packageId: String, quantity: Int) {
        if (quantity <= 0) {
            removeFromCart(packageId)
            return
        }
        val items = getCartItems().toMutableList()
        val index = items.indexOfFirst { it.packageId == packageId }
        if (index >= 0) {
            items[index] = items[index].copy(quantity = quantity)
            saveCartItems(items)
        }
    }

    suspend fun clearCart() {
        saveCartItems(emptyList())
    }

    suspend fun getCartCount(): Int {
        return getCartItems().sumOf { it.quantity }
    }
}
