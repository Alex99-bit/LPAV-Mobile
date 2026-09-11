import SwiftUI

enum FlyerCardSize {
    case full
    case compact
    case list
}

struct FlyerCardView: View {
    let package: TravelPackage
    var size: FlyerCardSize = .full
    @Environment(HomeViewModel.self) private var homeVM

    var body: some View {
        switch size {
        case .full:
            fullCard
        case .compact:
            compactCard
        case .list:
            listCard
        }
    }

    private var fullCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: package.urlThumbnailStorage, placeholder: "airplane.departure", aspectRatio: 3/4)
                    .frame(height: UIScreen.main.bounds.width * 0.35)

                Button {
                    Task {
                        await homeVM.toggleWishlist(package.packageId)
                    }
                } label: {
                    Image(systemName: homeVM.isInWishlist(package.packageId) ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(package.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.lpavText)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "mappin")
                        .font(.caption2)
                    Text(package.region)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.lpavSecondaryText)

                Text(package.price.formattedCurrency(package.currency))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
            }
            .padding(10)
        }
        .background(Color.lpavCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImageView(url: package.urlThumbnailStorage, placeholder: "airplane.departure", aspectRatio: 3/4)
                .frame(width: 160, height: 220)

            VStack(alignment: .leading, spacing: 2) {
                Text(package.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.lpavText)
                    .lineLimit(2)

                Text(package.price.formattedCurrency(package.currency))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
            }
            .padding(8)
        }
        .frame(width: 160)
        .background(Color.lpavCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }

    private var listCard: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: package.urlThumbnailStorage, placeholder: "airplane.departure", aspectRatio: 4/3)
                .frame(width: 100, height: 75)

            VStack(alignment: .leading, spacing: 4) {
                Text(package.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.lpavText)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "mappin")
                        .font(.caption2)
                    Text(package.region)
                        .font(.caption)
                }
                .foregroundColor(.lpavSecondaryText)

                Text(package.price.formattedCurrency(package.currency))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
            }

            Spacer()
        }
        .padding(10)
        .background(Color.lpavCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}
