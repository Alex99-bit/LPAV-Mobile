import Foundation

struct InstallmentSchedule: Codable, Identifiable, Sendable {
    let id: String
    let orderId: String
    let installmentNumber: Int
    let totalInstallments: Int
    let amountMxn: Double
    let dueDate: Date
    let paidDate: Date?
    let paymentStatus: PaymentStatus
    let stripePaymentIntentId: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case orderId = "order_id"
        case installmentNumber = "installment_number"
        case totalInstallments = "total_installments"
        case amountMxn = "amount_mxn"
        case dueDate = "due_date"
        case paidDate = "paid_date"
        case paymentStatus = "payment_status"
        case stripePaymentIntentId = "stripe_payment_intent_id"
        case createdAt = "created_at"
    }

    var isPaid: Bool {
        paymentStatus == .completed
    }

    var isOverdue: Bool {
        !isPaid && dueDate < Date()
    }

    var formattedAmount: String {
        "$\(Int(amountMxn).formatted()) MXN"
    }

    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }

    var installmentText: String {
        "Installment \(installmentNumber)/\(totalInstallments)"
    }
}
