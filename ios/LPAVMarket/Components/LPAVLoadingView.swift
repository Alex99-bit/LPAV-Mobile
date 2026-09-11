import SwiftUI

struct LPAVLoadingView: View {
    var message: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.lpavSecondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lpavBackground)
    }
}
