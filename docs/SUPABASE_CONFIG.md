# Supabase Configuration

Reference for all Supabase project configuration used by LPAV-Mobile.

---

## Environment Variables

These placeholders must be replaced with actual values from your Supabase project dashboard.

| Variable | Description | Location |
|----------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Project Settings → API |
| `SUPABASE_ANON_KEY` | Public anonymous key | Project Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Admin key (backend only, never in client) | Project Settings → API |
| `SUPABASE_JWT_SECRET` | JWT secret for token verification | Project Settings → API |

### iOS Configuration

Add to your Xcode project or `.xcconfig` file:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Android Configuration

Add to `local.properties` or `gradle.properties`:

```properties
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> Never commit real keys to version control. Use `.gitignore` and environment-specific config.

---

## Storage Buckets

### flyers

| Property | Value |
|----------|-------|
| Name | `flyers` |
| Access | Private |
| Public Read | Yes (via signed URLs) |
| File Size Limit | 10 MB |
| Allowed MIME Types | `application/pdf`, `image/jpeg`, `image/png`, `image/webp` |
| Path Structure | `{tenant_id}/{filename}` |

**Usage:** Travel package flyers and thumbnails uploaded by agency members.

### fiscal-documents

| Property | Value |
|----------|-------|
| Name | `fiscal-documents` |
| Access | Private |
| Public Read | No |
| File Size Limit | 5 MB |
| Allowed MIME Types | `application/pdf`, `image/jpeg`, `image/png` |
| Path Structure | `{tenant_id}/{user_id}/{filename}` |

**Usage:** RFC documents, invoices, and fiscal compliance files. Only accessible by the owning agency.

### Storage Policies

```sql
-- flyers: public read, authenticated write
CREATE POLICY "Public read access for flyers"
ON storage.objects FOR SELECT
USING (bucket_id = 'flyers');

CREATE POLICY "Agency members can upload flyers"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'flyers'
    AND auth.role() = 'authenticated'
);

-- fiscal-documents: owner-only access
CREATE POLICY "Owner read access for fiscal documents"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'fiscal-documents'
    AND auth.uid()::text = (string_to_array(name, '/'))[2]
);

CREATE POLICY "Agency members can upload fiscal documents"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'fiscal-documents'
    AND auth.role() = 'authenticated'
);
```

---

## Realtime Channels

Enable Supabase Realtime for live data updates.

### wallet_updates

| Property | Value |
|----------|-------|
| Channel | `wallet_updates:{user_id}` |
| Table | `wallet_transactions` |
| Event | `INSERT` |
| Filter | `user_id = eq.{current_user_id}` |
| Payload | Full `WalletTransaction` row |

**Usage:** Real-time wallet balance updates when points are earned, redeemed, or reversed.

### chat_messages

| Property | Value |
|----------|-------|
| Channel | `chat:{conversation_id}` |
| Table | `chat_messages` |
| Event | `INSERT` |
| Filter | `conversation_id = eq.{conversation_id}` |
| Payload | Full `ChatMessage` row |

**Usage:** Real-time chat message delivery within a conversation.

### notifications

| Property | Value |
|----------|-------|
| Channel | `notifications:{user_id}` |
| Table | `notifications` |
| Event | `INSERT` |
| Filter | `user_id = eq.{current_user_id}` |
| Payload | Full `Notification` row |

**Usage:** Push notification delivery and in-app notification badge updates.

### crm_leads

| Property | Value |
|----------|-------|
| Channel | `crm_leads:{tenant_id}` |
| Table | `leads` |
| Event | `INSERT`, `UPDATE` |
| Filter | `tenant_id = eq.{current_tenant_id}` |
| Payload | Full `Lead` row |

**Usage:** Real-time lead updates for agency CRM dashboard. Only available to agency members.

### Realtime Subscription Pattern (iOS)

```swift
supabase
    .channel("chat:\(conversationId)")
    .onPostgresChanges(
        event: .insert,
        schema: "public",
        table: "chat_messages",
        filter: PostgresFilter(
            column: "conversation_id",
            operator: .equals,
            value: conversationId
        )
    ) { payload in
        let message = try JSONDecoder().decode(
            ChatMessage.self,
            from: payload.newRecord.data
        )
        await MainActor.run {
            messages.append(message)
        }
    }
    .subscribe()
