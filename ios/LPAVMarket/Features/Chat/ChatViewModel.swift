import SwiftUI
import Supabase

@MainActor
@Observable
final class ChatViewModel {
    var conversations: [ChatConversation] = []
    var messages: [ChatMessage] = []
    var newMessageText = ""
    var isLoading = false
    var isLoadingMessages = false
    var isSending = false
    var errorMessage: String?
    var activeConversationId: String?

    private var channel: RealtimeChannel?
    private var messagesTask: Task<Void, Never>?

    func loadConversations() async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            conversations = try await APIRouter.Chat.fetchConversations(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMessages(conversationId: String) async {
        activeConversationId = conversationId
        isLoadingMessages = true
        defer { isLoadingMessages = false }

        do {
            messages = try await APIRouter.Chat.fetchMessages(conversationId: conversationId)
            messages.reverse()
        } catch {
            errorMessage = error.localizedDescription
        }

        await subscribeToMessages(conversationId: conversationId)
    }

    func subscribeToMessages(conversationId: String) async {
        messagesTask?.cancel()
        channel?.unsubscribe()

        do {
            let ch = try await APIRouter.Chat.subscribeToMessages(conversationId: conversationId)

            let stream = ch.postgresChanges(InsertAction.self, schema: "public", table: "messages")

            channel = ch

            messagesTask = Task {
                for await change in stream {
                    if let record = change.record,
                       let messageId = record["message_id"] as? String,
                       let conversationId = record["conversation_id"] as? String,
                       conversationId == activeConversationId {
                        let message = ChatMessage(
                            messageId: messageId,
                            conversationId: conversationId,
                            senderId: record["sender_id"] as? String ?? "",
                            messageText: record["message_text"] as? String ?? "",
                            createdAt: record["created_at"] as? String,
                            isSystem: record["is_system"] as? Bool,
                            isCensored: record["is_censored"] as? Bool,
                            censorshipReason: record["censorship_reason"] as? String,
                            messageType: record["message_type"] as? String
                        )
                        await MainActor.run {
                            self.messages.append(message)
                        }
                    }
                }
            }

            try await channel?.subscribe()
        } catch {
            print("Failed to subscribe to messages: \(error)")
        }
    }

    func sendMessage() async {
        guard let conversationId = activeConversationId,
              let userId = AuthManager.shared.currentUser?.profile.id,
              !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSending = true
        let message = ChatMessage(
            conversationId: conversationId,
            senderId: userId,
            messageText: newMessageText
        )

        do {
            let sent = try await APIRouter.Chat.sendMessage(message)
            messages.append(sent)
            newMessageText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }

    func startConversation(tenantId: String, packageId: String) async -> String? {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return nil }
        do {
            let response: [ChatConversation] = try await supabase.database
                .from("conversations")
                .insert([
                    "traveler_user_id": userId,
                    "tenant_id": tenantId,
                    "package_id": packageId,
                    "status": "active"
                ])
                .select()
                .execute()
                .value

            if let conversation = response.first {
                conversations.insert(conversation, at: 0)
                return conversation.conversationId
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
    }

    func unsubscribe() {
        messagesTask?.cancel()
        channel?.unsubscribe()
        channel = nil
        activeConversationId = nil
    }

    func getSenderName(for senderId: String) -> String {
        guard let userId = AuthManager.shared.currentUser?.profile.id else {
            return senderId.truncatedAddress
        }
        if senderId == userId {
            return AuthManager.shared.currentUser?.profile.fullName ?? "You"
        }
        if senderId == "ai_assistant" {
            return "AI Assistant"
        }
        return senderId.truncatedAddress
    }
}

protocol InsertAction: PostgresAction {
    associatedtype Record
    var record: [String: AnyJSON]? { get }
}

enum AnyJSON: Codable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case object([String: AnyJSON])
    case array([AnyJSON])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if container.decodeNil() {
            self = .null
        } else if let object = try? container.decode([String: AnyJSON].self) {
            self = .object(object)
        } else if let array = try? container.decode([AnyJSON].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown JSON type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .null: try container.encodeNil()
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        }
    }
}
