import SwiftUI

struct PackageDetailView: View {
    let packageId: String
    @State private var viewModel = PackageDetailViewModel()
    @Environment(AuthManager.self) private var authManager
    @State private var showChat = false
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let package = viewModel.package {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection(package: package)
                    infoSection(package: package)
                    descriptionSection(package: package)
                    agencySection
                    if !viewModel.reviews.isEmpty {
                        reviewsSection
                    }
                    actionButtonsSection
                }
            }
        }
        .navigationTitle("Package Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let package = viewModel.package {
                    ShareLink(item: URL(string: "https://lpavmarket.com/package/\(package.slug)") ?? URL(string: "https://lpavmarket.com")!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.loadPackage(packageId: packageId)
        }
    }

    private func heroSection(package: TravelPackage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImageView(
                url: package.coverImageUrl,
                width: nil,
                height: 250
            )
            .frame(height: 250)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(package.title)
                    .font(.title2.bold())
                    .foregroundStyle(brandText)

                HStack(spacing: 12) {
                    Label(package.region, systemImage: "mappin.circle.fill")
                    Label(package.durationText, systemImage: "clock")
                    Label(package.departureCity, systemImage: "airplane.departure")
                }
                .font(.caption)
                .foregroundStyle(brandSubtext)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(package.formattedPrice)
                        .font(.title.bold())
                        .foregroundStyle(brandPrimary)

                    if package.hasDiscount, let original = package.originalPriceMxn {
                        Text("$\(Int(original).formatted())")
                            .font(.subheadline)
                            .strikethrough()
                            .foregroundStyle(brandSubtext)

                        Text("-\(Int(package.discountPercentage))%")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(brandError)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    if let rating = package.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.subheadline.bold())
                            Text("(\(package.reviewCount))")
                                .font(.caption)
                                .foregroundStyle(brandSubtext)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func infoSection(package: TravelPackage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                infoBadge(icon: "calendar", title: "Departure", value: formatDate(package.departureDate))
                infoBadge(icon: "calendar.badge.clock", title: "Return", value: formatDate(package.returnDate))
            }

            HStack(spacing: 16) {
                infoBadge(icon: "person.2", title: "Group Size", value: "Max \(package.maxGroupSize)")
                infoBadge(icon: "ticket", title: "Available", value: "\(package.availableSpots) spots")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func infoBadge(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(brandSubtext)
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(brandPrimary)
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(brandText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(brandPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func descriptionSection(package: TravelPackage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let description = package.description {
                Text("About this package")
                    .font(.headline)
                    .foregroundStyle(brandText)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(brandSubtext)
                    .lineSpacing(4)
            }

            if let included = package.includedItems, !included.isEmpty {
                Text("What's included")
                    .font(.headline)
                    .foregroundStyle(brandText)
                ForEach(included, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(brandSuccess)
                            .font(.caption)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(brandText)
                    }
                }
            }

            if let excluded = package.excludedItems, !excluded.isEmpty {
                Text("Not included")
                    .font(.headline)
                    .foregroundStyle(brandText)
                ForEach(excluded, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(brandError)
                            .font(.caption)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(brandText)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var agencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let agency = viewModel.agency {
                Text("Operated by")
                    .font(.headline)
                    .foregroundStyle(brandText)

                NavigationLink(value: AgencyRoute(id: agency.id)) {
                    HStack(spacing: 12) {
                        AsyncImageView(
                            url: agency.logoUrl,
                            width: 48,
                            height: 48
                        )
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(agency.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(brandText)
                                if agency.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(brandPrimary)
                                        .font(.caption)
                                }
                            }
                            if let description = agency.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundStyle(brandSubtext)
                                    .lineLimit(2)
                            }
                        }

                        Spacer()

                        if let rating = agency.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.caption.bold())
                            }
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(brandSubtext)
                    }
                    .padding(12)
                    .background(Color.brandCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandBorder, lineWidth: 1)
                    )
                }
                .navigationDestination(for: AgencyRoute.self) { route in
                    AgencyProfileView(agencyId: route.id)
                        .environment(authManager)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews (\(viewModel.reviews.count))")
                .font(.headline)
                .foregroundStyle(brandText)

            ForEach(viewModel.reviews) { review in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        AsyncImageView(
                            url: review.userAvatarUrl,
                            width: 32,
                            height: 32
                        )
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(review.userName ?? "Anonymous")
                                .font(.subheadline.bold())
                                .foregroundStyle(brandText)
                            Text(review.formattedDate)
                                .font(.caption)
                                .foregroundStyle(brandSubtext)
                        }

                        Spacer()

                        HStack(spacing: 2) {
                            ForEach(review.stars, id: \.self) { filled in
                                Image(systemName: filled ? "star.fill" : "star")
                                    .foregroundStyle(filled ? .yellow : brandBorder)
                                    .font(.caption)
                            }
                        }
                    }

                    if let comment = review.comment {
                        Text(comment)
                            .font(.subheadline)
                            .foregroundStyle(brandText)
                    }
                }
                .padding(12)
                .background(Color.brandCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandBorder, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if let itinerary = viewModel.itinerary {
                NavigationLink {
                    ItineraryView(content: itinerary)
                } label: {
                    Label("View Generated Itinerary", systemImage: "map")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brandSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Button {
                    Task { await viewModel.generateItinerary() }
                } label: {
                    if viewModel.isGeneratingItinerary {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Generating...")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brandSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Label("Generate Itinerary", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(brandSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            Button {
                Task {
                    isLoading = true
                    do {
                        let response: CreateLeadResponse = try await supabase.functions
                            .invoke("create-lead", body: ["package_id": packageId])
                        showChat = true
                    } catch {
                        viewModel.errorMessage = error.localizedDescription
                    }
                    isLoading = false
                }
            } label: {
                if isLoading {
                    HStack {
                        ProgressView()
                            .tint(brandPrimary)
                        Text("Connecting...")
                    }
                    .font(.headline)
                    .foregroundStyle(brandPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(brandPrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Label("Request Info", systemImage: "bubble.left.and.bubble.right")
                        .font(.headline)
                        .foregroundStyle(brandPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brandPrimary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .disabled(isLoading)
            .navigationDestination(isPresented: $showChat) {
                if let agency = viewModel.agency {
                    ChatView(conversationId: agency.id, recipientName: agency.name)
                        .environment(authManager)
                }
            }

            Button {
                viewModel.addToCart()
            } label: {
                Label(
                    viewModel.addedToCart ? "Added to Cart" : "Add to Cart",
                    systemImage: viewModel.addedToCart ? "checkmark.cart.fill" : "cart.badge.plus"
                )
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.addedToCart ? brandSuccess : brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.addedToCart)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "TBD" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}
