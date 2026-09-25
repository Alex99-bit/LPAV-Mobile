import XCTest
@testable import LPAVMarket

final class BackendIntegrationTests: XCTestCase {

    static let supabaseURL = "https://qmcpaqbxbmkhxjezhlch.supabase.co"
    static let anonKey = "sb_publishable_gVbolST77dwQ9n6BpP6YNQ_oTWIiSPt"

    override func setUp() async throws {
        setenv("SUPABASE_URL", Self.supabaseURL, 1)
        setenv("SUPABASE_ANON_KEY", Self.anonKey, 1)
    }

    func testSupabaseConnection() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        XCTAssertNotNil(httpResponse)
        XCTAssertTrue([200, 401, 403].contains(httpResponse?.statusCode ?? 0),
                      "Expected 200, 401, or 403 but got \(httpResponse?.statusCode ?? -1)")
    }

    func testTravelPackagesTableExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/travel_packages?select=package_id&limit=1")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 401, 403, 406].contains(statusCode),
                      "travel_packages table should exist. Got status \(statusCode)")
    }

    func testAgenciesTenantsTableExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/agencies_tenants?select=tenant_id&limit=1")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 401, 403, 406].contains(statusCode),
                      "agencies_tenants table should exist. Got status \(statusCode)")
    }

    func testTransactionsOrdersTableExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/transactions_orders?select=order_id&limit=1")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 401, 403, 406].contains(statusCode),
                      "transactions_orders table should exist. Got status \(statusCode)")
    }

    func testUserWalletsTableExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/user_wallets?select=user_id&limit=1")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 401, 403, 406].contains(statusCode),
                      "user_wallets table should exist. Got status \(statusCode)")
    }

    func testChatMessagesTableExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/chat_messages?select=message_id&limit=1")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 401, 403, 406].contains(statusCode),
                      "chat_messages table should exist. Got status \(statusCode)")
    }

    func testCRMLeadsTableExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/rest/v1/crm_leads?select=lead_id&limit=1")!
        var request = URLRequest(url: url)
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 401, 403, 406].contains(statusCode),
                      "crm_leads table should exist. Got status \(statusCode)")
    }

    func testEdgeFunctionCreateCheckoutExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/functions/v1/create-checkout")!
        var request = URLRequest(url: url)
        request.httpMethod = "OPTIONS"
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 204, 400, 401].contains(statusCode),
                      "create-checkout function should exist. Got status \(statusCode)")
    }

    func testEdgeFunctionGenerateItineraryExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/functions/v1/generate-itinerary")!
        var request = URLRequest(url: url)
        request.httpMethod = "OPTIONS"
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 204, 400, 401].contains(statusCode),
                      "generate-itinerary function should exist. Got status \(statusCode)")
    }

    func testEdgeFunctionCreateLeadExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/functions/v1/create-lead")!
        var request = URLRequest(url: url)
        request.httpMethod = "OPTIONS"
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 204, 400, 401].contains(statusCode),
                      "create-lead function should exist. Got status \(statusCode)")
    }

    func testEdgeFunctionAIQualifyLeadExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/functions/v1/ai-qualify-lead")!
        var request = URLRequest(url: url)
        request.httpMethod = "OPTIONS"
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 204, 400, 401].contains(statusCode),
                      "ai-qualify-lead function should exist. Got status \(statusCode)")
    }

    func testEdgeFunctionPresignedUrlExists() async throws {
        let url = URL(string: "\(Self.supabaseURL)/functions/v1/presigned-url")!
        var request = URLRequest(url: url)
        request.httpMethod = "OPTIONS"
        request.setValue(Self.anonKey, forHTTPHeaderField: "apikey")

        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1

        XCTAssertTrue([200, 204, 400, 401].contains(statusCode),
                      "presigned-url function should exist. Got status \(statusCode)")
    }
}
