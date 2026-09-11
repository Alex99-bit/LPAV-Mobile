import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var unreadCount: Int {
        notifications.filter { $0.read != true }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && notifications.isEmpty {
                    LPAVLoadingView(message: "Loading notifications...")
                } else if let error = errorMessage, notifications.isEmpty {
                    LPAVEmptyState(
                        icon: "exclamationmark.triangle",
                        title: "Error",
                        message: error,
                        actionTitle: "Retry"
                    ) {
                        Task { await loadNotifications() }
                    }
                } else if notifications.isEmpty {
                    LPAVEmptyState(
                        icon: "bell",
                        title: "No Notifications",
                        message: "You're all caught up!"
                    )
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Mark All Read") {
                            Task { await markAllAsRead() }
                        }
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                    }
                }
            }
            .refreshable {
                await loadNotifications()
            }
            .task {
                await loadNotifications()
            }
        }
    }

    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(notifications) { notification in
                    notificationRow(notification: notification)
                }
            }
            .padding(16)
        }
    }

    private func notificationRow(notification: AppNotification) -> some View {
        Button {
            Task { await markAsRead(notificationId: notification.id) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: notification.iconName)
                    .font(.title3)
                    .foregroundColor(.lpavText)
                    .frame(width: 40, height: 40)
                    .background(Color.lpavSurface)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.lpavText)
                        .multilineTextAlignment(.leading)

                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.lpavSecondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let createdAt = notification.createdAt {
                        Text(createdAt.toDateFromISO()?.timeAgo ?? "")
                            .font(.caption2)
                            .foregroundColor(.lpavSecondaryText)
                    }
                }

                Spacer()

                if notification.read != true {
                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(12)
            .background(notification.read == true ? Color.lpavCard : Color.primaryGreen.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(notification.read == true ? Color.lpavSurface : Color.primaryGreen.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func loadNotifications() async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        isLoading = true
        do {
            notifications = try await APIRouter.Notifications.fetchAll(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func markAsRead(notificationId: String) async {
        do {
            try await APIRouter.Notifications.markAsRead(notificationId: notificationId)
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index] = AppNotification(
                    notificationId: notifications[index].notificationId,
                    userId: notifications[index].userId,
                    type: notifications[index].type,
                    title: notifications[index].title,
                    message: notifications[index].message,
                    metadata: notifications[index].metadata,
                    read: true,
                    createdAt: notifications[index].createdAt
                )
            }
        } catch {
            print("Failed to mark as read: \(error)")
        }
    }

    private func markAllAsRead() async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        do {
            for notification in notifications where notification.read != true {
                try await APIRouter.Notifications.markAsRead(notificationId: notification.id)
            }
            notifications = try await APIRouter.Notifications.fetchAll(userId: userId)
        } catch {
            print("Failed to mark all as read: \(error)")
        }
    }
}
