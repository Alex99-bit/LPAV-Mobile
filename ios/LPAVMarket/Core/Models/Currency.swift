import Foundation

enum Currency: String, Codable, Sendable {
    case mxn
    case usd
    case points

    var symbol: String {
        switch self {
        case .mxn: return "$"
        case .usd: return "US$"
        case .points: return "Pts"
        }
    }

    var code: String {
        switch self {
        case .mxn: return "MXN"
        case .usd: return "USD"
        case .points: return "PTS"
        }
    }
}
