import SwiftUI
import Kingfisher

struct AsyncImageView: View {
    let url: String?
    var width: CGFloat? = nil
    var height: CGFloat? = 100

    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            KFImage(imageURL)
                .resizable()
                .placeholder {
                    placeholderView
                }
                .fade(duration: 0.3)
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
        } else {
            placeholderView
                .frame(width: width, height: height)
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(brandBorder.opacity(0.3))
            .overlay(
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(brandBorder)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        AsyncImageView(url: nil, width: 200, height: 150)
        AsyncImageView(url: "https://picsum.photos/200/150", width: 200, height: 150)
    }
}
