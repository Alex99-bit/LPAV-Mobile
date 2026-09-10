import Foundation

struct AgencyTenant: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let slug: String
    let description: String?
    let logoUrl: String?
    let coverImageUrl: String?
    let phone: String?
    let email: String?
    let website: String?
    let isVerified: Bool
    let rating: Double?
    let reviewCount: Int
    let packageCount: Int
    let planType: PlanType
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description
        case logoUrl = "logo_url"
        case coverImageUrl = "cover_image_url"
        case phone, email, website
        case isVerified = "is_verified"
        case rating
        case reviewCount = "review_count"
        case packageCount = "package_count"
        case planType = "plan_type"
        case createdAt = "created_at"
    }

    var formattedRating: String {
        guard let rating = rating else { return "New" }
        return String(format: "%.1f", rating)
    }
}
