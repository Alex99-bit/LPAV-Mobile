import SwiftUI

@Observable
final class NotificationsViewModel {
    var notifications: [AppNotification] = []
    var isLoading = false
    var errorMessage: String?

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let userId = AuthManager.currentUserId
            let response: [AppNotification] = try await supabase
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            notifications = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(notificationId: String) async {
        do {
            try await supabase
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: notificationId)
                .execute()
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index] = AppNotification(
                    id: notifications[index].id,
                    userId: notifications[index].userId,
                    type: notifications[index].type,
                    title: notifications[index].title,
                    message: notifications[index].message,
                    referenceId: notifications[index].referenceId,
                    referenceType: notifications[index].referenceType,
                    isRead: true,
                    createdAt: notifications[index].createdAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() async {
        do {
            let userId = AuthManager.currentUserId
            try await supabase
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("is_read", value: false)
                .execute()
            notifications = notifications.map { notif in
                AppNotification(
                    id: notif.id,
                    userId: notif.userId,
                    type: notif.type,
                    title: notif.title,
                    message: notif.message,
                    referenceId: notif.referenceId,
                    referenceType: notif.referenceType,
                    isRead: true,
                    createdAt: notif.createdAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
