package com.lpav.market

import androidx.test.ext.junit.runners.AndroidJUnit4
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import okhttp3.Request
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class BackendIntegrationTest {

    companion object {
        const val SUPABASE_URL = "https://qmcpaqbxbmkhxjezhlch.supabase.co"
        const val ANON_KEY = "sb_publishable_gVbolST77dwQ9n6BpP6YNQ_oTWIiSPt"
    }

    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    @Test
    fun testSupabaseConnection() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/rest/v1/")
            .addHeader("apikey", ANON_KEY)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "Expected 200, 401, or 403 but got ${response.code}",
            response.code in listOf(200, 401, 403)
        )
        response.close()
    }

    @Test
    fun testTravelPackagesTableExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/rest/v1/travel_packages?select=package_id&limit=1")
            .addHeader("apikey", ANON_KEY)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "travel_packages table should exist. Got status ${response.code}",
            response.code in listOf(200, 401, 403, 406)
        )
        response.close()
    }

    @Test
    fun testAgenciesTenantsTableExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/rest/v1/agencies_tenants?select=tenant_id&limit=1")
            .addHeader("apikey", ANON_KEY)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "agencies_tenants table should exist. Got status ${response.code}",
            response.code in listOf(200, 401, 403, 406)
        )
        response.close()
    }

    @Test
    fun testTransactionsOrdersTableExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/rest/v1/transactions_orders?select=order_id&limit=1")
            .addHeader("apikey", ANON_KEY)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "transactions_orders table should exist. Got status ${response.code}",
            response.code in listOf(200, 401, 403, 406)
        )
        response.close()
    }

    @Test
    fun testChatMessagesTableExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/rest/v1/chat_messages?select=message_id&limit=1")
            .addHeader("apikey", ANON_KEY)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "chat_messages table should exist. Got status ${response.code}",
            response.code in listOf(200, 401, 403, 406)
        )
        response.close()
    }

    @Test
    fun testCRMLeadsTableExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/rest/v1/crm_leads?select=lead_id&limit=1")
            .addHeader("apikey", ANON_KEY)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "crm_leads table should exist. Got status ${response.code}",
            response.code in listOf(200, 401, 403, 406)
        )
        response.close()
    }

    @Test
    fun testEdgeFunctionCreateCheckoutExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/functions/v1/create-checkout")
            .addHeader("apikey", ANON_KEY)
            .method("OPTIONS", null)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "create-checkout function should exist. Got status ${response.code}",
            response.code in listOf(200, 204, 400, 401)
        )
        response.close()
    }

    @Test
    fun testEdgeFunctionGenerateItineraryExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/functions/v1/generate-itinerary")
            .addHeader("apikey", ANON_KEY)
            .method("OPTIONS", null)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "generate-itinerary function should exist. Got status ${response.code}",
            response.code in listOf(200, 204, 400, 401)
        )
        response.close()
    }

    @Test
    fun testEdgeFunctionCreateLeadExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/functions/v1/create-lead")
            .addHeader("apikey", ANON_KEY)
            .method("OPTIONS", null)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "create-lead function should exist. Got status ${response.code}",
            response.code in listOf(200, 204, 400, 401)
        )
        response.close()
    }

    @Test
    fun testEdgeFunctionAIQualifyLeadExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/functions/v1/ai-qualify-lead")
            .addHeader("apikey", ANON_KEY)
            .method("OPTIONS", null)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "ai-qualify-lead function should exist. Got status ${response.code}",
            response.code in listOf(200, 204, 400, 401)
        )
        response.close()
    }

    @Test
    fun testEdgeFunctionPresignedUrlExists() = runBlocking {
        val request = Request.Builder()
            .url("$SUPABASE_URL/functions/v1/presigned-url")
            .addHeader("apikey", ANON_KEY)
            .method("OPTIONS", null)
            .build()

        val response = client.newCall(request).execute()
        assertTrue(
            "presigned-url function should exist. Got status ${response.code}",
            response.code in listOf(200, 204, 400, 401)
        )
        response.close()
    }
}
