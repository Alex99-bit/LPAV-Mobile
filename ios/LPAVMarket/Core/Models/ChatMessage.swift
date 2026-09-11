import Foundation

struct ChatMessage: Codable, Identifiable, Sendable {
    let messageId: String
    let conversationId: String
    let senderId: String
    let messageText: String
    let createdAt: String?
    let isSystem: Bool?
    let isCensored: Bool?
    let censorshipReason: String?
    let messageType: String?
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case messageText = "message_text"
        case createdAt = "created_at"
        case isSystem = "is_system"
        case isCensored = "is_censored"
        case censorshipReason = "censorship_reason"
        case messageType = "message_type"
        case metadata
    }

    var id: String { messageId }

    var isSentByMe: Bool {
        senderId == AuthManager.currentUserId
    }

    var formattedTime: String {
        guard let dateString = createdAt,
              let date = dateString.toDateFromISO() else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    init(
        messageId: String = UUID().uuidString,
        conversationId: String,
        senderId: String,
        messageText: String,
        createdAt: String? = nil,
        isSystem: Bool? = false,
        isCensored: Bool? = false,
        censorshipReason: String? = nil,
        messageType: String? = "text",
        metadata: [String: String]? = nil
    ) {
        self.messageId = messageId
        self.conversationId = conversationId
        self.senderId = senderId
        self.messageText = messageText
        self.createdAt = createdAt
        self.isSystem = isSystem
        self.isCensored = isCensored
        self.censorshipReason = censorshipReason
        self.messageType = messageType
        self.metadata = metadata
    }
}
