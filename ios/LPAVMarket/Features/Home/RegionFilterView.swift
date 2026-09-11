import SwiftUI

struct RegionFilterView: View {
    @Environment(HomeViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    private let regions = [
        "Caribbean", "Europe", "Southeast Asia", "North America",
        "South America", "Central America", "Middle East", "Africa",
        "East Asia", "Oceania", "South Asia", "North Africa"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if let selected = vm.selectedRegion {
                        HStack {
                            Text("Selected: \(selected)")
                                .font(.subheadline)
                                .foregroundColor(.primaryGreen)
                            Spacer()
                            Button("Clear") {
                                vm.selectedRegion = nil
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(regions, id: \.self) { region in
                            Button {
                                vm.selectedRegion = vm.selectedRegion == region ? nil : region
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.caption)
                                    Text(region)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    if vm.selectedRegion == region {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.primaryGreen)
                                    }
                                }
                                .padding(12)
                                .background(vm.selectedRegion == region ? Color.primaryGreen.opacity(0.1) : Color.lpavSurface)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            vm.selectedRegion == region ? Color.primaryGreen : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .foregroundColor(.lpavText)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        Task { await vm.loadPackages() }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
