import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.lpavSecondaryText)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.lpavSecondaryText)
                }
            }
        }
        .padding(10)
        .background(Color.lpavSurface)
        .cornerRadius(10)
    }
}
