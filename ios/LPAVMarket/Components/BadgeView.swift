import SwiftUI

struct BadgeView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        BadgeView(text: "Pending", color: .statusPending)
        BadgeView(text: "Completed", color: .statusCompleted)
        BadgeView(text: "Failed", color: .statusFailed)
        BadgeView(text: "Partial", color: .statusPartial)
    }
}
