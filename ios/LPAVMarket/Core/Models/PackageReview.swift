import Foundation

struct PackageReview: Codable, Identifiable, Sendable {
    let reviewId: String
    let packageId: String
    let userId: String
    let rating: Int
    let comment: String?
    let userName: String?
    let userAvatarUrl: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case packageId = "package_id"
        case userId = "user_id"
        case rating
        case comment
        case userName = "user_name"
        case userAvatarUrl = "user_avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String { reviewId }

    init(
        reviewId: String = UUID().uuidString,
        packageId: String,
        userId: String,
        rating: Int,
        comment: String? = nil,
        userName: String? = nil,
        userAvatarUrl: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.reviewId = reviewId
        self.packageId = packageId
        self.userId = userId
        self.rating = max(1, min(5, rating))
        self.comment = comment
        self.userName = userName
        self.userAvatarUrl = userAvatarUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
