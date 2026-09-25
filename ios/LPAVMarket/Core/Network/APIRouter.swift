import Foundation
import Supabase

enum APIRouter {
    static var supabaseURL: String {
        ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
    }

    static var supabaseAnonKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
    }
}

extension APIRouter {

    enum Auth {
        static func signUp(email: String, password: String, fullName: String, roleName: String?) async throws -> Profile {
            let session = try await supabase.auth.signUp(email: email, password: password)
            let profile = Profile(
                id: session.user.id.uuidString,
                tenantId: nil,
                roleName: roleName ?? "traveler",
                fullName: fullName,
                email: email,
                avatarUrl: nil
            )
            try await createProfile(profile)
            return profile
        }

        static func signIn(email: String, password: String) async throws -> Profile {
            let session = try await supabase.auth.signIn(email: email, password: password)
            let profile = try await fetchProfile(userId: session.user.id.uuidString)
            return profile
        }

        static func signInWithGoogle(idToken: String) async throws -> Profile {
            let session = try await supabase.auth.signIn(
                credentials: .google(
                    idToken: idToken,
                    accessToken: ""
                )
            )
            let existingProfile = try? await fetchProfile(userId: session.user.id.uuidString)
            let profile: Profile
            if let existingProfile {
                profile = existingProfile
            } else {
                profile = Profile(
                    id: session.user.id.uuidString,
                    tenantId: nil,
                    roleName: "traveler",
                    fullName: session.user.userMetadata["full_name"]?.stringValue ?? "",
                    email: session.user.email ?? "",
                    avatarUrl: session.user.userMetadata["avatar_url"]?.stringValue
                )
                try await createProfile(profile)
            }
            return profile
        }

        static func signOut() async throws {
            try await supabase.auth.signOut()
        }

        private static func createProfile(_ profile: Profile) async throws {
            let json: [String: AnyJSON] = [
                "id": AnyJSON(profile.id),
                "tenant_id": AnyJSON(profile.tenantId as Any?),
                "role_name": AnyJSON(profile.roleName),
                "full_name": AnyJSON(profile.fullName),
                "email": AnyJSON(profile.email),
                "avatar_url": AnyJSON(profile.avatarUrl as Any?)
            ]
            try await supabase.database
                .from("profiles")
                .insert(json)
                .execute()
        }

        static func fetchProfile(userId: String) async throws -> Profile {
            let response: [Profile] = try await supabase.database
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            guard let profile = response.first else {
                throw SupabaseError.decodingFailed("Profile not found")
            }
            return profile
        }

        static func fetchCurrentUser() async throws -> Profile {
            let session = try await supabase.auth.session
            let profile = try await fetchProfile(userId: session.user.id.uuidString)
            return profile
        }
    }

    enum Packages {
        static func fetchAll(
            page: Int = 1,
            limit: Int = 20,
            region: String? = nil,
            minPrice: Double? = nil,
            maxPrice: Double? = nil,
            searchQuery: String? = nil
        ) async throws -> [TravelPackage] {
            var query = supabase.database
                .from("travel_packages")
                .select()
                .eq("publication_status", value: "published")
                .order("created_at", ascending: false)
                .range(from: (page - 1) * limit, to: page * limit - 1)

            if let region {
                query = query.eq("region", value: region)
            }
            if let minPrice {
                query = query.gte("price", value: minPrice)
            }
            if let maxPrice {
                query = query.lte("price", value: maxPrice)
            }
            if let searchQuery {
                query = query.ilike("title", value: "%\(searchQuery)%")
            }

            let response: [TravelPackage] = try await query.execute().value
            return response
        }

        static func fetchPackage(packageId: String) async throws -> TravelPackage {
            let response: [TravelPackage] = try await supabase.database
                .from("travel_packages")
                .select()
                .eq("package_id", value: packageId)
                .execute()
                .value
            guard let package = response.first else {
                throw SupabaseError.decodingFailed("Package not found")
            }
            return package
        }

