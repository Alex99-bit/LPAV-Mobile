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

## Loyalty Points System

| Constant | Value | Description |
|----------|-------|-------------|
| `POINTS_PER_100_MXN` | `1` | Points earned per 100 MXN spent |
| `POINT_VALUE_MXN` | `1` | Each point is worth 1 MXN when redeemed |
| `MIN_REDEEM_POINTS` | `200` | Minimum points required to redeem |
| `MAX_POINTS_PERCENT_PER_PURCHASE` | `0.20` | Max 20% of purchase total can be paid with points |
| `MAX_WALLET_BALANCE` | `15000` | Maximum points that can be held in wallet |
| `WELCOME_BONUS_POINTS` | `5` | Points credited on account creation |

### Points Earning Rules

- Points are earned on the `package_subtotal + package_iva` amount (gross before platform fee)
- Points are calculated as: `floor((package_subtotal + package_iva) / 100) * POINTS_PER_100_MXN`
- Points are credited when `payment_status` changes to `paid`
- Points are NOT earned on deposit-only payments; only on full payment

### Points Redemption Rules

- Minimum redemption: `MIN_REDEEM_POINTS` (200 points)
- Maximum redemption per purchase: `MAX_POINTS_PERCENT_PER_PURCHASE` (20%) of total amount
- Points are deducted from wallet at checkout creation
- If checkout fails or is abandoned, points are reversed
- Points have no expiration date

### Wallet Balance Rules

- Balance cannot exceed `MAX_WALLET_BALANCE` (15,000 points)
- Earning beyond the cap is silently capped
- Welcome bonus is exempt from the cap for the initial credit

### Points Transaction Types

| Type | Description | Points Effect |
|------|-------------|---------------|
| `earn` | Purchase completion | Positive |
| `redeem` | Points applied at checkout | Negative |
| `reversal` | Refund or failed checkout | Positive (restores) |
| `bonus` | Promotional or welcome | Positive |
| `referral` | Referral program reward | Positive |
| `review` | Review submission reward | Positive |

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

| Plan | Price (Monthly) | Price (Annual) | Features |
|------|-----------------|----------------|----------|
| Basico | $499 MXN | $4,990 MXN | Basic listing, manual lead management |
| Intermedio | $999 MXN | $9,990 MXN | AI qualification, chat, analytics |
| Premium | $1,999 MXN | $19,990 MXN | Priority placement, advanced AI, dedicated support |
| Fundador | Custom | Custom | White-label, API access, custom integrations |

### Plan Feature Matrix

| Feature | Basico | Intermedio | Premium | Fundador |
|---------|--------|------------|---------|----------|
| Package listings | 20 | 100 | Unlimited | Unlimited |
| AI lead qualification | No | Yes | Yes | Yes |
| Chat with customers | No | Yes | Yes | Yes |
| Analytics dashboard | Basic | Advanced | Advanced | Custom |
| Priority search ranking | No | No | Yes | Yes |
| Dedicated support | No | No | Yes | Yes |
| White-label | No | No | No | Yes |
| API access | No | No | No | Yes |

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
- User earns bonus points for approved reviews
