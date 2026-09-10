import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.notifications.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.loadNotifications() }
                    }
                } else if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        icon: "bell",
                        title: "No notifications",
                        message: "You're all caught up!"
                    )
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if viewModel.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Mark All Read") {
                            Task { await viewModel.markAllAsRead() }
                        }
                        .font(.caption)
                        .foregroundStyle(brandPrimary)
                    }
                }
            }
            .refreshable {
                await viewModel.loadNotifications()
            }
            .task {
                await viewModel.loadNotifications()
            }
        }
    }

    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.notifications) { notification in
                    notificationRow(notification: notification)
                }
            }
            .padding(16)
        }
    }

    private func notificationRow(notification: AppNotification) -> some View {
        Button {
            Task { await viewModel.markAsRead(notificationId: notification.id) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: iconForType(notification.type))
                    .font(.title3)
                    .foregroundStyle(colorForType(notification.type))
                    .frame(width: 40, height: 40)
                    .background(colorForType(notification.type).opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(brandText)
                        .multilineTextAlignment(.leading)

                    Text(notification.message)
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(notification.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(brandSubtext)
                }

                Spacer()

                if !notification.isRead {
                    Circle()
                        .fill(brandPrimary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(12)
            .background(notification.isRead ? Color.brandCard : brandPrimary.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(notification.isRead ? brandBorder : brandPrimary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForType(_ type: NotificationType) -> String {
        switch type {
        case .orderUpdate: return "bag.fill"
        case .paymentReceived: return "checkmark.circle.fill"
        case .paymentDue: return "exclamationmark.circle.fill"
        case .chatMessage: return "bubble.left.fill"
        case .packageUpdate: return "arrow.triangle.2.circlepath"
        case .promotion: return "sparkles"
        case .system: return "info.circle.fill"
        }
    }

    private func colorForType(_ type: NotificationType) -> Color {
        switch type {
        case .orderUpdate: return brandPrimary
        case .paymentReceived: return brandSuccess
        case .paymentDue: return brandAccent
        case .chatMessage: return .purple
        case .packageUpdate: return brandPrimary
        case .promotion: return brandAccent
        case .system: return .gray
        }
    }
}