        static func fetchFeatured() async throws -> [TravelPackage] {
            let response: [TravelPackage] = try await supabase.database
                .from("travel_packages")
                .select()
                .eq("publication_status", value: "published")
                .eq("is_featured", value: true)
                .limit(10)
                .execute()
                .value
            return response
        }

        static func fetchByTenant(tenantId: String) async throws -> [TravelPackage] {
            let response: [TravelPackage] = try await supabase.database
                .from("travel_packages")
                .select()
                .eq("tenant_id", value: tenantId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return response
        }

        static func create(_ package: TravelPackage) async throws -> TravelPackage {
            let response: [TravelPackage] = try await supabase.database
                .from("travel_packages")
                .insert(package)
                .select()
                .execute()
                .value
            guard let created = response.first else {
                throw SupabaseError.decodingFailed("Failed to create package")
            }
            return created
        }

        static func update(_ package: TravelPackage) async throws -> TravelPackage {
            let response: [TravelPackage] = try await supabase.database
                .from("travel_packages")
                .update(package)
                .eq("package_id", value: package.packageId)
                .select()
                .execute()
                .value
            guard let updated = response.first else {
                throw SupabaseError.decodingFailed("Failed to update package")
            }
            return updated
        }
    }

    enum Orders {
        static func create(order: TransactionOrder) async throws -> TransactionOrder {
            let response: [TransactionOrder] = try await supabase.database
                .from("transactions_orders")
                .insert(order)
                .select()
                .execute()
                .value
            guard let created = response.first else {
                throw SupabaseError.decodingFailed("Failed to create order")
            }
            return created
        }

        static func fetchUserOrders(userId: String) async throws -> [TransactionOrder] {
            let response: [TransactionOrder] = try await supabase.database
                .from("transactions_orders")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return response
        }

        static func fetchOrder(orderId: String) async throws -> TransactionOrder {
            let response: [TransactionOrder] = try await supabase.database
                .from("transactions_orders")
                .select()
                .eq("order_id", value: orderId)
                .execute()
                .value
            guard let order = response.first else {
                throw SupabaseError.decodingFailed("Order not found")
            }
            return order
        }
    }

    enum CRM {
        static func fetchLeads(tenantId: String, status: String? = nil) async throws -> [CRMLead] {
            var query = supabase.database
                .from("crm_leads")
                .select()
                .eq("tenant_id", value: tenantId)
                .order("created_at", ascending: false)

            if let status {
                query = query.eq("status", value: status)
            }

            let response: [CRMLead] = try await query.execute().value
            return response
        }

        static func updateLeadStatus(leadId: String, status: String) async throws {
            try await supabase.database
                .from("crm_leads")
                .update(["status": status])
                .eq("lead_id", value: leadId)
                .execute()
        }

        static func assignLead(leadId: String, assignedTo: String) async throws {
            try await supabase.database
                .from("crm_leads")
                .update(["assigned_to": assignedTo])
                .eq("lead_id", value: leadId)
                .execute()
        }
    }

    enum Chat {
        static func fetchConversations(userId: String) async throws -> [ChatConversation] {
            let response: [ChatConversation] = try await supabase.database
                .from("conversations")
                .select()
                .or("traveler_user_id.eq.\(userId),agent_user_id.eq.\(userId)")
                .order("updated_at", ascending: false)
                .execute()
                .value
            return response
        }

        static func fetchMessages(conversationId: String, limit: Int = 50) async throws -> [ChatMessage] {
            let response: [ChatMessage] = try await supabase.database
                .from("chat_messages")
                .select()
                .eq("conversation_id", value: conversationId)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            return response
        }

        static func sendMessage(_ message: ChatMessage) async throws -> ChatMessage {
            let response: [ChatMessage] = try await supabase.database
                .from("chat_messages")
                .insert(message)
                .select()
                .execute()
                .value
            guard let created = response.first else {
                throw SupabaseError.decodingFailed("Failed to send message")
            }
            return created
        }

        static func subscribeToMessages(conversationId: String) async throws -> RealtimeChannel {
            let channel = supabase.channel("chat_messages:\(conversationId)")
            return channel
        }
    }

