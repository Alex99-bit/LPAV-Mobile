import SwiftUI

struct PackageDetailView: View {
    let packageId: String
    @State private var package: TravelPackage?
    @State private var reviews: [PackageReview] = []
    @State private var agency: AgencyTenant?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isGeneratingItinerary = false
    @State private var itinerary: String?
    @State private var addedToCart = false
    @State private var showChat = false
    @State private var isCreatingLead = false
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ScrollView {
            if isLoading {
                LPAVLoadingView(message: "Loading package...")
            } else if let package {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection(package: package)
                    descriptionSection(package: package)
                    actionButtonsSection
                }
            } else if let error = errorMessage {
                LPAVEmptyState(
                    icon: "exclamationmark.triangle",
                    title: "Error",
                    message: error,
                    actionTitle: "Retry"
                ) {
                    Task { await loadPackage() }
                }
            }
        }
        .background(Color.lpavBackground)
        .navigationTitle("Package Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPackage()
        }
    }

    private func heroSection(package: TravelPackage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImageView(url: package.urlThumbnailStorage, placeholder: "airplane.departure", aspectRatio: 4/3)
                .frame(height: 250)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(package.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.lpavText)

                HStack(spacing: 12) {
                    Label(package.region, systemImage: "mappin.circle.fill")
                    if let duration = package.duration {
                        Label(duration, systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundColor(.lpavSecondaryText)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(package.price.formattedCurrency(package.currency))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)

                    if let guests = package.maxGuests {
                        Text("Max \(guests) guests")
                            .font(.caption)
                            .foregroundColor(.lpavSecondaryText)
                    }

                    Spacer()
                }

                if let departureDate = package.departureDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.primaryGreen)
                        Text(departureDate)
                            .font(.subheadline)
                            .foregroundColor(.lpavText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func descriptionSection(package: TravelPackage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let description = package.description {
                Text("About this package")
                    .font(.headline)
                    .foregroundColor(.lpavText)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.lpavSecondaryText)
                    .lineSpacing(4)
            }

            if let includes = package.includes, !includes.isEmpty {
                Text("What's included")
                    .font(.headline)
                    .foregroundColor(.lpavText)
                ForEach(includes, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primaryGreen)
                            .font(.caption)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.lpavText)
                    }
                }
            }

            if let excludes = package.excludes, !excludes.isEmpty {
                Text("Not included")
                    .font(.headline)
                    .foregroundColor(.lpavText)
                ForEach(excludes, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.lpavText)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if let itinerary {
                NavigationLink {
                    ItineraryView(content: itinerary)
                } label: {
                    Label("View Generated Itinerary", systemImage: "map")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.darkGreen)
                        .cornerRadius(12)
                }
            } else {
                Button {
                    Task { await generateItinerary() }
                } label: {
                    if isGeneratingItinerary {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Generating...")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.darkGreen)
                        .cornerRadius(12)
                    } else {
                        Label("Generate Itinerary", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.darkGreen)
                            .cornerRadius(12)
                    }
                }
            }

            Button {
                addedToCart = true
                CartManager.shared.addPackage(packageId)
            } label: {
                Label(
                    addedToCart ? "Added to Cart" : "Add to Cart",
                    systemImage: addedToCart ? "checkmark.cart.fill" : "cart.badge.plus"
                )
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(addedToCart ? Color.primaryGreen : Color.primaryGreen)
                .cornerRadius(12)
            }
            .disabled(addedToCart)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func loadPackage() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: [TravelPackage] = try await supabase.database
                .from("packages")
                .select()
                .eq("package_id", value: packageId)
                .execute()
                .value
            package = response.first

            if let package {
                let reviewResponse: [PackageReview] = try await supabase.database
                    .from("reviews")
                    .select()
                    .eq("package_id", value: package.packageId)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                reviews = reviewResponse

                if let tenantId = package.tenantId {
                    let agencyResponse: [AgencyTenant] = try await supabase.database
                        .from("tenants")
                        .select()
                        .eq("id", value: tenantId)
                        .execute()
                        .value
                    agency = agencyResponse.first
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func generateItinerary() async {
        isGeneratingItinerary = true
        defer { isGeneratingItinerary = false }
        do {
            let response: ItineraryResponse = try await EdgeFunction.invokeDecodable(
                function: "generate-itinerary",
                body: ["package_id": packageId]
            )
            itinerary = response.summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ItineraryView: View {
    let content: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(content)
                    .font(.body)
                    .foregroundColor(.lpavText)
                    .lineSpacing(4)
            }
            .padding()
        }
        .navigationTitle("AI Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }
}
