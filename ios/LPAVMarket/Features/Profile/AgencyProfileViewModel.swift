import SwiftUI

@Observable
final class AgencyProfileViewModel {
    var agency: AgencyTenant?
    var packages: [TravelPackage] = []
    var reviews: [PackageReview] = []
    var isLoading = false
    var errorMessage: String?

    func loadAgency(agencyId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let agencyResponse: [AgencyTenant] = try await supabase
                .from("tenants")
                .select()
                .eq("id", value: agencyId)
                .execute()
                .value
            agency = agencyResponse.first

            let packageResponse: [TravelPackage] = try await supabase
                .from("travel_packages")
                .select()
                .eq("tenant_id", value: agencyId)
                .eq("status", value: "published")
                .order("created_at", ascending: false)
                .limit(20)
                .execute()
                .value
            packages = packageResponse
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
