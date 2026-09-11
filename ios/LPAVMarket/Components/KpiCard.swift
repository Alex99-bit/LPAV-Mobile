import SwiftUI

struct KpiCard: View {
    let kpi: KPIData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: kpi.icon)
                    .font(.title3)
                    .foregroundColor(kpi.color)
                Spacer()
                if let change = kpi.change, let isPositive = kpi.isPositive {
                    HStack(spacing: 2) {
                        Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text(String(format: "%.1f%%", change))
                            .font(.caption2)
                    }
                    .foregroundColor(isPositive ? .primaryGreen : .red)
                }
            }

            Text(kpi.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.lpavText)

            Text(kpi.title)
                .font(.caption)
                .foregroundColor(.lpavSecondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lpavCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}

struct KPIData {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let change: Double?
    let isPositive: Bool?

    init(title: String, value: String, icon: String, color: Color = .primaryGreen, change: Double? = nil, isPositive: Bool? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.change = change
        self.isPositive = isPositive
    }
}
