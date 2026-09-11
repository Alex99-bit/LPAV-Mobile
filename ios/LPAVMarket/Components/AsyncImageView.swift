import SwiftUI

struct AsyncImageView: View {
    let url: String?
    var placeholder: String = "photo"
    var cornerRadius: CGFloat = 8
    var aspectRatio: CGFloat?

    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                case .failure:
                    placeholderView
                case .empty:
                    shimmerPlaceholder
                @unknown default:
                    placeholderView
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .aspectRatio(aspectRatio, contentMode: .fit)
        } else {
            placeholderView
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.lpavSurface)
            .overlay(
                Image(systemName: placeholder)
                    .font(.title)
                    .foregroundColor(.lpavSecondaryText)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var shimmerPlaceholder: some View {
        Rectangle()
            .fill(Color.lpavSurface)
            .shimmering()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
