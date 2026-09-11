import SwiftUI

struct PriceFilterView: View {
    @Environment(HomeViewModel.self) private var vm
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 100000
    @State private var currency = "MXN"
    @Environment(\.dismiss) private var dismiss

    private let currencies = ["MXN", "USD", "EUR"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Currency", selection: $currency) {
                    ForEach(currencies, id: \.self) { cur in
                        Text(cur).tag(cur)
                    }
                }
                .pickerStyle(.segmented)

                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Minimum")
                                .font(.subheadline)
                                .foregroundColor(.lpavSecondaryText)
                            Spacer()
                            Text(minPrice, format: .currency(code: currency))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.lpavText)
                        }
                        Slider(value: $minPrice, in: 0...maxPrice, step: 1000)
                            .tint(.primaryGreen)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Maximum")
                                .font(.subheadline)
                                .foregroundColor(.lpavSecondaryText)
                            Spacer()
                            Text(maxPrice, format: .currency(code: currency))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.lpavText)
                        }
                        Slider(value: $maxPrice, in: minPrice...200000, step: 1000)
                            .tint(.primaryGreen)
                    }
                }
                .padding()
                .background(Color.lpavSurface)
                .cornerRadius(12)

                Spacer()

                VStack(spacing: 8) {
                    LPAVButton(title: "Apply Filters") {
                        vm.minPrice = minPrice > 0 ? minPrice : nil
                        vm.maxPrice = maxPrice < 200000 ? maxPrice : nil
                        Task { await vm.loadPackages() }
                        dismiss()
                    }

                    Button("Clear Price Filters") {
                        vm.minPrice = nil
                        vm.maxPrice = nil
                        minPrice = 0
                        maxPrice = 100000
                        Task { await vm.loadPackages() }
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("Price Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                minPrice = vm.minPrice ?? 0
                maxPrice = vm.maxPrice ?? 100000
            }
        }
    }
}
