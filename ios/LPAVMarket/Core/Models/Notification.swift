import Foundation

struct AppNotification: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    let type: NotificationType
    let title: String
    let message: String
    let referenceId: String?
    let referenceType: String?
    let isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type, title, message
        case referenceId = "reference_id"
        case referenceType = "reference_type"
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
