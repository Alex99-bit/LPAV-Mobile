# Database Models

All tables are defined in Supabase (PostgreSQL). Below are the Swift struct representations used by the iOS client. Android equivalents should mirror these structures.

> **Note (September 2026):** The `user_wallets` and `wallet_transactions` tables remain in the Supabase database for schema compatibility and future reactivation of the loyalty points system. Mobile clients must NOT read balances, create transactions, or expose wallet UI while the feature is disabled. The columns `points_earned` and `points_redeemed` on `TransactionOrder` are preserved in the schema but receive no active writes.

---

## Enums

### UserRole

```swift
enum UserRole: String, Codable {
    case endUser = "EndUser"
    case agencyPending = "Agency_Pending"
    case agencyAdmin = "Agency_Admin"
    case agencyAgent = "Agency_Agent"
    case agencyCollaborator = "Agency_Collaborator"
    case superAdmin = "SuperAdmin"
}
```

### Currency

```swift
enum Currency: String, Codable {
    case mxn = "MXN"
    case usd = "USD"
    case eur = "EUR"
}
```

### PublicationStatus

```swift
enum PublicationStatus: String, Codable {
    case draft = "draft"
    case published = "published"
    case archived = "archived"
    case concluded = "concluded"
    case pendingReview = "pending_review"
}
```

### PaymentStatus

```swift
enum PaymentStatus: String, Codable {
    case pending = "pending"
    case partialPaid = "partial_paid"
    case paid = "paid"
    case moroso = "moroso"
    case cancelled = "cancelled"
}
```

### ChatMessageType

```swift
enum ChatMessageType: String, Codable {
    case text = "text"
    case paymentRequest = "payment_request"
    case paymentConfirmed = "payment_confirmed"
}
```

### NotificationType

```swift
enum NotificationType: String, Codable {
    case newMessage = "new_message"
    case paymentReceived = "payment_received"
    case packageReported = "package_reported"
    case packageApproved = "package_approved"
    case packageBanned = "package_banned"
    case orderCancelled = "order_cancelled"
}
```

### PlanType

```swift
enum PlanType: String, Codable {
    case basico = "Basico"
    case intermedio = "Intermedio"
    case premium = "Premium"
    case fundador = "Fundador"
}
```

### ConversationStatus

```swift
enum ConversationStatus: String, Codable {
    case open = "open"
    case pendingResponse = "pending_response"
    case closed = "closed"
}
```

### LeadStatus

```swift
enum LeadStatus: String, Codable {
    case new = "new"
    case contacted = "contacted"
    case qualified = "qualified"
    case proposalSent = "proposal_sent"
    case negotiation = "negotiation"
    case won = "won"
    case lost = "lost"
}
```

### InstallmentStatus

```swift
enum InstallmentStatus: String, Codable {
    case pending = "pending"
    case paid = "paid"
    case overdue = "overdue"
    case cancelled = "cancelled"
}
```

### ReviewStatus

```swift
enum ReviewStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
}
```

### AgencyVerificationStatus

```swift
enum AgencyVerificationStatus: String, Codable {
    case pending = "pending"
    case verified = "verified"
    case rejected = "rejected"
}
```

### AgencyTenantStatus

```swift
enum AgencyTenantStatus: String, Codable {
    case active = "active"
    case suspended = "suspended"
    case cancelled = "cancelled"
}
```

---

## Tables

### Profile

**Table name:** `profiles`

```swift
struct Profile: Codable, Identifiable {
    let id: UUID
    let email: String
    let fullName: String
    let tenantId: UUID?
    let roleName: UserRole
    let avatarUrl: String?
    let phone: String?
    let censorshipStrikes: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case tenantId = "tenant_id"
        case roleName = "role_name"
        case avatarUrl = "avatar_url"
        case phone
        case censorshipStrikes = "censorship_strikes"
        case createdAt = "created_at"
    }
}
```

---

### TravelPackage

**Table name:** `travel_packages`

```swift
struct TravelPackage: Codable, Identifiable {
    let id: UUID // package_id
    let tenantId: UUID
    let title: String
    let region: String
    let price: Double
    let currency: Currency
    let urlFlyerStorage: String?
    let urlThumbnailStorage: String?
    let hasCoordinator: Bool
    let publicationStatus: PublicationStatus
    let departureDate: Date
    let departureCity: String
    let descriptionText: String?
    let totalRooms: Int
    let availableRooms: Int
    let depositPercent: Double
    let maxInstallments: Int
    let itineraryText: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "package_id"
        case tenantId = "tenant_id"
        case title
        case region
        case price
        case currency
        case urlFlyerStorage = "url_flyer_storage"
        case urlThumbnailStorage = "url_thumbnail_storage"
        case hasCoordinator = "has_coordinator"
        case publicationStatus = "publication_status"
        case departureDate = "departure_date"
        case departureCity = "departure_city"
        case descriptionText = "description"
        case totalRooms = "total_rooms"
        case availableRooms = "available_rooms"
        case depositPercent = "deposit_percent"
        case maxInstallments = "max_installments"
        case itineraryText = "itinerary_text"
        case createdAt = "created_at"
    }
}
```

---

### TransactionOrder

**Table name:** `transaction_orders`

