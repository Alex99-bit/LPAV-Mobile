import Foundation

struct Profile: Codable, Identifiable, Sendable {
    var id: String
    var tenantId: String?
    var roleName: String
    var fullName: String
    var email: String
    var avatarUrl: String?
    var phone: String?
    var preferences: UserPreferences?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case roleName = "role_name"
        case fullName = "full_name"
        case email
        case avatarUrl = "avatar_url"
        case phone
        case preferences
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: String,
        tenantId: String? = nil,
        roleName: String,
        fullName: String,
        email: String,
        avatarUrl: String? = nil,
        phone: String? = nil,
        preferences: UserPreferences? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.tenantId = tenantId
        self.roleName = roleName
        self.fullName = fullName
        self.email = email
        self.avatarUrl = avatarUrl
        self.phone = phone
        self.preferences = preferences
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isAgency: Bool {
        roleName.hasPrefix("Agency_")
    }

    var isTraveler: Bool {
        roleName == "traveler"
    }

    var isSuperAdmin: Bool {
        roleName == "super_admin"
    }

    var displayName: String {
        fullName.isEmpty ? email : fullName
    }

    var displayRole: String {
        switch roleName {
        case "Agency_Admin": return "Agency Admin"
        case "Agency_Agent": return "Agency Agent"
        case "Agency_Collaborator": return "Agency Collaborator"
        case "traveler": return "Traveler"
        default: return roleName.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

struct UserPreferences: Codable, Sendable {
    var currency: String?
    var language: String?
    var notifications: NotificationPreferences?
    var travelStyle: [String]?
    var preferredRegions: [String]?
    var budgetRange: BudgetRange?
}

struct NotificationPreferences: Codable, Sendable {
    var pushEnabled: Bool?
    var emailEnabled: Bool?
    var marketingEnabled: Bool?
    var chatEnabled: Bool?
}

struct BudgetRange: Codable, Sendable {
    var min: Double?
    var max: Double?
    var currency: String?
}