```

### Realtime Subscription Pattern (Kotlin)

```kotlin
supabase
    .channel("chat:$conversationId")
    .postgresChangeFlow<PostgresAction.Insert>(
        schema = "public",
        table = "chat_messages",
        filter = PostgresFilter(
            column = "conversation_id",
            operator = FilterOperator.EQ,
            value = conversationId
        )
    )
    .map { decodeRow<ChatMessage>(it.record) }
    .onEach { message ->
        _messages.update { it + message }
    }
    .launchIn(scope)
```

---

## Auth Methods

### Email/Password

| Property | Value |
|----------|-------|
| Provider | `email` |
| Confirmation | Email link |
| Password Min Length | 8 characters |
| Rate Limit | 30 attempts per hour per email |

**Flow:**
1. User registers with email and password
2. Confirmation email sent with magic link
3. User clicks link → email confirmed
4. User can now sign in with email/password

### Google OAuth

| Property | Value |
|----------|-------|
| Provider | `google` |
| Scopes | `openid`, `email`, `profile` |
| Button Text | "Continuar con Google" |

**Flow:**
1. User taps "Continuar con Google"
2. System OAuth sheet opens
3. User authenticates with Google
4. Redirect back to app with tokens
5. Profile auto-created from Google data

### Auth Configuration (iOS)

```swift
// Sign in with Email/Password
try await supabase.auth.signIn(
    email: "user@example.com",
    password: "securepassword"
)

// Sign in with Google
try await supabase.auth.signInWith(
    provider: .google,
    redirectTo: URL(string: "lpav://auth/callback")
)

// Sign out
try await supabase.auth.signOut()
```

### Auth Configuration (Kotlin)

```kotlin
// Sign in with Email/Password
supabase.auth.signInWith(Email) {
    email = "user@example.com"
    password = "securepassword"
}

// Sign in with Google
supabase.auth.signInWith(Google) {
    scopes = listOf("openid", "email", "profile")
}

// Sign out
supabase.auth.signOut()
```

### Row Level Security (RLS)

All tables have RLS enabled. Policies ensure:

| Policy | Rule |
|--------|------|
| Users can read own profile | `auth.uid() = id` |
| Users can update own profile | `auth.uid() = id` |
| Agency members read tenant data | `auth.uid() IN (SELECT user_id FROM profiles WHERE tenant_id = X)` |
| Public read for published packages | `publication_status = 'published'` |
| Users read own orders | `auth.uid() = user_id` |
| Users read own wallet | `auth.uid() = user_id` |
| Users read own notifications | `auth.uid() = user_id` |
| Agents read assigned leads | `assigned_to = auth.uid()` |

---

## Edge Functions Deployment

Deploy all Edge Functions from the project root:

```bash
supabase functions deploy create-checkout
supabase functions deploy create-lead
supabase functions deploy generate-itinerary
supabase functions deploy ai-qualify-lead
supabase functions deploy create-chat-payment
supabase functions deploy manage-subscription
supabase functions deploy presigned-url
```

### Function Secrets

Set via Supabase Dashboard → Edge Functions → Secrets:

| Secret | Description |
|--------|-------------|
| `STRIPE_SECRET_KEY` | Stripe API secret key |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret |
| `OPENAI_API_KEY` | OpenAI API key for AI qualification |

### Environment Variables in Functions

Access via `Deno.env.get()`:

```typescript
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const stripeKey = Deno.env.get('STRIPE_SECRET_KEY')!
```
