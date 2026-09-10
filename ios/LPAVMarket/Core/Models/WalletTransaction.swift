import Foundation

struct WalletTransaction: Codable, Identifiable, Sendable {
    let id: String
    let walletId: String
    let type: WalletTransactionType
    let amount: Int
    let balanceAfter: Int
    let description: String
    let referenceId: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case walletId = "wallet_id"
        case type, amount
        case balanceAfter = "balance_after"
        case description
        case referenceId = "reference_id"
        case createdAt = "created_at"
    }

    var formattedAmount: String {
        let prefix = type.isPositive ? "+" : "-"
        return "\(prefix)\(amount.formatted()) pts"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}
