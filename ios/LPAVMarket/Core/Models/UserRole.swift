import Foundation

enum UserRole: String, Codable, Sendable {
    case traveler
    case agencyAdmin = "agency_admin"
    case superAdmin = "super_admin"

    var displayName: String {
        switch self {
        case .traveler: return "Traveler"
        case .agencyAdmin: return "Agency Admin"
        case .superAdmin: return "Super Admin"
        }
    }
}
