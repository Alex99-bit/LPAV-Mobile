# API Contracts

All backend logic runs as Supabase Edge Functions. This document specifies every HTTP contract the mobile client must implement.

## Common Headers

Every authenticated request must include:

```
Authorization: Bearer {access_token}
apikey: {SUPABASE_ANON_KEY}
Content-Type: application/json
```

## Base URL Patterns

| Pattern | Usage |
|---------|-------|
| `{SUPABASE_URL}/rest/v1/{table}` | Supabase REST (PostgREST) |
| `{SUPABASE_URL}/functions/v1/{function}` | Edge Function invocation |

---

## 1. create-checkout

**Method:** POST  
**Auth:** JWT required  
**URL:** `{SUPABASE_URL}/functions/v1/create-checkout`

Creates a Stripe Checkout Session for a travel package purchase.

### Request Body

```json
{
  "package_id": "uuid-string",
  "deposit_percent": 0.25,
  "points_to_redeem": 500
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `package_id` | string (uuid) | Yes | The travel package to purchase |
| `deposit_percent` | number | No | Fraction of total to pay upfront. Must be >= 0.2. Defaults to MIN_DEPOSIT_PERCENTAGE |
| `points_to_redeem` | integer | No | Wallet points to apply as discount. Must be >= 200 and <= MAX_POINTS_PERCENT_PER_PURCHASE of total |

### Success Response — 200

```json
{
  "id": "checkout_session_id_string",
  "url": "https://checkout.stripe.com/pay/cs_...",
  "amount_total": 12500.00,
  "currency": "MXN",
  "platform_fee": 2500.00,
  "agency_commission": 2250.00,
  "commission_rate": 0.18,
  "hold_id": "hold_uuid_or_null",
  "points_redeemed": 500
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Stripe Checkout Session ID |
| `url` | string | Redirect URL for the customer to complete payment |
| `amount_total` | number | Total amount charged to customer (after points deduction) |
| `currency` | string | ISO 4217 currency code |
| `platform_fee` | number | Platform's share of the transaction |
| `agency_commission` | number | Agency's commission amount |
| `commission_rate` | number | Applied commission rate (decimal) |
| `hold_id` | string \| null | Room hold ID if inventory was reserved |
| `points_redeemed` | integer \| null | Points actually redeemed (may differ from requested) |

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_PACKAGE` | Package does not exist or is not published |
| 400 | `INSUFFICIENT_ROOMS` | No available rooms for the package |
| 400 | `INVALID_DEPOSIT` | deposit_percent < MIN_DEPOSIT_PERCENTAGE |
| 400 | `INVALID_POINTS` | points_to_redeem < MIN_REDEEM_POINTS or exceeds max allowed |
| 400 | `INSUFFICIENT_WALLET` | User has fewer points than requested |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 429 | `RATE_LIMITED` | Too many checkout attempts |

---

## 2. create-lead

**Method:** POST  
**Auth:** JWT required  
**URL:** `{SUPABASE_URL}/functions/v1/create-lead`

Creates a new lead record and assigns it to an available agent within the tenant.

### Request Body

```json
{
  "package_id": "uuid-string"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `package_id` | string (uuid) | Yes | The travel package the lead is interested in |

### Success Response — 200

```json
{
  "lead_id": "lead_uuid",
  "conversation_id": "conversation_uuid",
  "assigned_to": "agent_user_uuid"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `lead_id` | string | The created lead record ID |
| `conversation_id` | string | The chat conversation linked to this lead |
| `assigned_to` | string | The user ID of the assigned agent |

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_PACKAGE` | Package does not exist or is not published |
| 400 | `NO_AGENTS_AVAILABLE` | No agents available in the tenant |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 409 | `DUPLICATE_LEAD` | User already has an active lead for this package |

---

## 3. generate-itinerary

**Method:** POST  
**Auth:** JWT required  
**URL:** `{SUPABASE_URL}/functions/v1/generate-itinerary`

Generates a structured day-by-day itinerary for a travel package.

### Request Body

```json
{
  "package_id": "uuid-string",
  "cluster_interests_hash": "caribbean_adventure_v2"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `package_id` | string (uuid) | Yes | The travel package to generate an itinerary for |
| `cluster_interests_hash` | string | No | Hash of the user's interest cluster for personalized suggestions |

### Success Response — 200

```json
{
  "title": "Caribe Mexicano 7 Noches",
  "totalDays": 7,
  "description": "Disfruta de las playas del Caribe Mexicano...",
  "days": [
    {
      "dayNumber": 1,
      "title": "Llegada y Bienvenida",
      "activities": [
        {
          "time": "14:00",
          "description": "Check-in en el hotel",
          "location": "Resort Paradise, Cancún"
        },
        {
          "time": "18:00",
          "description": "Cóctel de bienvenida en la terraza",
          "location": "Terraza Principal"
        }
      ]
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Itinerary title |
| `totalDays` | integer | Number of days in the itinerary |
| `description` | string \| null | Overview description |
| `days` | array | Ordered list of day objects |
| `days[].dayNumber` | integer | Day number (1-indexed) |
| `days[].title` | string | Day title |
| `days[].activities` | array | Activities for this day |
| `days[].activities[].time` | string | Time of activity (HH:mm) |
| `days[].activities[].description` | string | Activity description |
| `days[].activities[].location` | string \| null | Activity location |

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_PACKAGE` | Package does not exist |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 500 | `GENERATION_FAILED` | Itinerary generation failed |

---

## 4. ai-qualify-lead

**Method:** POST  
**Auth:** JWT required (non-Basico agency only)  
**URL:** `{SUPABASE_URL}/functions/v1/ai-qualify-lead`

AI-powered lead qualification. Extracts structured fields from conversation messages and determines whether to transfer to a human agent.

### Request Body

```json
{
  "lead_id": "lead_uuid",
  "conversation_id": "conversation_uuid",
  "latest_message": "Quiero un paquete para 4 personas, presupuesto de 20,000 MXN, que salga de CDMX en diciembre"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `lead_id` | string (uuid) | Yes | The lead to qualify |
| `conversation_id` | string (uuid) | Yes | The conversation context |
| `latest_message` | string | Yes | The latest message from the customer |

### Success Response — 200

```json
{
  "reply": "¡Hola! He detectado que buscas un paquete para 4 personas con presupuesto de $20,000 MXN saliendo de CDMX en diciembre. Déjame buscar opciones para ti...",
  "extracted_fields": {
    "group_size": 4,
    "budget": 20000,
    "departure_city": "CDMX",
    "travel_month": "diciembre",
    "interests": ["playa", "familia"]
  },
  "should_transfer_to_human": false,
  "qualification_completed": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `reply` | string | AI-generated response to the customer |
| `extracted_fields` | object | Structured data extracted from the conversation |
| `should_transfer_to_human` | boolean | Whether the conversation should be escalated |
| `qualification_completed` | boolean | Whether all required qualification fields are filled |

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_LEAD` | Lead does not exist |
| 403 | `PLAN_NOT_SUPPORTED` | Agency is on Basico plan (AI not available) |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 429 | `RATE_LIMITED` | Too many AI qualification attempts |

---

## 5. create-chat-payment

**Method:** POST  
**Auth:** JWT required (agency)  
**URL:** `{SUPABASE_URL}/functions/v1/create-chat-payment`

Creates a Stripe Checkout Session for a payment initiated within a chat conversation (installment or full payment).

### Request Body

```json
{
  "conversation_id": "conversation_uuid",
  "amount": 5000.00,
  "currency": "MXN",
  "concept": "Segundo abono - Paquete Caribe Mexicano",
  "order_id": "order_uuid"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `conversation_id` | string (uuid) | Yes | The conversation where payment was initiated |
| `amount` | number | Yes | Payment amount |
| `currency` | string | No | ISO 4217 code. Defaults to MXN |
| `concept` | string | Yes | Human-readable payment description |
| `order_id` | string (uuid) | No | Related order ID for installment tracking |

### Success Response — 200

```json
{
  "url": "https://checkout.stripe.com/pay/cs_...",
  "stripe_session_id": "cs_...",
  "amount": 5000.00,
  "currency": "MXN",
  "commission_applied": 900.00,
  "commission_rate": 0.18
}
```

| Field | Type | Description |
|-------|------|-------------|
| `url` | string | Stripe Checkout URL |
| `stripe_session_id` | string | Stripe session identifier |
| `amount` | number | Payment amount |
| `currency` | string | Currency code |
| `commission_applied` | number | Platform commission for this payment |
| `commission_rate` | number | Applied commission rate (decimal) |

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_CONVERSATION` | Conversation does not exist or is not accessible |
| 400 | `INVALID_AMOUNT` | Amount is zero or negative |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 403 | `AGENCY_REQUIRED` | User is not an agency member |

---

## 6. manage-subscription

**Method:** POST  
**Auth:** JWT required (Agency_Admin role)  
**URL:** `{SUPABASE_URL}/functions/v1/manage-subscription`

Manages agency subscription plans and billing.

### Request Body — Change Plan

```json
{
  "action": "change_plan",
  "plan": "Premium",
  "billing_cycle": "annual"
}
```

### Request Body — Customer Portal

```json
{
  "action": "portal"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action` | string | Yes | `"change_plan"` or `"portal"` |
| `plan` | string | Conditional | Required when action is `change_plan`. One of: Basico, Intermedio, Premium, Fundador |
| `billing_cycle` | string | No | `"monthly"` or `"annual"`. Defaults to monthly |

### Success Response — change_plan — 200

```json
{
  "url": "https://checkout.stripe.com/pay/cs_...",
  "plan": "Premium",
  "billing_cycle": "annual",
  "previous_plan": "Intermedio"
}
```

### Success Response — portal — 200

```json
{
  "url": "https://billing.stripe.com/p/session/..."
}
```

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_PLAN` | Plan is not a valid option |
| 400 | `INVALID_ACTION` | Action must be change_plan or portal |
| 403 | `ADMIN_REQUIRED` | User is not an Agency_Admin |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 500 | `STRIPE_ERROR` | Stripe API error |

---

## 7. presigned-url

**Method:** POST  
**Auth:** JWT required (agency)  
**URL:** `{SUPABASE_URL}/functions/v1/presigned-url`

Generates a presigned URL for uploading files to Supabase Storage.

### Request Body

```json
{
  "filename": "flyer_paquete_caribe.pdf"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `filename` | string | Yes | Original filename including extension |

### Success Response — 200

```json
{
  "signedUrl": "https://your-project.supabase.co/storage/v1/object/sign/flyers/...",
  "path": "flyers/tenant_abc/flyer_paquete_caribe_20260909.pdf"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `signedUrl` | string | Pre-signed upload URL (PUT) |
| `path` | string | Storage path where the file will be stored |

### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `INVALID_FILENAME` | Filename is empty or contains invalid characters |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 403 | `AGENCY_REQUIRED` | User is not an agency member |
| 413 | `FILE_TOO_LARGE` | File exceeds storage limits |

---

## Supabase REST API Pattern

For direct table operations (reads, inserts, updates, deletes) without Edge Functions:

```
GET    {SUPABASE_URL}/rest/v1/{table}?select=*&column=eq.value
POST   {SUPABASE_URL}/rest/v1/{table}
PATCH  {SUPABASE_URL}/rest/v1/{table}?id=eq.value
DELETE {SUPABASE_URL}/rest/v1/{table}?id=eq.value
```

### Required Headers

```
apikey: {SUPABASE_ANON_KEY}
Authorization: Bearer {access_token}
Content-Type: application/json
Prefer: return=representation
```

### Query Parameters

| Parameter | Example | Description |
|-----------|---------|-------------|
| `select` | `select=id,name,price` | Columns to return |
| `eq` | `?id=eq.uuid` | Equals filter |
| `gt` | `?price=gt.1000` | Greater than |
| `lt` | `?price=lt.5000` | Less than |
| `gte` | `?rating=gte.4` | Greater than or equal |
| `lte` | `?rating=lte.5` | Less than or equal |
| `order` | `order=created_at.desc` | Sort order |
| `limit` | `limit=20` | Row limit |
| `offset` | `offset=40` | Row offset for pagination |

---

## Edge Function Call Pattern

```
POST {SUPABASE_URL}/functions/v1/{function_name}
```

### Required Headers

```
apikey: {SUPABASE_ANON_KEY}
Authorization: Bearer {access_token}
Content-Type: application/json
```

The Supabase client libraries handle these headers automatically when using `supabase.functions.invoke()`.
