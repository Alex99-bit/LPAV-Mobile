import Foundation

struct UserWallet: Codable, Identifiable, Sendable {
    let walletId: String
    let userId: String
    let pointsBalance: Int
    let lifetimePoints: Int?
    let tier: String?
    let expiresAt: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case walletId = "wallet_id"
        case userId = "user_id"
        case pointsBalance = "points_balance"
        case lifetimePoints = "lifetime_points"
        case tier
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String { walletId }

    var tierDisplay: String {
        switch tier {
        case "platinum": return "Platinum"
        case "gold": return "Gold"
        case "silver": return "Silver"
        case "bronze": return "Bronze"
        default: return "Standard"
        }
    }

    var tierColor: String {
        switch tier {
        case "platinum": return "purple"
        case "gold": return "yellow"
        case "silver": return "gray"
        case "bronze": return "orange"
        default: return "blue"
        }
    }

    var pointsValue: Double {
        Double(pointsBalance) * 0.01
    }

    init(
        walletId: String = UUID().uuidString,
        userId: String,
        pointsBalance: Int = 0,
        lifetimePoints: Int? = nil,
        tier: String? = nil,
        expiresAt: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.walletId = walletId
        self.userId = userId
        self.pointsBalance = pointsBalance
        self.lifetimePoints = lifetimePoints
        self.tier = tier
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
