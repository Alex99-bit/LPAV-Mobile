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
        method: String = "POST",
        authToken: String? = nil
    ) async throws -> Data {
        guard let url = URL(string: "\(supabaseURL)/functions/v1/\(function)") else {
            throw EdgeFunctionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "apikey")

        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }

        if !body.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw EdgeFunctionError.httpError(-1)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = errorBody["error"] as? String {
                throw EdgeFunctionError.serverError(errorMsg)
            }
            throw EdgeFunctionError.httpError(httpResponse.statusCode)
        }

        return data
    }

    static func invokeDecodable<T: Decodable>(
        function: String,
        body: [String: Any] = [:],
        method: String = "POST",
        authToken: String? = nil
    ) async throws -> T {
        let data = try await invoke(function: function, body: body, method: method, authToken: authToken)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    enum Functions {
        static func createCheckoutSession(
            packageId: String,
            depositPercent: Double? = nil,
            pointsToRedeem: Int? = nil,
            authToken: String? = nil
        ) async throws -> CreateCheckoutResponse {
            var body: [String: Any] = ["package_id": packageId]
            if let depositPercent {
                body["deposit_percent"] = depositPercent
            }
            if let pointsToRedeem {
                body["points_to_redeem"] = pointsToRedeem
            }
            let response: CreateCheckoutResponse = try await EdgeFunction.invokeDecodable(
                function: "create-checkout",
                body: body,
                authToken: authToken
            )
            return response
        }

        static func generateItinerary(
            packageId: String,
            clusterInterestsHash: String? = nil,
            authToken: String? = nil
        ) async throws -> ItineraryResponse {
            var body: [String: Any] = ["package_id": packageId]
            if let clusterInterestsHash {
                body["cluster_interests_hash"] = clusterInterestsHash
            }
            let response: ItineraryResponse = try await EdgeFunction.invokeDecodable(
                function: "generate-itinerary",
                body: body,
                authToken: authToken
            )
            return response
        }

        static func createLead(
            packageId: String,
            authToken: String? = nil
        ) async throws -> CreateLeadResponse {
            let response: CreateLeadResponse = try await EdgeFunction.invokeDecodable(
                function: "create-lead",
                body: ["package_id": packageId],
                authToken: authToken
            )
            return response
        }

        static func aiQualifyLead(
            leadId: String,
            conversationId: String,
            latestMessage: String,
            authToken: String? = nil
        ) async throws -> QualifyLeadResponse {
            let response: QualifyLeadResponse = try await EdgeFunction.invokeDecodable(
                function: "ai-qualify-lead",
                body: [
                    "lead_id": leadId,
                    "conversation_id": conversationId,
                    "latest_message": latestMessage
                ],
                authToken: authToken
            )
            return response
        }

        static func createChatPayment(
            conversationId: String,
            amount: Double,
            currency: String = "MXN",
            concept: String,
            orderId: String? = nil,
            authToken: String? = nil
        ) async throws -> ChatPaymentResponse {
            var body: [String: Any] = [
                "conversation_id": conversationId,
                "amount": amount,
                "currency": currency,
                "concept": concept
            ]
            if let orderId {
                body["order_id"] = orderId
            }
            let response: ChatPaymentResponse = try await EdgeFunction.invokeDecodable(
                function: "create-chat-payment",
                body: body,
                authToken: authToken
            )
            return response
        }

        static func manageSubscription(
            action: String,
            plan: String? = nil,
            billingCycle: String? = nil,
            authToken: String? = nil
        ) async throws -> SubscriptionResponse {
            var body: [String: Any] = ["action": action]
            if let plan {
                body["plan"] = plan
            }
            if let billingCycle {
                body["billing_cycle"] = billingCycle
            }
            let response: SubscriptionResponse = try await EdgeFunction.invokeDecodable(
                function: "manage-subscription",
                body: body,
                authToken: authToken
            )
            return response
        }

        static func presignedUrl(
            filename: String,
            authToken: String? = nil
        ) async throws -> PresignedUrlResponse {
            let response: PresignedUrlResponse = try await EdgeFunction.invokeDecodable(
                function: "presigned-url",
                body: ["filename": filename],
                authToken: authToken
            )
            return response
        }
    }
}

enum EdgeFunctionError: LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingError(String)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Edge Function URL"
        case .httpError(let code):
            return "Edge Function returned HTTP \(code)"
        case .decodingError(let detail):
            return "Failed to decode Edge Function response: \(detail)"
        case .serverError(let message):
            return message
        }
    }
}

struct CreateCheckoutResponse: Codable, Sendable {
    let id: String
    let url: String
    let amountTotal: Double
    let currency: String
    let platformFee: Double
    let agencyCommission: Double
    let commissionRate: Double
    let holdId: String?
    let pointsRedeemed: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case amountTotal = "amount_total"
        case currency
        case platformFee = "platform_fee"
        case agencyCommission = "agency_commission"
        case commissionRate = "commission_rate"
        case holdId = "hold_id"
        case pointsRedeemed = "points_redeemed"
    }
}

struct ItineraryResponse: Codable, Sendable {
    let title: String
    let totalDays: Int
    let description: String?
    let days: [ItineraryDay]

    enum CodingKeys: String, CodingKey {
        case title
        case totalDays = "totalDays"
        case description
        case days
    }

    struct ItineraryDay: Codable, Identifiable, Sendable {
        let dayNumber: Int
        let title: String
        let activities: [ItineraryActivity]

        enum CodingKeys: String, CodingKey {
            case dayNumber = "dayNumber"
            case title
            case activities
        }

        var id: Int { dayNumber }
    }

    struct ItineraryActivity: Codable, Identifiable, Sendable {
        let time: String
        let description: String
        let location: String?

        var id: String { "\(time)-\(description)" }
    }
}

struct CreateLeadResponse: Codable, Sendable {
    let leadId: String
    let conversationId: String
    let assignedTo: String

    enum CodingKeys: String, CodingKey {
        case leadId = "lead_id"
        case conversationId = "conversation_id"
        case assignedTo = "assigned_to"
    }
}

struct QualifyLeadResponse: Codable, Sendable {
    let reply: String
    let extractedFields: [String: String]?
    let shouldTransferToHuman: Bool
    let qualificationCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case reply
        case extractedFields = "extracted_fields"
        case shouldTransferToHuman = "should_transfer_to_human"
        case qualificationCompleted = "qualification_completed"
    }
}

struct ChatPaymentResponse: Codable, Sendable {
    let url: String
    let stripeSessionId: String
    let amount: Double
    let currency: String
    let commissionApplied: Double
    let commissionRate: Double

    enum CodingKeys: String, CodingKey {
        case url
        case stripeSessionId = "stripe_session_id"
        case amount
        case currency
        case commissionApplied = "commission_applied"
        case commissionRate = "commission_rate"
    }
}

struct SubscriptionResponse: Codable, Sendable {
    let url: String?
    let plan: String?
    let billingCycle: String?
    let previousPlan: String?

    enum CodingKeys: String, CodingKey {
        case url
        case plan
        case billingCycle = "billing_cycle"
        case previousPlan = "previous_plan"
    }
}

struct PresignedUrlResponse: Codable, Sendable {
    let signedUrl: String
    let path: String

    enum CodingKeys: String, CodingKey {
        case signedUrl = "signedUrl"
        case path
    }
}
