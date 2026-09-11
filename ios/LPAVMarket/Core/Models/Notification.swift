import Foundation

struct AppNotification: Codable, Identifiable, Sendable {
    let notificationId: String
    let userId: String
    let type: String
    let title: String
    let message: String
    let metadata: [String: String]?
    let read: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case notificationId = "notification_id"
        case userId = "user_id"
        case type
        case title
        case message
        case metadata
        case read
        case createdAt = "created_at"
    }

    var id: String { notificationId }

    var iconName: String {
        switch type {
        case "chat": return "bubble.left.fill"
        case "order": return "cart.fill"
        case "flyer": return "airplane.departure"
        case "points": return "star.fill"
        case "lead": return "person.badge.plus"
        case "review": return "star.bubble.fill"
        default: return "bell.fill"
        }
    }

    var iconColor: String {
        switch type {
        case "chat": return "blue"
        case "order": return "green"
        case "flyer": return "purple"
        case "points": return "orange"
        case "lead": return "yellow"
        case "review": return "pink"
        default: return "gray"
        }
    }

    init(
        notificationId: String = UUID().uuidString,
        userId: String,
        type: String,
        title: String,
        message: String,
        metadata: [String: String]? = nil,
        read: Bool? = false,
        createdAt: String? = nil
    ) {
        self.notificationId = notificationId
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.metadata = metadata
        self.read = read
        self.createdAt = createdAt
    }
}
