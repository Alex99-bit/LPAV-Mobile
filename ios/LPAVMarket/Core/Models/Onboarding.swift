import Foundation

struct OnboardingProfile: Codable, Identifiable, Sendable {
    let userId: String
    var clusterInterestsHash: [String]?
    var interestsTags: [String]?
    var preferredDestinations: [String]?
    var targetBudgetRange: BudgetRange?
    var travelFrequency: String?
    var travelWith: [String]?
    var accommodationType: [String]?
    var activityPreferences: [String]?
    var dietaryRestrictions: [String]?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case clusterInterestsHash = "cluster_interests_hash"
        case interestsTags = "interests_tags"
        case preferredDestinations = "preferred_destinations"
        case targetBudgetRange = "target_budget_range"
        case travelFrequency = "travel_frequency"
        case travelWith = "travel_with"
        case accommodationType = "accommodation_type"
        case activityPreferences = "activity_preferences"
        case dietaryRestrictions = "dietary_restrictions"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String { userId }

    init(
        userId: String,
        clusterInterestsHash: [String]? = nil,
        interestsTags: [String]? = nil,
        preferredDestinations: [String]? = nil,
        targetBudgetRange: BudgetRange? = nil,
        travelFrequency: String? = nil,
        travelWith: [String]? = nil,
        accommodationType: [String]? = nil,
        activityPreferences: [String]? = nil,
        dietaryRestrictions: [String]? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.userId = userId
        self.clusterInterestsHash = clusterInterestsHash
        self.interestsTags = interestsTags
        self.preferredDestinations = preferredDestinations
        self.targetBudgetRange = targetBudgetRange
        self.travelFrequency = travelFrequency
        self.travelWith = travelWith
        self.accommodationType = accommodationType
        self.activityPreferences = activityPreferences
        self.dietaryRestrictions = dietaryRestrictions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