    enum Reviews {
        static func fetchForPackage(packageId: String) async throws -> [PackageReview] {
            let response: [PackageReview] = try await supabase.database
                .from("package_reviews")
                .select()
                .eq("package_id", value: packageId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return response
        }

        static func createReview(_ review: PackageReview) async throws -> PackageReview {
            let response: [PackageReview] = try await supabase.database
                .from("package_reviews")
                .insert(review)
                .select()
                .execute()
                .value
            guard let created = response.first else {
                throw SupabaseError.decodingFailed("Failed to create review")
            }
            return created
        }
    }

    enum Wallet {
        static func fetchWallet(userId: String) async throws -> UserWallet {
            let response: [UserWallet] = try await supabase.database
                .from("user_wallets")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            guard let wallet = response.first else {
                throw SupabaseError.decodingFailed("Wallet not found")
            }
            return wallet
        }

        static func fetchPointsHistory(userId: String) async throws -> [WalletTransaction] {
            let response: [WalletTransaction] = try await supabase.database
                .from("wallet_transactions")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return response
        }

        static func redeemPoints(userId: String, points: Int) async throws -> UserWallet {
            let response: [UserWallet] = try await supabase.database
                .rpc("redeem_points", params: [
                    "p_user_id": userId,
                    "p_points": points
                ])
                .execute()
                .value
            guard let wallet = response.first else {
                throw SupabaseError.decodingFailed("Failed to redeem points")
            }
            return wallet
        }
    }

    enum Notifications {
        static func fetchAll(userId: String) async throws -> [AppNotification] {
            let response: [AppNotification] = try await supabase.database
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            return response
        }

        static func markAsRead(notificationId: String) async throws {
            try await supabase.database
                .from("notifications")
                .update(["read": true])
                .eq("notification_id", value: notificationId)
                .execute()
        }
    }

    enum Tenants {
        static func fetchTenant(tenantId: String) async throws -> AgencyTenant {
            let response: [AgencyTenant] = try await supabase.database
                .from("agencies_tenants")
                .select()
                .eq("tenant_id", value: tenantId)
                .execute()
                .value
            guard let tenant = response.first else {
                throw SupabaseError.decodingFailed("Tenant not found")
            }
            return tenant
        }
    }

    enum Onboarding {
        static func saveProfile(_ profile: OnboardingProfile) async throws {
            try await supabase.database
                .from("onboarding_profiles")
                .upsert(profile)
                .execute()
        }

        static func fetchProfile(userId: String) async throws -> OnboardingProfile? {
            let response: [OnboardingProfile] = try await supabase.database
                .from("onboarding_profiles")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            return response.first
        }
    }
}

final class ChatConversation: Codable, Identifiable, Sendable {
    let conversationId: String
    let travelerUserId: String
    let agentUserId: String?
    let lastMessage: String?
    let updatedAt: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case travelerUserId = "traveler_user_id"
        case agentUserId = "agent_user_id"
        case lastMessage = "last_message"
        case updatedAt = "updated_at"
        case status
    }

    var id: String { conversationId }
}

final class PointsTransaction: Codable, Identifiable, Sendable {
    let transactionId: String
    let userId: String
    let points: Int
    let reason: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case userId = "user_id"
        case points
        case reason
        case createdAt = "created_at"
    }

    var id: String { transactionId }
}

@Observable
final class CartManager {
    static let shared = CartManager()

    private(set) var packageIds: [String] = []

    private let defaultsKey = "cart_package_ids"

    private init() {
        loadFromDefaults()
    }

    func addPackage(_ packageId: String) {
        guard !packageIds.contains(packageId) else { return }
        packageIds.append(packageId)
        saveToDefaults()
    }

    func removePackage(_ packageId: String) {
        packageIds.removeAll { $0 == packageId }
        saveToDefaults()
    }

    func clear() {
        packageIds.removeAll()
        saveToDefaults()
    }

    var count: Int { packageIds.count }

    private func loadFromDefaults() {
        packageIds = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
    }

    private func saveToDefaults() {
        UserDefaults.standard.set(packageIds, forKey: defaultsKey)
    }

    func mergeWithRemote(userId: String) async {
        loadFromDefaults()
    }
}
