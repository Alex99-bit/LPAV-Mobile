import SwiftUI

struct LPAVButton: View {
    let title: String
    var icon: String? = nil
    var isLoading = false
    var style: ButtonStyle = .primary
    var isDisabled = false
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, outline, destructive, ghost

        var backgroundColor: Color {
            switch self {
            case .primary: return .primaryGreen
            case .secondary: return .lpavSurface
            case .outline: return .clear
            case .destructive: return .red
            case .ghost: return .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive: return .white
            case .secondary: return .lpavText
            case .outline: return .primaryGreen
            case .ghost: return .primaryGreen
            }
        }

        var borderColor: Color {
            switch self {
            case .outline: return .primaryGreen
            default: return .clear
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(style.foregroundColor)
                } else if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor, lineWidth: 1.5)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}
