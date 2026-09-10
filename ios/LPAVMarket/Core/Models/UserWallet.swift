import Foundation

struct UserWallet: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    let balance: Int
    let totalEarned: Int
    let totalRedeemed: Int
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case balance, totalEarned = "total_earned"
        case totalRedeemed = "total_redeemed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var formattedBalance: String {
        "\(balance.formatted()) pts"
    }

    var estimatedMxnValue: Double {
        Double(balance) * 0.10
    }
}
