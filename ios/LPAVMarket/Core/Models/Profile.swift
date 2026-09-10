import Foundation

struct Profile: Codable, Identifiable, Sendable {
    let id: String
    let email: String
    let fullName: String?
    let tenantId: String?
    let roleName: String
    let avatarUrl: String?
    let phone: String?
    let censorshipStrikes: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email
        case fullName = "full_name"
        case tenantId = "tenant_id"
        case roleName = "role_name"
        case avatarUrl = "avatar_url"
        case phone
        case censorshipStrikes = "censorship_strikes"
        case createdAt = "created_at"
    }

    var isAgency: Bool {
        roleName == "agency_admin" || roleName == "agency"
    }

    var isTraveler: Bool {
        roleName == "traveler"
    }

    var isSuperAdmin: Bool {
        roleName == "super_admin"
    }

    var displayName: String {
        fullName ?? email
    }
}
