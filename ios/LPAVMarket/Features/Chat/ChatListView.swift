import SwiftUI

struct ChatListView: View {
    @Environment(ChatViewModel.self) private var vm

    var body: some View {
        Group {
            if vm.isLoading {
                LPAVLoadingView(message: "Loading conversations...")
            } else if vm.conversations.isEmpty {
                LPAVEmptyState(
                    icon: "bubble.left.and.bubble.right",
                    title: "No Conversations",
                    message: "Chat with agencies about packages you're interested in",
                    actionTitle: "Browse Packages"
                ) {
                    NotificationCenter.default.post(name: .navigateToPackage, object: nil)
                }
            } else {
                List {
                    ForEach(vm.conversations) { conversation in
                        NavigationLink(destination: ChatView(conversationId: conversation.conversationId)) {
                            conversationRow(conversation)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Chat")
        .refreshable {
            await vm.loadConversations()
        }
        .task {
            if vm.conversations.isEmpty {
                await vm.loadConversations()
            }
        }
    }

    private func conversationRow(_ conversation: ChatConversation) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(conversation.status == "ai_active" ? Color.primaryGreen.opacity(0.2) : Color.lightBlue.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: conversation.status == "ai_active" ? "brain.head.profile" : "person.fill")
                        .font(.title3)
                        .foregroundColor(conversation.status == "ai_active" ? .primaryGreen : .lightBlue)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.status == "ai_active" ? "AI Assistant" : "Travel Agency")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.lpavText)

                    if conversation.status == "ai_active" {
                        LPAVBadge(text: "AI", color: .primaryGreen)
                    }
                }

                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage)
                        .font(.caption)
                        .foregroundColor(.lpavSecondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let date = conversation.updatedAt?.toDateFromISO() {
                Text(date.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.lpavSecondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}
