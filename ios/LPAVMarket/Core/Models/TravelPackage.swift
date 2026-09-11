import Foundation

struct TravelPackage: Codable, Identifiable, Sendable {
    let packageId: String
    let tenantId: String?
    let title: String
    let region: String
    let price: Double
    let currency: String
    let urlFlyerStorage: String?
    let urlThumbnailStorage: String?
    let hasCoordinator: Bool?
    let publicationStatus: String?
    let departureDate: String?
    let description: String?
    let duration: String?
    let maxGuests: Int?
    let includes: [String]?
    let excludes: [String]?
    let isFeatured: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case packageId = "package_id"
        case tenantId = "tenant_id"
        case title
        case region
        case price
        case currency
        case urlFlyerStorage = "url_flyer_storage"
        case urlThumbnailStorage = "url_thumbnail_storage"
        case hasCoordinator = "has_coordinator"
        case publicationStatus = "publication_status"
        case departureDate = "departure_date"
        case description
        case duration
        case maxGuests = "max_guests"
        case includes
        case excludes
        case isFeatured = "is_featured"
        case createdAt = "created_at"
    }

    var id: String { packageId }

    init(
        packageId: String,
        tenantId: String? = nil,
        title: String,
        region: String,
        price: Double,
        currency: String,
        urlFlyerStorage: String? = nil,
        urlThumbnailStorage: String? = nil,
        hasCoordinator: Bool? = nil,
        publicationStatus: String? = nil,
        departureDate: String? = nil,
        description: String? = nil,
        duration: String? = nil,
        maxGuests: Int? = nil,
        includes: [String]? = nil,
        excludes: [String]? = nil,
        isFeatured: Bool? = nil,
        createdAt: String? = nil
    ) {
        self.packageId = packageId
        self.tenantId = tenantId
        self.title = title
        self.region = region
        self.price = price
        self.currency = currency
        self.urlFlyerStorage = urlFlyerStorage
        self.urlThumbnailStorage = urlThumbnailStorage
        self.hasCoordinator = hasCoordinator
        self.publicationStatus = publicationStatus
        self.departureDate = departureDate
        self.description = description
        self.duration = duration
        self.maxGuests = maxGuests
        self.includes = includes
        self.excludes = excludes
        self.isFeatured = isFeatured
        self.createdAt = createdAt
    }
}
