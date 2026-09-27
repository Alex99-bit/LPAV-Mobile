import Foundation

struct CartItem: Codable, Identifiable, Sendable {
    let id: UUID
    let packageId: String
    let packageTitle: String
    let coverImageUrl: String?
    let region: String
    let priceMxn: Double
    let quantity: Int

    var totalPrice: Double {
        priceMxn * Double(quantity)
    }

    var formattedPrice: String {
        "$\(Int(totalPrice).formatted()) MXN"
    }
}
