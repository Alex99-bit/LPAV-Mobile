import Foundation

struct PackageRoute: Hashable {
    let id: String
}

struct AgencyRoute: Hashable {
    let id: String
}

struct ConversationRoute: Hashable {
    let id: String
    let name: String
}

struct CartRoute: Hashable {}
