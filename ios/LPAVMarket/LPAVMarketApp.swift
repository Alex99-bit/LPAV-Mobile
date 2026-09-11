import SwiftUI

@main
struct LPAVMarketApp: App {
    @State private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .task {
                    await authManager.restoreSession()
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        if url.scheme == "lpavmarket" {
            deepLinkRouter.handleScheme(components)
        } else {
            deepLinkRouter.handleUniversalLink(components)
        }
    }
}

@MainActor
final class DeepLinkRouter {
    static let shared = DeepLinkRouter()

    func handleScheme(_ components: URLComponents) {
        guard let host = components.host else { return }
        switch host {
        case "checkout":
            if let packageId = components.queryItems?.first(where: { $0.name == "package_id" })?.value {
                CartManager.shared.addPackage(packageId)
            }
        case "chat":
            if let conversationId = components.queryItems?.first(where: { $0.name == "conversation_id" })?.value {
                NotificationCenter.default.post(
                    name: .navigateToChat,
                    object: nil,
                    userInfo: ["conversation_id": conversationId]
                )
            }
        case "flyer":
            if let packageId = components.queryItems?.first(where: { $0.name == "package_id" })?.value {
                NotificationCenter.default.post(
                    name: .navigateToPackage,
                    object: nil,
                    userInfo: ["package_id": packageId]
                )
            }
        default:
            break
        }
    }

    func handleUniversalLink(_ components: URLComponents) {
        let path = components.path
        if path.hasPrefix("/checkout") {
            if let packageId = components.queryItems?.first(where: { $0.name == "package_id" })?.value {
                CartManager.shared.addPackage(packageId)
            }
        } else if path.hasPrefix("/chat") {
            let conversationId = path.components(separatedBy: "/").last
            if let conversationId {
                NotificationCenter.default.post(
                    name: .navigateToChat,
                    object: nil,
                    userInfo: ["conversation_id": conversationId]
                )
            }
        } else if path.hasPrefix("/flyer") {
            let packageId = path.components(separatedBy: "/").last
            if let packageId {
                NotificationCenter.default.post(
                    name: .navigateToPackage,
                    object: nil,
                    userInfo: ["package_id": packageId]
                )
            }
        }
    }
}

extension Notification.Name {
    static let navigateToChat = Notification.Name("navigateToChat")
    static let navigateToPackage = Notification.Name("navigateToPackage")
    static let appWillEnterForeground = Notification.Name("appWillEnterForeground")
}
