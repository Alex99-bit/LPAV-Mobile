import Foundation

struct ChatMessage: Codable, Identifiable, Sendable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String?
    let content: String
    let messageType: ChatMessageType
    let paymentAmount: Double?
    let paymentStatus: String?
    let createdAt: Date
    let readAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case senderName = "sender_name"
        case content
        case messageType = "message_type"
        case paymentAmount = "payment_amount"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case readAt = "read_at"
    }

    var isSentByMe: Bool {
        senderId == AuthManager.currentUserId
    }

    var isPaymentRequest: Bool {
        messageType == .paymentRequest
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }
}
