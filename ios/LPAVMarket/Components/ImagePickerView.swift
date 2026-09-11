import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.primaryGreen)
                        Text("Select Image")
                            .font(.headline)
                            .foregroundColor(.lpavText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .background(Color.lpavSurface)
                    .cornerRadius(12)
                }
            }

            if selectedImage != nil {
                LPAVButton(title: "Remove", style: .destructive) {
                    selectedImage = nil
                    selectedItem = nil
                }
            }

            LPAVButton(title: "Done") {
                dismiss()
            }
        }
        .padding()
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}
