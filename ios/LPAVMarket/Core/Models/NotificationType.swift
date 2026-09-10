import Foundation

enum NotificationType: String, Codable, Sendable {
    case orderUpdate = "order_update"
    case paymentReceived = "payment_received"
    case paymentDue = "payment_due"
    case chatMessage = "chat_message"
    case packageUpdate = "package_update"
    case promotion
    case system

    var displayName: String {
        switch self {
        case .orderUpdate: return "Order Update"
        case .paymentReceived: return "Payment Received"
        case .paymentDue: return "Payment Due"
        case .chatMessage: return "Chat Message"
        case .packageUpdate: return "Package Update"
        case .promotion: return "Promotion"
        case .system: return "System"
        }
    }
}
