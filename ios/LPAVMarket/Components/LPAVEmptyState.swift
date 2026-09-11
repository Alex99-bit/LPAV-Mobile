import SwiftUI

struct LPAVEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.lpavSecondaryText)

            Text(title)
                .font(.headline)
                .foregroundColor(.lpavText)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.lpavSecondaryText)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                LPAVButton(title: actionTitle, style: .outline, action: action)
                    .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
