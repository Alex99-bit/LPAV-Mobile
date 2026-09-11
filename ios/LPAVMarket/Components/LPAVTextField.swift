import SwiftUI

struct LPAVTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.lpavSecondaryText)

            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(.lpavSecondaryText)
                        .frame(width: 20)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                }
            }
            .padding(12)
            .background(Color.lpavSurface)
            .cornerRadius(10)
        }
    }
}
