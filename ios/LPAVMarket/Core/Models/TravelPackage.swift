import Foundation

struct TravelPackage: Codable, Identifiable, Sendable {
    let id: String
    let tenantId: String
    let title: String
    let slug: String
    let description: String?
    let coverImageUrl: String?
    let region: String
    let departureCity: String
    let destination: String?
    let durationDays: Int
    let durationNights: Int
    let priceMxn: Double
    let originalPriceMxn: Double?
    let pointsPrice: Int
    let currency: Currency
    let includedItems: [String]?
    let excludedItems: [String]?
    let maxGroupSize: Int
    let availableSpots: Int
    let status: PublicationStatus
    let rating: Double?
    let reviewCount: Int
    let departureDate: Date?
    let returnDate: Date?
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case title, slug, description
        case coverImageUrl = "cover_image_url"
        case region
        case departureCity = "departure_city"
        case destination
        case durationDays = "duration_days"
        case durationNights = "duration_nights"
        case priceMxn = "price_mxn"
        case originalPriceMxn = "original_price_mxn"
        case pointsPrice = "points_price"
        case currency
        case includedItems = "included_items"
        case excludedItems = "excluded_items"
        case maxGroupSize = "max_group_size"
        case availableSpots = "available_spots"
        case status, rating
        case reviewCount = "review_count"
        case departureDate = "departure_date"
        case returnDate = "return_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var formattedPrice: String {
        "\(currency.symbol)\(Int(priceMxn).formatted())"
    }

    var durationText: String {
        "\(durationDays)D/\(durationNights)N"
    }

    var hasDiscount: Bool {
        guard let original = originalPriceMxn else { return false }
        return original > priceMxn
    }

    var discountPercentage: Double {
        guard let original = originalPriceMxn, original > priceMxn else { return 0 }
        return ((original - priceMxn) / original) * 100
    }
}
