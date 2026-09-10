import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(brandBorder)

            Text(title)
                .font(.headline)
                .foregroundStyle(brandText)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(brandSubtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let actionTitle, let onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "cart",
        title: "Empty Cart",
        message: "Add some packages to your cart"
    )
}
