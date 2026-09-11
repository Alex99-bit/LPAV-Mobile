import SwiftUI
import Supabase

@MainActor
@Observable
final class HomeViewModel {
    var packages: [TravelPackage] = []
    var featuredPackages: [TravelPackage] = []
    var wishlistPackageIds: [String] = []
    var isLoading = false
    var isLoadingMore = false
    var searchError: String?
    var selectedRegion: String?
    var minPrice: Double?
    var maxPrice: Double?
    var searchQuery = ""
    var currentPage = 1
    var hasMorePages = true
    var geminiSuggestions: [String] = []
    var isGeminiSearching = false

    private let pageSize = 20

    func loadPackages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            packages = try await APIRouter.Packages.fetchAll(
                page: 1,
                limit: pageSize,
                region: selectedRegion,
                minPrice: minPrice,
                maxPrice: maxPrice,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery
            )
            currentPage = 1
            hasMorePages = packages.count >= pageSize
        } catch {
            searchError = error.localizedDescription
        }
    }

    func loadMore() async {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let more = try await APIRouter.Packages.fetchAll(
                page: nextPage,
                limit: pageSize,
                region: selectedRegion,
                minPrice: minPrice,
                maxPrice: maxPrice,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery
            )
            packages.append(contentsOf: more)
            currentPage = nextPage
            hasMorePages = more.count >= pageSize
        } catch {
            print("Failed to load more: \(error)")
        }
    }

    func loadFeatured() async {
        do {
            featuredPackages = try await APIRouter.Packages.fetchFeatured()
        } catch {
            print("Failed to load featured: \(error)")
        }
    }

    func loadWishlist() async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        do {
            let response: [FavoritePackage] = try await supabase.database
                .from("wishlists")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            wishlistPackageIds = response.map(\.packageId)
        } catch {
            print("Failed to load wishlist: \(error)")
        }
    }

    func toggleWishlist(_ packageId: String) async {
        if wishlistPackageIds.contains(packageId) {
            await removeFromWishlist(packageId)
        } else {
            await addToWishlist(packageId)
        }
    }

    func isInWishlist(_ packageId: String) -> Bool {
        wishlistPackageIds.contains(packageId)
    }

    private func addToWishlist(_ packageId: String) async {
        wishlistPackageIds.append(packageId)
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        do {
            try await supabase.database
                .from("wishlists")
                .insert([
                    "user_id": userId,
                    "package_id": packageId
                ])
                .execute()
        } catch {
            print("Failed to add to wishlist: \(error)")
        }
    }

    private func removeFromWishlist(_ packageId: String) async {
        wishlistPackageIds.removeAll { $0 == packageId }
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        do {
            try await supabase.database
                .from("wishlists")
                .delete()
                .eq("user_id", value: userId)
                .eq("package_id", value: packageId)
                .execute()
        } catch {
            print("Failed to remove from wishlist: \(error)")
        }
    }

    func searchWithGemini(_ query: String) async {
        isGeminiSearching = true
        defer { isGeminiSearching = false }

        do {
            let response = try await EdgeFunction.Functions.searchWithGemini(
                query: query,
                context: [
                    "selected_region": selectedRegion as Any,
                    "price_min": minPrice as Any,
                    "price_max": maxPrice as Any
                ]
            )
            geminiSuggestions = response.suggestions ?? []
            searchQuery = query
            await loadPackages()
        } catch {
            searchError = error.localizedDescription
        }
    }

    func clearFilters() {
        selectedRegion = nil
        minPrice = nil
        maxPrice = nil
        searchQuery = ""
    }

    var hasActiveFilters: Bool {
        selectedRegion != nil || minPrice != nil || maxPrice != nil || !searchQuery.isEmpty
    }
}

struct FavoritePackage: Codable, Sendable {
    let packageId: String
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case packageId = "package_id"
        case userId = "user_id"
    }
}
