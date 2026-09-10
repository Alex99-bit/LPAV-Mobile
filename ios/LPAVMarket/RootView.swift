import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Group {
            if authManager.isLoading {
                LoadingView(message: "Loading...")
            } else if authManager.isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
        .task {
            await authManager.restoreSession()
        }
    }
}
