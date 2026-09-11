import SwiftUI

struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @Environment(AuthManager.self) private var authManager
    @State private var showRegionFilter = false
    @State private var showPriceFilter = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeroSearchView()

                filterBar

                if viewModel.isLoading && viewModel.packages.isEmpty {
                    loadingPlaceholder
                } else if let error = viewModel.searchError, viewModel.packages.isEmpty {
                    LPAVEmptyState(
                        icon: "exclamationmark.triangle",
                        title: "Error Loading Packages",
                        message: error,
                        actionTitle: "Retry"
                    ) {
                        Task { await viewModel.loadPackages() }
                    }
                } else if viewModel.packages.isEmpty {
                    LPAVEmptyState(
                        icon: "magnifyingglass",
                        title: "No Packages Found",
                        message: "Try adjusting your filters or search terms"
                    )
                } else {
                    CatalogGridView(packages: viewModel.packages)

                    if viewModel.hasMorePages {
                        LPAVButton(title: "Load More", style: .outline) {
                            Task { await viewModel.loadMore() }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom)
        }
        .background(Color.lpavBackground)
        .navigationTitle("Explore")
        .sheet(isPresented: $showRegionFilter) {
            RegionFilterView()
        }
        .sheet(isPresented: $showPriceFilter) {
            PriceFilterView()
        }
        .refreshable {
            await viewModel.loadPackages()
        }
        .task {
            await viewModel.loadPackages()
            await viewModel.loadFeatured()
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    showRegionFilter = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                        Text(viewModel.selectedRegion ?? "Region")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedRegion != nil ? Color.primaryGreen.opacity(0.1) : Color.lpavSurface)
                    .foregroundColor(viewModel.selectedRegion != nil ? .primaryGreen : .lpavText)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(viewModel.selectedRegion != nil ? Color.primaryGreen : Color.clear, lineWidth: 1)
                    )
                }

                Button {
                    showPriceFilter = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle")
                            .font(.caption)
                        Text("Price")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background((viewModel.minPrice != nil || viewModel.maxPrice != nil) ? Color.primaryGreen.opacity(0.1) : Color.lpavSurface)
                    .foregroundColor((viewModel.minPrice != nil || viewModel.maxPrice != nil) ? .primaryGreen : .lpavText)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke((viewModel.minPrice != nil || viewModel.maxPrice != nil) ? Color.primaryGreen : Color.clear, lineWidth: 1)
                    )
                }

                if viewModel.hasActiveFilters {
                    Button {
                        viewModel.clearFilters()
                        Task { await viewModel.loadPackages() }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text("Clear All")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var loadingPlaceholder: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 16
            ) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.lpavSurface)
                        .frame(height: 220)
                        .overlay(
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.lpavSurface)
                                    .frame(height: 120)
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.lpavSurface)
                                        .frame(height: 14)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.lpavSurface)
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