```swift
struct TransactionOrder: Codable, Identifiable {
    let id: UUID // order_id
    let tenantId: UUID
    let stripeCheckoutSessionId: String?
    let userId: UUID
    let totalAmount: Double
    let remainingBalance: Double
    let currency: Currency
    let platformCommissionFee: Double
    let packageSubtotal: Double
    let packageIva: Double
    let paymentStatus: PaymentStatus
    let nextPaymentDue: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case tenantId = "tenant_id"
        case stripeCheckoutSessionId = "stripe_checkout_session_id"
        case userId = "user_id"
        case totalAmount = "total_amount"
        case remainingBalance = "remaining_balance"
        case currency
        case platformCommissionFee = "platform_commission_fee"
        case packageSubtotal = "package_subtotal"
        case packageIva = "package_iva"
        case paymentStatus = "payment_status"
        case nextPaymentDue = "next_payment_due"
        case createdAt = "created_at"
    }
}
```

---

### ChatConversation

**Table name:** `chat_conversations`

```swift
struct ChatConversation: Codable, Identifiable {
    let id: UUID // conversation_id
    let leadId: UUID?
    let tenantId: UUID
    let customerId: UUID
    let assignedAgentId: UUID?
    let status: ConversationStatus
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "conversation_id"
        case leadId = "lead_id"
        case tenantId = "tenant_id"
        case customerId = "customer_id"
        case assignedAgentId = "assigned_agent_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### ChatMessage

**Table name:** `chat_messages`

```swift
struct ChatMessage: Codable, Identifiable {
    let id: UUID // message_id
    let conversationId: UUID
    let senderId: UUID
    let messageText: String
    let messageType: ChatMessageType
    let metadata: [String: AnyCodable]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "message_id"
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case messageText = "message_text"
        case messageType = "message_type"
        case metadata
        case createdAt = "created_at"
    }
}
```

---

### Notification

**Table name:** `notifications`

```swift
struct Notification: Codable, Identifiable {
    let id: UUID // notification_id
    let userId: UUID
    let type: NotificationType
    let title: String
    let messageText: String
    let read: Bool
    let metadata: [String: AnyCodable]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "notification_id"
        case userId = "user_id"
        case type
        case title
        case messageText = "message"
        case read
        case metadata
        case createdAt = "created_at"
    }
}
```

---

### InstallmentSchedule

**Table name:** `installment_schedules`

```swift
struct InstallmentSchedule: Codable, Identifiable {
    let id: UUID // installment_id
    let orderId: UUID
    let installmentNumber: Int
    let amountDue: Double
    let amountPaid: Double
    let dueDate: Date
    let paidAt: Date?
    let stripeCheckoutUrl: String?
    let status: InstallmentStatus
    let reminderSentAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "installment_id"
        case orderId = "order_id"
        case installmentNumber = "installment_number"
        case amountDue = "amount_due"
        case amountPaid = "amount_paid"
        case dueDate = "due_date"
        case paidAt = "paid_at"
        case stripeCheckoutUrl = "stripe_checkout_url"
        case status
        case reminderSentAt = "reminder_sent_at"
        case createdAt = "created_at"
    }
}
```

---

### PackageReview

**Table name:** `package_reviews`

```swift
struct PackageReview: Codable, Identifiable {
    let id: UUID // review_id
    let packageId: UUID
    let userId: UUID
    let orderId: UUID?
    let rating: Int
    let titleText: String?
    let commentText: String?
    let status: ReviewStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "review_id"
        case packageId = "package_id"
        case userId = "user_id"
        case orderId = "order_id"
        case rating
        case titleText = "title"
        case commentText = "comment"
        case status
        case createdAt = "created_at"
    }
}
```

---

### AgencyTenant

**Table name:** `agency_tenants`

```swift
struct AgencyTenant: Codable, Identifiable {
    let id: UUID // tenant_id
    let businessName: String
    let rfc: String?
    let addressText: String?
    let status: AgencyTenantStatus
    let planType: PlanType
    let commissionRate: Double
    let logoUrl: String?
    let descriptionText: String?
    let contactEmail: String?
    let contactPhone: String?
    let websiteUrl: String?
    let verificationStatus: AgencyVerificationStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "tenant_id"
        case businessName = "business_name"
        case rfc
        case addressText = "address_text"
        case status
        case planType = "plan_type"
        case commissionRate = "commission_rate"
        case logoUrl = "logo_url"
        case descriptionText = "description"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case websiteUrl = "website_url"
        case verificationStatus = "verification_status"
        case createdAt = "created_at"
    }
}
```

---

### Lead

**Table name:** `leads`

```swift
struct Lead: Codable, Identifiable {
    let id: UUID // lead_id
    let tenantId: UUID
    let packageId: UUID
    let userId: UUID
    let assignedTo: UUID?
    let status: LeadStatus
    let conversationId: UUID?
    let qualificationData: [String: AnyCodable]?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "lead_id"
        case tenantId = "tenant_id"
        case packageId = "package_id"
        case userId = "user_id"
        case assignedTo = "assigned_to"
        case status
        case conversationId = "conversation_id"
        case qualificationData = "qualification_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### RoomHold

**Table name:** `room_holds`

```swift
struct RoomHold: Codable, Identifiable {
    let id: UUID // hold_id
    let packageId: UUID
    let userId: UUID
    let roomsHeld: Int
    let expiresAt: Date
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "hold_id"
        case packageId = "package_id"
        case userId = "user_id"
        case roomsHeld = "rooms_held"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}
```

---

### AnyCodable Helper

For metadata and qualification_data JSON columns:

```swift
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        default:
            try container.encodeNil()
        }
    }
}
```
