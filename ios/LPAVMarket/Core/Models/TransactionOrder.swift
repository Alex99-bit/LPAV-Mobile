import Foundation

struct TransactionOrder: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    let tenantId: String
    let packageId: String
    let packageTitle: String?
    let totalAmountMxn: Double
    let depositAmountMxn: Double
    let pointsUsed: Int
    let pointsValueMxn: Double
    let ivaAmount: Double
    let totalWithIva: Double
    let paymentStatus: PaymentStatus
    let stripePaymentIntentId: String?
    let installmentPlan: Bool
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case tenantId = "tenant_id"
        case packageId = "package_id"
        case packageTitle = "package_title"
        case totalAmountMxn = "total_amount_mxn"
        case depositAmountMxn = "deposit_amount_mxn"
        case pointsUsed = "points_used"
        case pointsValueMxn = "points_value_mxn"
        case ivaAmount = "iva_amount"
        case totalWithIva = "total_with_iva"
        case paymentStatus = "payment_status"
        case stripePaymentIntentId = "stripe_payment_intent_id"
        case installmentPlan = "installment_plan"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var formattedTotal: String {
        "$\(Int(totalWithIva).formatted()) MXN"
    }

    var formattedDeposit: String {
        "$\(Int(depositAmountMxn).formatted()) MXN"
    }

    var statusColor: PaymentStatus {
        paymentStatus
    }
}
