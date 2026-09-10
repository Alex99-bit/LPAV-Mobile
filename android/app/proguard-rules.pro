# Add project specific ProGuard rules here.
-keepattributes Signature
-keepattributes *Annotation*

# Supabase
-keep class io.github.jan.supabase.** { *; }
-keep class io.ktor.** { *; }

# Gson
-keepattributes Signature
-keep class com.google.gson.** { *; }
-keep class com.lpav.market.core.model.** { *; }

# Stripe
-keep class com.stripe.** { *; }
