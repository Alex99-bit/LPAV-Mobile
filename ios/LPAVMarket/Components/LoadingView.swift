import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    var showOverlay: Bool = false

    var body: some View {
        if showOverlay {
            overlayLoading
        } else {
            centerLoading
        }
    }

    private var centerLoading: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(brandSubtext)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var overlayLoading: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    LoadingView()
}
