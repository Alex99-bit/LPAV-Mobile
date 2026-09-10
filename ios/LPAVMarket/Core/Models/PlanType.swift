import Foundation

enum PlanType: String, Codable, Sendable {
    case free
    case basic
    case premium
    case enterprise

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .basic: return "Basic"
        case .premium: return "Premium"
        case .enterprise: return "Enterprise"
        }
    }

    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .basic: return 49.00
        case .premium: return 149.00
        case .enterprise: return 399.00
        }
    }
}
