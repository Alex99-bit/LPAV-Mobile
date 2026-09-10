import SwiftUI

@Observable
final class HomeViewModel {
    var packages: [TravelPackage] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedRegion: String?
    var selectedDepartureCity: String?
    var priceRange: ClosedRange<Double> = 0...50000
    var showFilters = false

    let regions = [
        "All Regions", "Caribbean", "Pacific Coast", "Central Highlands",
        "Yucatan Peninsula", "Baja California", "Oaxaca Coast", "Riviera Maya",
        "Lake Chapala", "Colonial Cities", "Copper Canyon", "Huasteca",
        "Sierra Norte", "Costa Chica", "Ixtapa-Zihuatanejo", "San Miguel de Allende"
    ]

    let departureCities = [
        "All Cities", "Mexico City", "Guadalajara", "Monterrey", "Cancun",
        "Puerto Vallarta", "Tijuana", "Leon", "Merida", "Oaxaca",
        "Puebla", "Queretaro", "San Luis Potosi", "Aguascalientes",
        "Morelia", "Toluca", "Veracruz", "Tampico", "Mazatlan",
        "Hermosillo", "Chihuahua", "Durango", "Zacatecas", "Ciudad Juarez"
    ]

    var filteredPackages: [TravelPackage] {
        var result = packages

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.region.localizedCaseInsensitiveContains(searchText) ||
                $0.departureCity.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let region = selectedRegion, region != "All Regions" {
            result = result.filter { $0.region == region }
        }

        if let city = selectedDepartureCity, city != "All Cities" {
            result = result.filter { $0.departureCity == city }
        }

        result = result.filter {
            $0.priceMxn >= priceRange.lowerBound && $0.priceMxn <= priceRange.upperBound
        }

        return result
    }

    var hasActiveFilters: Bool {
        selectedRegion != nil || selectedDepartureCity != nil ||
        priceRange != 0...50000 || !searchText.isEmpty
    }

    func loadPackages() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response: [TravelPackage] = try await supabase
                .from("travel_packages")
                .select()
                .eq("status", value: "published")
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            packages = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearFilters() {
        selectedRegion = nil
        selectedDepartureCity = nil
        priceRange = 0...50000
        searchText = ""
    }
}
