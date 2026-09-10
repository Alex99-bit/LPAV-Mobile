package com.lpav.market.core.di

import android.content.Context
import com.lpav.market.core.auth.AuthManager
import com.lpav.market.core.network.SupabaseModule
import com.lpav.market.core.storage.CartStorage
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import io.github.jan.supabase.SupabaseClient
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideSupabaseClient(): SupabaseClient = SupabaseModule.client

    @Provides
    @Singleton
    fun provideAuthManager(): AuthManager = AuthManager()

    @Provides
    @Singleton
    fun provideCartStorage(
        @ApplicationContext context: Context
    ): CartStorage = CartStorage(context)
}
