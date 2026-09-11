import Foundation

struct TransactionOrder: Codable, Identifiable, Sendable {
    let orderId: String
    let packageId: String?
    let tenantId: String?
    let userId: String
    let totalAmount: Double
    let remainingBalance: Double?
    let currency: String
    let platformCommissionFee: Double?
    let paymentStatus: String
    let stripeSessionId: String?
    let pointsRedeemed: Int?
    let discountApplied: Double?
    let travelerName: String?
    let travelerEmail: String?
    let travelDate: String?
    let guestCount: Int?
    let specialRequests: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case packageId = "package_id"
        case tenantId = "tenant_id"
        case userId = "user_id"
        case totalAmount = "total_amount"
        case remainingBalance = "remaining_balance"
        case currency
        case platformCommissionFee = "platform_commission_fee"
        case paymentStatus = "payment_status"
        case stripeSessionId = "stripe_session_id"
        case pointsRedeemed = "points_redeemed"
        case discountApplied = "discount_applied"
        case travelerName = "traveler_name"
        case travelerEmail = "traveler_email"
        case travelDate = "travel_date"
        case guestCount = "guest_count"
        case specialRequests = "special_requests"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String { orderId }

    var statusDisplay: String {
        switch paymentStatus {
        case "pending": return "Pending"
        case "processing": return "Processing"
        case "completed": return "Completed"
        case "failed": return "Failed"
        case "refunded": return "Refunded"
        case "partial": return "Partially Paid"
        default: return paymentStatus.capitalized
        }
    }

    var statusColor: String {
        switch paymentStatus {
        case "completed": return "green"
        case "pending", "processing": return "yellow"
        case "failed": return "red"
        case "refunded": return "gray"
        default: return "gray"
        }
    }

    init(
        orderId: String = UUID().uuidString,
        packageId: String? = nil,
        tenantId: String? = nil,
        userId: String,
        totalAmount: Double,
        remainingBalance: Double? = nil,
        currency: String = "MXN",
        platformCommissionFee: Double? = nil,
        paymentStatus: String = "pending",
        stripeSessionId: String? = nil,
        pointsRedeemed: Int? = nil,
        discountApplied: Double? = nil,
        travelerName: String? = nil,
        travelerEmail: String? = nil,
        travelDate: String? = nil,
        guestCount: Int? = nil,
        specialRequests: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.orderId = orderId
        self.packageId = packageId
        self.tenantId = tenantId
        self.userId = userId
        self.totalAmount = totalAmount
        self.remainingBalance = remainingBalance
        self.currency = currency
        self.platformCommissionFee = platformCommissionFee
        self.paymentStatus = paymentStatus
        self.stripeSessionId = stripeSessionId
        self.pointsRedeemed = pointsRedeemed
        self.discountApplied = discountApplied
        self.travelerName = travelerName
        self.travelerEmail = travelerEmail
        self.travelDate = travelDate
        self.guestCount = guestCount
        self.specialRequests = specialRequests
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
