import SwiftUI

struct ChatConversation: Codable, Identifiable, Sendable {
    let id: String
    let recipientName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case recipientName = "recipient_name"
    }
}

struct ChatListView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var conversations: [ConversationRoute] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if conversations.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "No conversations",
                        message: "Start a chat with an agency to begin"
                    )
                } else {
                    List(conversations) { conversation in
                        NavigationLink(value: conversation) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(brandPrimary)
                                Text(conversation.name)
                                    .font(.subheadline)
                                    .foregroundStyle(brandText)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
            .navigationDestination(for: ConversationRoute.self) { route in
                ChatView(conversationId: route.id, recipientName: route.name)
                    .environment(authManager)
            }
            .task {
                isLoading = true
                do {
                    let userId = AuthManager.currentUserId
                    let response: [ChatConversation] = try await supabase
                        .from("chat_conversations")
                        .select()
                        .or("user1_id.eq.\(userId),user2_id.eq.\(userId)")
                        .execute()
                        .value
                    conversations = response.map {
                        ConversationRoute(id: $0.id, name: $0.recipientName ?? "Unknown")
                    }
                } catch {}
                isLoading = false
            }
        }
    }
}
