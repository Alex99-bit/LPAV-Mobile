import Foundation

enum PaymentStatus: String, Codable, Sendable {
    case pending
    case partial
    case completed
    case failed
    case refunded

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .partial: return "Partial"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        }
    }
}
