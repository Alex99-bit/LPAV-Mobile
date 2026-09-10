import Foundation

enum ChatMessageType: String, Codable, Sendable {
    case text
    case paymentRequest = "payment_request"
    case system

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .paymentRequest: return "Payment Request"
        case .system: return "System"
        }
    }
}
