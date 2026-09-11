import SwiftUI

struct LPAVBadge: View {
    let text: String
    var color: Color = .primaryGreen
    var isOutline: Bool = false

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isOutline ? Color.clear : color.opacity(0.15))
            .foregroundColor(isOutline ? color : color)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(color.opacity(0.4), lineWidth: isOutline ? 1 : 0)
            )
            .cornerRadius(6)
    }
}
