import Foundation

struct CRMLead: Codable, Identifiable, Sendable {
    let leadId: String
    let tenantId: String
    let travelerUserId: String?
    let packageId: String?
    let assignedTo: String?
    let status: String
    let source: String?
    let priority: String?
    let estimatedBudget: Double?
    let conversationId: String?
    let aiQualificationProgress: Int?
    let aiQualificationCompleted: Bool?
    let notes: String?
    let travelerName: String?
    let travelerEmail: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case leadId = "lead_id"
        case tenantId = "tenant_id"
        case travelerUserId = "traveler_user_id"
        case packageId = "package_id"
        case assignedTo = "assigned_to"
        case status
        case source
        case priority
        case estimatedBudget = "estimated_budget"
        case conversationId = "conversation_id"
        case aiQualificationProgress = "ai_qualification_progress"
        case aiQualificationCompleted = "ai_qualification_completed"
        case notes
        case travelerName = "traveler_name"
        case travelerEmail = "traveler_email"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var id: String { leadId }

    var statusDisplay: String {
        switch status {
        case "new": return "New"
        case "contacted": return "Contacted"
        case "qualified": return "Qualified"
        case "proposal_sent": return "Proposal Sent"
        case "won": return "Won"
        case "lost": return "Lost"
        default: return status.capitalized
        }
    }

    var priorityColor: String {
        switch priority {
        case "high": return "red"
        case "medium": return "orange"
        case "low": return "green"
        default: return "gray"
        }
    }

    init(
        leadId: String,
        tenantId: String,
        travelerUserId: String? = nil,
        packageId: String? = nil,
        assignedTo: String? = nil,
        status: String,
        source: String? = nil,
        priority: String? = nil,
        estimatedBudget: Double? = nil,
        conversationId: String? = nil,
        aiQualificationProgress: Int? = nil,
        aiQualificationCompleted: Bool? = nil,
        notes: String? = nil,
        travelerName: String? = nil,
        travelerEmail: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.leadId = leadId
        self.tenantId = tenantId
        self.travelerUserId = travelerUserId
        self.packageId = packageId
        self.assignedTo = assignedTo
        self.status = status
        self.source = source
        self.priority = priority
        self.estimatedBudget = estimatedBudget
        self.conversationId = conversationId
        self.aiQualificationProgress = aiQualificationProgress
        self.aiQualificationCompleted = aiQualificationCompleted
        self.notes = notes
        self.travelerName = travelerName
        self.travelerEmail = travelerEmail
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
