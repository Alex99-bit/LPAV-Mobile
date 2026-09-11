import SwiftUI

struct PointsBalanceBadge: View {
    let balance: Int
    let tier: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.title)
                .foregroundColor(.primaryGreen)

            VStack(alignment: .leading) {
                Text(" \(balance.formattedPoints()) pts")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.lpavText)
                Text(tier)
                    .font(.caption)
                    .foregroundColor(.lpavSecondaryText)
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.primaryGreen.opacity(0.1), Color.lightBlue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}
