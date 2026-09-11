import SwiftUI

struct WishlistView: View {
    @Environment(HomeViewModel.self) private var vm
    @State private var wishlistPackages: [TravelPackage] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LPAVLoadingView(message: "Loading saved flyers...")
            } else if wishlistPackages.isEmpty {
                LPAVEmptyState(
                    icon: "heart",
                    title: "No Saved Flyers",
                    message: "Tap the heart icon on any package to save it here for later",
                    actionTitle: "Explore Packages"
                ) {
                    NotificationCenter.default.post(name: .navigateToPackage, object: nil)
                }
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 16
                    ) {
                        ForEach(wishlistPackages) { package in
                            NavigationLink(destination: PackageDetailView(package: package)) {
                                FlyerCardView(package: package, size: .full)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.lpavBackground)
            }
        }
        .navigationTitle("Saved Flyers")
        .refreshable {
            await vm.loadWishlist()
            await loadWishlistPackages()
        }
        .task {
            await vm.loadWishlist()
            await loadWishlistPackages()
        }
    }

    private func loadWishlistPackages() async {
        isLoading = true
        var loaded: [TravelPackage] = []
        for id in vm.wishlistPackageIds {
            if let package = try? await APIRouter.Packages.fetchPackage(packageId: id) {
                loaded.append(package)
            }
        }
        wishlistPackages = loaded
        isLoading = false
    }
}
