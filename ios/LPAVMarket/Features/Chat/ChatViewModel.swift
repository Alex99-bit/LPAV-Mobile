import SwiftUI

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var isLoading = false
    var errorMessage: String?
    var newMessageText = ""

    func loadMessages(conversationId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response: [ChatMessage] = try await supabase
                .from("chat_messages")
                .select()
                .eq("conversation_id", value: conversationId)
                .order("created_at", ascending: true)
                .limit(100)
                .execute()
                .value
            messages = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendMessage(conversationId: String, senderName: String) async {
        let text = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        newMessageText = ""

        do {
            let messageData: [String: AnyJSON] = [
                "conversation_id": AnyJSON(conversationId),
                "sender_id": AnyJSON(AuthManager.currentUserId),
                "sender_name": AnyJSON(senderName),
                "content": AnyJSON(text),
                "message_type": AnyJSON("text")
            ]
            try await supabase
                .from("chat_messages")
                .insert(messageData)
                .execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func listenForMessages(conversationId: String) {
        Task {
            let channel = supabase.realtime.channel("chat-\(conversationId)")
            let changes = channel.postgresChanges(
                action: .insert,
                schema: "public",
                table: "chat_messages"
            )
            try await channel.subscribe()
            for await change in changes {
                if let record = change.record,
                   let payload = try? JSONDecoder().decode(ChatMessage.self, from: JSONSerialization.data(withJSONObject: record)) {
                    if !messages.contains(where: { $0.id == payload.id }) {
                        messages.append(payload)
                    }
                }
            }
        }
    }
}
