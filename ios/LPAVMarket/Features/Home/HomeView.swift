import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.packages.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.packages.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.loadPackages() }
                    }
                } else if viewModel.filteredPackages.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No packages found",
                        message: "Try adjusting your filters or search terms"
                    )
                } else {
                    packageList
                }
            }
            .navigationTitle("LPAV Market")
            .searchable(text: $viewModel.searchText, prompt: "Search packages...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showFilters = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            if viewModel.hasActiveFilters {
                                Circle()
                                    .fill(brandAccent)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: CartRoute()) {
                        Image(systemName: "cart")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FiltersView(
                    selectedRegion: $viewModel.selectedRegion,
                    selectedDepartureCity: $viewModel.selectedDepartureCity,
                    priceRange: $viewModel.priceRange,
                    onApply: { viewModel.showFilters = false },
                    onClear: { viewModel.clearFilters() }
                )
            }
            .refreshable {
                await viewModel.loadPackages()
            }
            .task {
                await viewModel.loadPackages()
            }
        }
    }

    private var packageList: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 170, maximum: .infinity), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(viewModel.filteredPackages) { package in
                    NavigationLink(value: PackageRoute(id: package.id)) {
                        PackageCardView(package: package)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationDestination(for: PackageRoute.self) { route in
            PackageDetailView(packageId: route.id)
        }
        .navigationDestination(for: CartRoute.self) { _ in
            CartView()
        }
    }

    private var loadingView: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 170, maximum: .infinity), spacing: 16)],
                spacing: 16
            ) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(brandBorder.opacity(0.3))
                        .frame(height: 220)
                        .overlay(
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(brandBorder.opacity(0.5))
                                    .frame(height: 100)
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(brandBorder.opacity(0.5))
                                        .frame(height: 14)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(brandBorder.opacity(0.5))
                                        .frame(height: 14)
                                        .frame(width: 80, alignment: .leading)
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                            }
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
