import SwiftUI

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }

    private var statusColor: Color {
        switch status.lowercased() {
        case "active", "completed", "won", "delivered": return .primaryGreen
        case "pending", "processing", "contacted", "qualified": return Color(hex: "F59E0B")
        case "inactive", "failed", "lost", "cancelled": return .red
        case "new": return .lightBlue
        default: return .lpavSecondaryText
        }
    }
}
