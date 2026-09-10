import SwiftUI

struct FiltersView: View {
    @Binding var selectedRegion: String?
    @Binding var selectedDepartureCity: String?
    @Binding var priceRange: ClosedRange<Double>
    var onApply: () -> Void
    var onClear: () -> Void

    @State private var localRegion: String?
    @State private var localCity: String?
    @State private var localMinPrice: Double = 0
    @State private var localMaxPrice: Double = 50000

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

    var body: some View {
        NavigationStack {
            Form {
                Section("Region") {
                    ForEach(regions, id: \.self) { region in
                        Button {
                            localRegion = region == "All Regions" ? nil : region
                        } label: {
                            HStack {
                                Text(region)
                                    .foregroundStyle(brandText)
                                Spacer()
                                if (region == "All Regions" && localRegion == nil) || localRegion == region {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(brandPrimary)
                                }
                            }
                        }
                    }
                }

                Section("Departure City") {
                    ForEach(departureCities, id: \.self) { city in
                        Button {
                            localCity = city == "All Cities" ? nil : city
                        } label: {
                            HStack {
                                Text(city)
                                    .foregroundStyle(brandText)
                                Spacer()
                                if (city == "All Cities" && localCity == nil) || localCity == city {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(brandPrimary)
                                }
                            }
                        }
                    }
                }

                Section("Price Range (MXN)") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("$\(Int(localMinPrice).formatted())")
                                .font(.subheadline)
                                .foregroundStyle(brandText)
                            Spacer()
                            Text("$\(Int(localMaxPrice).formatted())")
                                .font(.subheadline)
                                .foregroundStyle(brandText)
                        }

                        Slider(value: $localMinPrice, in: 0...localMaxPrice, step: 500)
                        Slider(value: $localMaxPrice, in: localMinPrice...50000, step: 500)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        localRegion = nil
                        localCity = nil
                        localMinPrice = 0
                        localMaxPrice = 50000
                        onClear()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        selectedRegion = localRegion
                        selectedDepartureCity = localCity
                        priceRange = localMinPrice...localMaxPrice
                        onApply()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                localRegion = selectedRegion
                localCity = selectedDepartureCity
                localMinPrice = priceRange.lowerBound
                localMaxPrice = priceRange.upperBound
            }
        }
    }
}
