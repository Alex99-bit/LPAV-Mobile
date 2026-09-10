import SwiftUI
import Kingfisher

struct PackageCardView: View {
    let package: TravelPackage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImageView(
                url: package.coverImageUrl,
                width: nil,
                height: 120
            )
            .frame(height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(package.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(brandText)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(brandPrimary)
                    Text(package.region)
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundStyle(brandSubtext)
                    Text(package.durationText)
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                }

                HStack {
                    if package.hasDiscount, let original = package.originalPriceMxn {
                        Text("$\(Int(original).formatted())")
                            .font(.caption)
                            .strikethrough()
                            .foregroundStyle(brandSubtext)
                    }

                    Text(package.formattedPrice)
                        .font(.subheadline.bold())
                        .foregroundStyle(brandPrimary)
                }

                Text(package.departureCity)
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(brandSecondary.opacity(0.8))
                    .clipShape(Capsule())
            }
            .padding(10)
        }
        .background(Color.brandCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
