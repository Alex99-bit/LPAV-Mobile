import Foundation

struct AgencyTenant: Codable, Identifiable, Sendable {
    let tenantId: String
    let name: String
    let slug: String?
    let logoUrl: String?
    let coverUrl: String?
    let description: String?
    let website: String?
    let contactEmail: String?
    let contactPhone: String?
    let address: String?
    let city: String?
    let country: String?
    let subscriptionTier: String?
    let subscriptionStatus: String?
    let saasActive: Bool?
    let verified: Bool?
    let regions: [String]?
    let socialLinks: [String: String]?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case name
        case slug
        case logoUrl = "logo_url"
        case coverUrl = "cover_url"
        case description
        case website
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case address
        case city
        case country
        case subscriptionTier = "subscription_tier"
        case subscriptionStatus = "subscription_status"
        case saasActive = "saas_active"
        case verified
        case regions
        case socialLinks = "social_links"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String { tenantId }

    init(
        tenantId: String,
        name: String,
        slug: String? = nil,
        logoUrl: String? = nil,
        coverUrl: String? = nil,
        description: String? = nil,
        website: String? = nil,
        contactEmail: String? = nil,
        contactPhone: String? = nil,
        address: String? = nil,
        city: String? = nil,
        country: String? = nil,
        subscriptionTier: String? = nil,
        subscriptionStatus: String? = nil,
        saasActive: Bool? = nil,
        verified: Bool? = nil,
        regions: [String]? = nil,
        socialLinks: [String: String]? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.tenantId = tenantId
        self.name = name
        self.slug = slug
        self.logoUrl = logoUrl
        self.coverUrl = coverUrl
        self.description = description
        self.website = website
        self.contactEmail = contactEmail
        self.contactPhone = contactPhone
        self.address = address
        self.city = city
        self.country = country
        self.subscriptionTier = subscriptionTier
        self.subscriptionStatus = subscriptionStatus
        self.saasActive = saasActive
        self.verified = verified
        self.regions = regions
        self.socialLinks = socialLinks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
