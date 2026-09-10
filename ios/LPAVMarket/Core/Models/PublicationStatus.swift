import Foundation

enum PublicationStatus: String, Codable, Sendable {
    case draft
    case published
    case suspended
    case archived

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .published: return "Published"
        case .suspended: return "Suspended"
        case .archived: return "Archived"
        }
    }
}
