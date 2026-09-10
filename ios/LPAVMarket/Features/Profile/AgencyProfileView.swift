import SwiftUI

struct AgencyProfileView: View {
    let agencyId: String
    @State private var viewModel = AgencyProfileViewModel()
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let agency = viewModel.agency {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection(agency: agency)
                    packagesSection
                }
            }
        }
        .navigationTitle(agency?.name ?? "Agency")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadAgency(agencyId: agencyId)
        }
    }

    private func headerSection(agency: AgencyTenant) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                AsyncImageView(
                    url: agency.logoUrl,
                    width: 72,
                    height: 72
                )
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(agency.name)
                            .font(.title2.bold())
                            .foregroundStyle(brandText)
                        if agency.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(brandPrimary)
                        }
                    }

                    HStack(spacing: 12) {
                        if let rating = agency.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline.bold())
                                Text("(\(agency.reviewCount) reviews)")
                                    .font(.caption)
                                    .foregroundStyle(brandSubtext)
                            }
                        }

                        Label("\(agency.packageCount) packages", systemImage: "bag")
                            .font(.caption)
                            .foregroundStyle(brandSubtext)
                    }
                }
            }

            if let description = agency.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(brandSubtext)
                    .lineSpacing(4)
            }

            VStack(spacing: 8) {
                if let phone = agency.phone {
                    contactRow(icon: "phone.fill", text: phone)
                }
                if let email = agency.email {
                    contactRow(icon: "envelope.fill", text: email)
                }
                if let website = agency.website {
                    contactRow(icon: "globe", text: website)
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
        .padding(16)
    }

    private func contactRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(brandPrimary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(brandText)
        }
    }

    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Published Packages (\(viewModel.packages.count))")
                .font(.headline)
                .foregroundStyle(brandText)
                .padding(.horizontal, 16)

            if viewModel.packages.isEmpty {
                EmptyStateView(
                    icon: "bag",
                    title: "No packages",
                    message: "This agency hasn't published any packages yet"
                )
                .frame(height: 120)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.packages) { package in
                            NavigationLink(value: PackageRoute(id: package.id)) {
                                PackageCardView(package: package)
                                    .frame(width: 180)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .navigationDestination(for: PackageRoute.self) { route in
                    PackageDetailView(packageId: route.id)
                }
            }
        }
        .padding(.vertical, 12)
    }
}
