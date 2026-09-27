# Business Rules

All business constants enforced by both the backend Edge Functions and the iOS client.

---

## Tax

| Constant | Value | Description |
|----------|-------|-------------|
| `IVA_RATE` | `0.16` | 16% Mexican IVA tax applied to package prices |

---

## Commission Rates

Commission is calculated on `package_subtotal + package_iva` (gross amount).

### Standard Rates by Plan

| Plan | Rate | Effective Multiplier |
|------|------|---------------------|
| Basico | 20% | 0.20 |
| Intermedio | 18% | 0.18 |
| Premium | 15% | 0.15 |
| Fundador | 7.5% | 0.075 |

### Preferential Rates

When an agency meets conversion thresholds, lower rates apply:

| Plan | Preferential Rate | Minimum Conversion |
|------|------------------|--------------------|
| Intermedio | 17% | >= 5% (5 qualified leads per 100 inquiries) |
| Premium | 12% | >= 8% (8 qualified leads per 100 inquiries) |

> Basico and Fundador do not have preferential rates.

---

## Deposits and Installments

| Constant | Value | Description |
|----------|-------|-------------|
| `MIN_DEPOSIT_PERCENTAGE` | `0.20` | Minimum 20% upfront payment required |
| `MAX_DEFERRED_MONTHS` | `4` | Maximum number of monthly installments |
| `GRACE_PERIOD_DAYS` | `15` | Days after due date before marking installment as overdue |

### Deposit Rules

- Deposit must be >= `MIN_DEPOSIT_PERCENTAGE` of total
- Remaining balance can be split into up to `MAX_DEFERRED_MONTHS` equal installments
- Each installment gets its own Stripe Checkout Session
- Installments are due monthly from the checkout date
- After `GRACE_PERIOD_DAYS` past due, installment status changes to `overdue`
- If any installment is overdue, remaining installments are also marked `overdue`

---

## Content Moderation

| Constant | Value | Description |
|----------|-------|-------------|
| `MAX_CENSORSHIP_STRIKES` | `5` | Strikes before account suspension |

### Moderation Rules

- Each confirmed violation adds 1 strike to the user's `censorship_strikes`
- At `MAX_CENSORSHIP_STRIKES` (5), the account is automatically suspended
- Strikes are permanent and non-reversible without admin intervention
- Applies to: chat messages, package reviews, profile content

---

## Region Catalog

Valid values for `TravelPackage.region`:

| Code | Display Name |
|------|-------------|
| `caribe_mexicano` | Caribe Mexicano |
| `riviera_maya` | Riviera Maya |
| `los_cabos` | Los Cabos |
| `puerto_vallarta` | Puerto Vallarta |
| `ciudad_de_mexico` | Ciudad de Mexico |
| `oaxaca` | Oaxaca |
| `guanajuato` | Guanajuato |
| `yucatan` | Yucatan |
| `quintana_roo` | Quintana Roo |
| `jalisco` | Jalisco |
| `europa` | Europa |
| `sudamerica` | Sudamerica |
| `centroamerica` | Centroamerica |
| `asia` | Asia |
| `africa` | Africa |
| `otro` | Otro |

---

## Departure City Catalog

Valid values for `TravelPackage.departure_city`:

| Code | Display Name |
|------|-------------|
| `CDMX` | Ciudad de Mexico |
| `MTY` | Monterrey |
| `GDL` | Guadalajara |
| `SLP` | San Luis Potosi |
| `CUN` | Cancun |
| `MID` | Merida |
| `TIJ` | Tijuana |
| `PBC` | Puebla |
| `QRO` | Queretaro |
| `BJX` | Leon/Guanajuato |
| `TLC` | Toluca |
| `VER` | Veracruz |
| `VSA` | Villahermosa |
| `HMO` | Hermosillo |
| `CUL` | Culiacan |
| `CUU` | Chihuahua |
| `AGU` | Aguascalientes |
| `MLM` | Morelia |
| `OAX` | Oaxaca |
| `TGZ` | Tuxtla Gutierrez |
| `LAP` | La Paz |
| `PVR` | Puerto Vallarta |
| `SJD` | San Jose del Cabo |
| `Otro` | Otro |

---

## Subscription Plans

> **Nota:** Los precios y límites de planes son definidos por el Dashboard (LPAV-Marketplace-Dashboard) como sistema de registro. Los valores canónicos son:

| Plan | Price (Monthly) | Commission | Features |
|------|-----------------|------------|----------|
| Basico | $0 MXN | 20% (fixed) | 50 flyers, 1 admin, no custom roles |
| Intermedio | $1,799 MXN | 18% (pref. 17%) | 50 flyers, 1 custom role, 3-5 collaborators |
| Premium | $2,999 MXN | 15% (pref. 12%) | 50 flyers, 3 custom roles, unlimited collaborators |
| Fundador | $0 MXN | 7.5% (fixed) | 50 flyers, 3 custom roles, unlimited (10 seats only) |

