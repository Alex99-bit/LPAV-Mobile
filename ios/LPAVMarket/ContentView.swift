import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView()
            }

            Tab("Orders", systemImage: "bag.fill", value: 1) {
                OrdersView()
            }

            Tab("Wallet", systemImage: "creditcard.fill", value: 2) {
                WalletView()
            }

            Tab("Chat", systemImage: "bubble.left.and.bubble.right.fill", value: 3) {
                ChatListView()
            }

            Tab("Profile", systemImage: "person.fill", value: 4) {
                ProfileView()
            }
        }
        .tint(.primaryGreen)
    }
}
