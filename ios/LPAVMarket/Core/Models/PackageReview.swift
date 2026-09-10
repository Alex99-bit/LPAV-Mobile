import Foundation

struct PackageReview: Codable, Identifiable, Sendable {
    let id: String
    let packageId: String
    let userId: String
    let userName: String?
    let userAvatarUrl: String?
    let rating: Int
    let comment: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case packageId = "package_id"
        case userId = "user_id"
        case userName = "user_name"
        case userAvatarUrl = "user_avatar_url"
        case rating, comment
        case createdAt = "created_at"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }

    var stars: [Bool] {
        (1...5).map { $0 <= rating }
    }
}
