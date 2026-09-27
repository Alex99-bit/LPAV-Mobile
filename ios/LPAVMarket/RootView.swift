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
