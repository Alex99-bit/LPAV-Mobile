import Foundation

enum WalletTransactionType: String, Codable, Sendable {
    case purchase
    case redemption
    case refund
    case bonus
    case commission
    case adjustment

    var displayName: String {
        switch self {
        case .purchase: return "Purchase"
        case .redemption: return "Redemption"
        case .refund: return "Refund"
        case .bonus: return "Bonus"
        case .commission: return "Commission"
        case .adjustment: return "Adjustment"
        }
    }

    var isPositive: Bool {
        switch self {
        case .purchase, .redemption, .adjustment: return false
        case .refund, .bonus, .commission: return true
        }
    }
}
