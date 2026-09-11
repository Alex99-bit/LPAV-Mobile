import Foundation

enum EdgeFunction {
    static var supabaseURL: String {
        ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
    }

    static var supabaseAnonKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
    }

    static func invoke(
        function: String,
        body: [String: Any] = [:],
        method: String = "POST"
    ) async throws -> Data {
        guard let url = URL(string: "\(supabaseURL)/functions/v1/\(function)") else {
            throw EdgeFunctionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        if !body.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw EdgeFunctionError.httpError(statusCode)
        }

        return data
    }

    static func invokeDecodable<T: Decodable>(
        function: String,
        body: [String: Any] = [:],
        method: String = "POST"
    ) async throws -> T {
        let data = try await invoke(function: function, body: body, method: method)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    enum Functions {
        static func createCheckoutSession(packageIds: [String], successUrl: String, cancelUrl: String) async throws -> CreateCheckoutResponse {
            let response: CreateCheckoutResponse = try await EdgeFunction.invokeDecodable(
                function: "create-checkout",
                body: [
                    "package_ids": packageIds,
                    "success_url": successUrl,
                    "cancel_url": cancelUrl
                ]
            )
            return response
        }

        static func generateItinerary(packageId: String, preferences: String?) async throws -> ItineraryResponse {
            var body: [String: Any] = ["package_id": packageId]
            if let preferences {
                body["preferences"] = preferences
            }
            let response: ItineraryResponse = try await EdgeFunction.invokeDecodable(
                function: "generate-itinerary",
                body: body
            )
            return response
        }

        static func searchWithGemini(query: String, context: [String: Any] = [:]) async throws -> GeminiSearchResponse {
            var body: [String: Any] = ["query": query]
            for (key, value) in context {
                body[key] = value
            }
            let response: GeminiSearchResponse = try await EdgeFunction.invokeDecodable(
                function: "gemini-search",
                body: body
            )
            return response
        }

        static func qualifyLead(leadId: String) async throws -> LeadQualificationResponse {
            let response: LeadQualificationResponse = try await EdgeFunction.invokeDecodable(
                function: "qualify-lead",
                body: ["lead_id": leadId]
            )
            return response
        }
    }
}

enum EdgeFunctionError: LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Edge Function URL"
        case .httpError(let code):
            return "Edge Function returned HTTP \(code)"
        case .decodingError(let detail):
            return "Failed to decode Edge Function response: \(detail)"
        }
    }
}

struct CreateCheckoutResponse: Codable, Sendable {
    let sessionId: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case url
    }
}

struct ItineraryResponse: Codable, Sendable {
    let itinerary: [ItineraryDay]
    let summary: String?

    struct ItineraryDay: Codable, Identifiable, Sendable {
        let day: Int
        let title: String
        let description: String
        let activities: [String]?
        let meals: [String]?

        var id: Int { day }
    }
}

struct GeminiSearchResponse: Codable, Sendable {
    let results: [String]?
    let summary: String?
    let suggestions: [String]?
}

struct LeadQualificationResponse: Codable, Sendable {
    let score: Int?
    let summary: String?
    let qualified: Bool?
}