### Plan Feature Matrix

| Feature | Basico | Intermedio | Premium | Fundador |
|---------|--------|------------|---------|----------|
| Active flyers | 50 | 50 | 50 | 50 |
| Custom roles | 0 | 1 | 3 | 3 |
| Team members | 1 admin | 3-5 | Unlimited | Unlimited |
| AI lead qualification | No | Yes | Yes | Yes |
| Chat with customers | Yes | Yes | Yes | Yes |
| Analytics dashboard | Basic | Standard | Advanced | Advanced |
| Preferential commission | No | >= 5% conversion | >= 8% conversion | No |
| Dedicated support | No | No | 24/7 | 24/7 |

---

## Order Lifecycle

```
Created (pending)
  → Deposit Paid (partial_paid)
    → Installments Paid (partial_paid)
      → Fully Paid (paid)
        → Concluded (after travel date)
  
  → Cancelled (at any point before conclusion)
  
  → Moroso (if any installment overdue past grace period)
```

### Status Transitions

| Current Status | Allowed Next Statuses |
|---------------|----------------------|
| `pending` | `partial_paid`, `cancelled` |
| `partial_paid` | `partial_paid`, `paid`, `moroso`, `cancelled` |
| `paid` | `concluded` |
| `moroso` | `paid`, `cancelled` |
| `cancelled` | (terminal) |

---

## Package Publication Flow

```
draft → pending_review → published → archived
                           ↓
                        concluded
                           ↓
                        (archive automatically after departure + 30 days)
```

### Publication Rules

- Packages start as `draft`
- Agency submits for review → `pending_review`
- Admin approves → `published`
- Admin rejects → returns to `draft` with feedback
- After departure date + 30 days → auto-archived to `concluded`
- Agency can manually archive → `archived`

---

## Room Inventory Rules

- `available_rooms` decrements on successful checkout (payment_status = paid)
- `available_rooms` increments on order cancellation or refund
- Room hold is temporary (expires after 30 minutes)
- If `available_rooms` reaches 0, package cannot be purchased
- `available_rooms` cannot exceed `total_rooms`

---

## Chat Payment Rules

- Only agency members can initiate chat payments
- Payment amount must be > 0
- Commission is calculated on the payment amount using the agency's current rate
- Stripe session expires after 24 hours
- Payment confirmation updates the related order's `remaining_balance`

---

## Lead Assignment Rules

- Leads are assigned round-robin to available agents within the tenant
- Agent must have `Agency_Agent` or `Agency_Admin` role
- If no agents are available, lead is created unassigned
- AI qualification is only available for Intermedio plans and above
- Lead status transitions: new → contacted → qualified → proposal_sent → negotiation → won/lost

---

## Review Rules

- Only users with a completed order (`payment_status = paid`) can leave a review
- One review per order per user
- Rating must be between 1 and 5
- Reviews go through moderation before appearing publicly

---

## Loyalty Points Status (TEMPORARILY DISABLED)

> **Current status (September 2026):** The loyalty points system (Avimo Puntos) is **temporarily disabled** across all platforms (web dashboard, iOS app, and Android app).

### What is disabled:

- **No point earning:** Purchases do not generate loyalty points.
- **No point redemption:** Checkout does not accept or apply points as payment.
- **No wallet UI:** Balance display, transaction history, and redemption controls are removed from all clients.
- **No backend processing:** Edge Functions (`create-checkout`, `stripe-webhook`, `review-package`) do not credit, debit, or reverse points.

### What is preserved:

- Database tables `user_wallets` and `wallet_transactions` remain in Supabase with historical data intact.
- Columns `points_earned` and `points_redeemed` in `transactions_orders` remain defined but receive no writes.
- RPC functions `credit_points`, `debit_points`, `get_or_create_wallet` remain available but are not invoked.
- Historical balances are preserved and will be valid when the system is reactivated.

### Reactivation plan:

When the loyalty program is reactivated, it will follow a phased approach:
1. Define a versioned loyalty policy (`loyalty_policy_version = 1`).
2. Decide treatment of historical balances (remain valid, expire, or require acceptance).
3. No retroactive points for purchases made during the dormant period.
4. Progressive activation: read-only audit → earning only → redemption → bonuses/promotions.
5. Server-side feature flag (`LOYALTY_POINTS_ENABLED`) gates all point operations.

See the master documentation (DOC MAESTRO.md, Section 6.4) for the full reactivation specification.
