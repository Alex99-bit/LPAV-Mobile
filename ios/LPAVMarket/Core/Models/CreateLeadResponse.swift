import Foundation

struct CreateLeadResponse: Codable {
    let conversationId: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case message
    }
}
