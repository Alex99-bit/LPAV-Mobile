import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Group {
            switch authManager.authenticationState {
            case .loading:
                LaunchScreenView()
            case .unauthenticated:
                LoginView()
            case .requiresBiometric:
                BiometricUnlockView()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.authenticationState)
    }
}

struct BiometricUnlockView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            Color.lpavBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: BiometricAuth.shared.biometryName == "Face ID" ? "faceid" : "touchid")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryGreen)

                Text("Unlock with \(BiometricAuth.shared.biometryName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.lpavText)

                LPAVButton(
                    title: "Unlock",
                    icon: BiometricAuth.shared.biometryName == "Face ID" ? "faceid" : "touchid",
                    isLoading: isAuthenticating
                ) {
                    isAuthenticating = true
                    Task {
                        let success = await authManager.biometricAuthenticate()
                        isAuthenticating = false
                    }
                }
                .controlSize(.extraLarge)

                Button("Sign Out") {
                    Task { await authManager.signOut() }
                }
                .foregroundColor(.lpavSecondaryText)
            }
            .padding()
        }
    }
}

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color.primaryGreen.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "airplane.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)

                Text("LPAV Market")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                ProgressView()
                    .tint(.white)
                    .padding(.top, 8)
            }
        }
    }
}

struct MainTabView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var marketplaceVM = HomeViewModel()
    @State private var checkoutVM = CheckoutViewModel()
    @State private var walletVM = WalletViewModel()
    @State private var chatVM = ChatViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
                    .environment(marketplaceVM)
            }
            .tabItem {
                Label("Explore", systemImage: "magnifyingglass")
            }
            .tag(0)

            NavigationStack {
                WishlistView()
                    .environment(marketplaceVM)
            }
            .tabItem {
                Label("Saved", systemImage: "heart")
            }
            .tag(1)

            NavigationStack {
                CartView()
                    .environment(checkoutVM)
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
            }
            .badge(checkoutVM.packageIds.count)
            .tag(2)

            NavigationStack {
                ChatListView()
                    .environment(chatVM)
            }
            .tabItem {
                Label("Chat", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(3)

            NavigationStack {
                WalletView()
                    .environment(walletVM)
            }
            .tabItem {
                Label("Wallet", systemImage: "wallet.pass")
            }
            .tag(4)
        }
        .tint(.primaryGreen)
        .task {
            await marketplaceVM.loadPackages()
            await marketplaceVM.loadFeatured()
            await marketplaceVM.loadWishlist()
            await checkoutVM.loadCartPackages()
        }
    }
}

struct WalletView: View {
    @Environment(WalletViewModel.self) private var walletVM

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PointsBalanceBadge(
                    balance: walletVM.pointsBalance,
                    tier: walletVM.tier
                )

                LPAVCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Points Value")
                            .font(.subheadline)
                            .foregroundColor(.lpavSecondaryText)
                        Text(walletVM.pointsValue, format: .currency(code: "MXN"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.lpavText)
                    }
                }

                LPAVCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(.lpavText)

                        if walletVM.transactions.isEmpty {
                            LPAVEmptyState(
                                icon: "tray",
                                title: "No Transactions",
                                message: "Your points transaction history will appear here"
                            )
                        } else {
                            ForEach(walletVM.transactions) { transaction in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.reason.capitalized)
                                            .font(.subheadline)
                                            .foregroundColor(.lpavText)
                                        Text(transaction.createdAt.toDateFromISO()?.timeAgo ?? "")
                                            .font(.caption)
                                            .foregroundColor(.lpavSecondaryText)
                                    }
                                    Spacer()
                                    Text("\(transaction.points > 0 ? "+" : "")\(transaction.points)")
                                        .font(.headline)
                                        .foregroundColor(transaction.points > 0 ? .primaryGreen : .red)
                                }
                                .padding(.vertical, 4)

                                if transaction.id != walletVM.transactions.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.lpavBackground)
        .navigationTitle("Wallet")
        .refreshable {
            await walletVM.loadWallet()
        }
        .task {
            await walletVM.loadWallet()
        }
    }
}
