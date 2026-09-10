import SwiftUI

@Observable
final class PackageDetailViewModel {
    var package: TravelPackage?
    var agency: AgencyTenant?
    var reviews: [PackageReview] = []
    var itinerary: String?
    var isLoading = false
    var isGeneratingItinerary = false
    var errorMessage: String?
    var addedToCart = false

    func loadPackage(packageId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: [TravelPackage] = try await supabase
                .from("travel_packages")
                .select()
                .eq("id", value: packageId)
                .execute()
                .value
            package = response.first

            if let tenantId = package?.tenantId {
                let agencyResponse: [AgencyTenant] = try await supabase
                    .from("tenants")
                    .select()
                    .eq("id", value: tenantId)
                    .execute()
                    .value
                agency = agencyResponse.first
            }

            let reviewResponse: [PackageReview] = try await supabase
                .from("package_reviews")
                .select()
                .eq("package_id", value: packageId)
                .order("created_at", ascending: false)
                .limit(20)
                .execute()
                .value
            reviews = reviewResponse
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateItinerary() async {
        guard let package else { return }
        isGeneratingItinerary = true
        defer { isGeneratingItinerary = false }
        do {
            let response: [String: String] = try await supabase.functions
                .invoke("generate-itinerary", body: [
                    "package_id": package.id,
                    "title": package.title,
                    "region": package.region,
                    "duration_days": package.durationDays
                ])
            itinerary = response["itinerary"] ?? "No itinerary generated."
        } catch {
            errorMessage = "Failed to generate itinerary: \(error.localizedDescription)"
        }
    }

    func addToCart() {
        guard let package else { return }
        let cartItem = CartItem(
            id: UUID(),
            packageId: package.id,
            packageTitle: package.title,
            coverImageUrl: package.coverImageUrl,
            region: package.region,
            priceMxn: package.priceMxn,
            pointsPrice: package.pointsPrice,
            quantity: 1
        )
        CartStorage.shared.addItem(cartItem)
        addedToCart = true
    }
}
