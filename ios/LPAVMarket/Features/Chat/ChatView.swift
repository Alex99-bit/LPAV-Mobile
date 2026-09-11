import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) private var vm
    let conversationId: String
    @State private var scrolledToBottom = false

    var body: some View {
        VStack(spacing: 0) {
            messageList
            messageInput
        }
        .background(Color.lpavBackground)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadMessages(conversationId: conversationId)
        }
        .onDisappear {
            vm.unsubscribe()
        }
    }

    private var messageList: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: message.senderId == AuthManager.shared.currentUser?.profile.id
                        )
                        .id(message.messageId)
                    }
                }
                .padding()
            }
            .onChange(of: vm.messages.count) { _, _ in
                if let lastMessage = vm.messages.last {
                    withAnimation {
                        scrollProxy.scrollTo(lastMessage.messageId, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var messageInput: some View {
        HStack(spacing: 8) {
            TextField("Type a message...", text: Binding(
                get: { vm.newMessageText },
                set: { vm.newMessageText = $0 }
            ))
            .textFieldStyle(.plain)
            .padding(10)
            .background(Color.lpavSurface)
            .cornerRadius(20)

            Button {
                Task { await vm.sendMessage() }
            } label: {
                if vm.isSending {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
            }
            .foregroundColor(.primaryGreen)
            .disabled(vm.newMessageText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isSending)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.lpavCard)
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom) {
            if isCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if message.isSystem == true {
                    systemMessageView
                } else {
                    userMessageView
                }
            }

            if !isCurrentUser { Spacer(minLength: 60) }
        }
    }

    private var userMessageView: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
            if !isCurrentUser {
                Text(getSenderName())
                    .font(.caption2)
                    .foregroundColor(.lpavSecondaryText)
                    .padding(.leading, 4)
            }

            VStack(alignment: .leading, spacing: 2) {
                if message.isCensored == true {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.orange)
                        Text("This message was flagged and removed")
                            .font(.caption)
                            .foregroundColor(.lpavSecondaryText)
                    }
                } else {
                    Text(message.messageText)
                        .font(.subheadline)
                        .foregroundColor(isCurrentUser ? .white : .lpavText)
                }

                if let createdAt = message.createdAt {
                    Text(createdAt.toDateFromISO()?.timeAgo ?? createdAt)
                        .font(.caption2)
                        .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .lpavSecondaryText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isCurrentUser ? Color.primaryGreen : Color.lpavSurface)
            .cornerRadius(16, corners: isCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
        }
    }

    private var systemMessageView: some View {
        HStack {
            Spacer()
            Text(message.messageText)
                .font(.caption)
                .foregroundColor(.lpavSecondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.lpavSurface)
                .cornerRadius(12)
            Spacer()
        }
    }

    private func getSenderName() -> String {
        if message.senderId == "ai_assistant" { return "AI Assistant" }
        if message.senderId.hasPrefix("agent_") { return "Agent" }
        return message.senderId.truncatedAddress
    }
}
