import Foundation

struct Role: Codable, Identifiable, Sendable {
    let roleId: String
    let tenantId: String?
    let roleName: String
    let permissions: [String]?
    let description: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case roleId = "role_id"
        case tenantId = "tenant_id"
        case roleName = "role_name"
        case permissions
        case description
        case createdAt = "created_at"
    }

    var id: String { roleId }

    func hasPermission(_ permission: String) -> Bool {
        permissions?.contains(permission) ?? false
    }

    var displayName: String {
        roleName.replacingOccurrences(of: "_", with: " ").capitalized
    }

    init(
        roleId: String = UUID().uuidString,
        tenantId: String? = nil,
        roleName: String,
        permissions: [String]? = nil,
        description: String? = nil,
        createdAt: String? = nil
    ) {
        self.roleId = roleId
        self.tenantId = tenantId
        self.roleName = roleName
        self.permissions = permissions
        self.description = description
        self.createdAt = createdAt
    }
}
