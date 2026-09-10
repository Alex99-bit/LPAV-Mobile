# LPAV-Mobile

Mobile marketplace for travel packages with integrated CRM, chat, and payments. Built for travel agencies to list, sell, and manage travel experiences.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Mobile Apps                       │
│              iOS (Swift)  ·  Android (Kotlin)         │
├─────────────────────────────────────────────────────┤
│                   Supabase                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │   Auth    │  │   DB     │  │  Edge Functions   │  │
│  │ (JWT+RLS) │  │ (Postgres)│  │  (Deno)          │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Storage  │  │ Realtime │  │  PostgREST API    │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────┤
│              External Services                       │
│         Stripe (Payments)  ·  OpenAI (AI)            │
└─────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| iOS | Swift 5.9+, SwiftUI, iOS 17+ |
| Android | Kotlin, Jetpack Compose, Material 3 |
| Backend | Supabase (PostgreSQL, Edge Functions, Auth, Storage, Realtime) |
| Payments | Stripe Checkout, Stripe Billing |
| AI | OpenAI API (lead qualification) |
| Architecture | MVVM (iOS), MVVM + Clean Architecture (Android) |
| DI | Factory pattern (iOS), Hilt (Android) |
| Networking | Supabase Swift/Kotlin client libraries |

---

## Prerequisites

- **Xcode 15+** (iOS development)
- **Android Studio Hedgehog+** (Android development)
- **CocoaPods** or **Swift Package Manager** (iOS dependencies)
- **Gradle 8.2+** (Android build system)
- **Supabase CLI** (backend deployment)
- **Node.js 18+** (Supabase Edge Functions local dev)
- **Stripe CLI** (local payment testing)
- **Git**

---

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/LPAV-Mobile.git
cd LPAV-Mobile
```

### 2. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your project URL and anon key from Settings → API
3. Run the database migrations (see `supabase/migrations/`)
4. Deploy Edge Functions:

```bash
supabase functions deploy
```

### 3. Set Up Stripe

1. Create a [Stripe account](https://stripe.com)
2. Get your test API keys from the Stripe Dashboard
3. Set Stripe secrets in Supabase:

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
```

4. Create a Stripe webhook pointing to:
   ```
   https://your-project.supabase.co/functions/v1/stripe-webhook
   ```

### 4. iOS Setup

```bash
cd ios
pod install
# or if using SPM, open .xcodeproj directly
```

Create `ios/Config/Debug.xcconfig`:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Open `LPAV-Mobile.xcworkspace` in Xcode.

### 5. Android Setup

Create `android/local.properties`:

```properties
sdk.dir=/path/to/android/sdk
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Sync Gradle and build.

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Supabase public anon key | Yes |
| `SUPABASE_SERVICE_ROLE_KEY` | Admin key (backend only) | No |
| `STRIPE_SECRET_KEY` | Stripe API secret key | Backend |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook secret | Backend |
| `OPENAI_API_KEY` | OpenAI API key | Backend |

---

## Folder Structure

```
LPAV-Mobile/
├── ios/                          # iOS Swift project
│   ├── LPAV-Mobile/
│   │   ├── App/                  # App entry point, scene delegate
│   │   ├── Features/             # Feature modules
│   │   │   ├── Auth/             # Login, register, onboarding
│   │   │   ├── Catalog/          # Package browsing, search, filters
│   │   │   ├── PackageDetail/    # Package detail, itinerary, reviews
│   │   │   ├── Checkout/         # Payment flow, Stripe integration
│   │   │   ├── Orders/           # Order history, installment tracking
│   │   │   ├── Chat/             # Real-time messaging
│   │   │   ├── Wallet/           # Points balance, transaction history
│   │   │   ├── Notifications/    # In-app notifications
│   │   │   ├── Agency/           # Agency dashboard, CRM, analytics
│   │   │   └── Profile/          # User profile, settings
│   │   ├── Core/                 # Shared infrastructure
│   │   │   ├── Network/          # Supabase client, API layer
│   │   │   ├── Auth/             # Auth manager, token handling
│   │   │   ├── Storage/          # File upload, presigned URLs
│   │   │   └── Realtime/         # Realtime subscription manager
│   │   ├── Models/               # Data models, Codable structs
│   │   ├── Components/           # Reusable UI components
│   │   └── Resources/            # Assets, colors, localization
│   ├── Config/                   # XCConfig files
│   └── Podfile / Package.swift
├── android/                      # Android Kotlin project
│   ├── app/
│   │   └── src/main/
│   │       ├── java/             # Kotlin source files
│   │       ├── res/              # Resources
│   │       └── AndroidManifest.xml
│   ├── build.gradle.kts
│   └── gradle.properties
├── supabase/                     # Supabase configuration
│   ├── migrations/               # SQL migrations
│   └── functions/                # Edge Functions
│       ├── create-checkout/
│       ├── create-lead/
│       ├── generate-itinerary/
│       ├── ai-qualify-lead/
│       ├── create-chat-payment/
│       ├── manage-subscription/
│       └── presigned-url/
├── docs/                         # Documentation
│   ├── API_CONTRACTS.md
│   ├── DATABASE_MODELS.md
│   ├── BUSINESS_RULES.md
│   └── SUPABASE_CONFIG.md
└── README.md
```

---

## Documentation

- **[API Contracts](docs/API_CONTRACTS.md)** — All Edge Function HTTP contracts
- **[Database Models](docs/DATABASE_MODELS.md)** — Swift struct representations of all tables
- **[Business Rules](docs/BUSINESS_RULES.md)** — Constants, commission rates, points system, lifecycle rules
- **[Supabase Config](docs/SUPABASE_CONFIG.md)** — Storage buckets, realtime channels, auth setup

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes following the existing code style
4. Add or update tests as needed
5. Run linting and type checks before committing
6. Submit a pull request with a clear description

### Code Style

- **iOS:** Follow Swift API Design Guidelines. Use `swiftlint` if configured.
- **Android:** Follow Kotlin coding conventions. Use `ktlint` if configured.
- **General:** No secrets in code. Use environment variables for all configuration.

---

## License

Proprietary. All rights reserved.
