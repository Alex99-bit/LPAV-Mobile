import SwiftUI

struct OrdersView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var orders: [TransactionOrder] = []
    @State private var isLoading = true
    @State private var selectedSegment = "all"

    private let segments = ["all", "pending", "completed", "refunded"]

    var filteredOrders: [TransactionOrder] {
        if selectedSegment == "all" { return orders }
        if selectedSegment == "refunded" {
            return orders.filter { $0.paymentStatus == "refunded" || $0.paymentStatus == "partial" }
        }
        return orders.filter { $0.paymentStatus == selectedSegment }
    }

    var body: some View {
        Group {
            if isLoading {
                LPAVLoadingView(message: "Loading orders...")
            } else if orders.isEmpty {
                LPAVEmptyState(
                    icon: "shippingbox",
                    title: "No Orders Yet",
                    message: "Your completed bookings will appear here",
                    actionTitle: "Browse Packages"
                ) {
                    NotificationCenter.default.post(name: .navigateToPackage, object: nil)
                }
            } else {
                VStack(spacing: 0) {
                    Picker("Filter", selection: $selectedSegment) {
                        ForEach(segments, id: \.self) { segment in
                            Text(segment.capitalized).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    List {
                        ForEach(filteredOrders) { order in
                            OrderRow(order: order)
                        }
                    }
                    .listStyle(.plain)
                }
                .background(Color.lpavBackground)
            }
        }
        .navigationTitle("Orders")
        .task {
            await loadOrders()
        }
    }

    private func loadOrders() async {
        guard let userId = authManager.currentUser?.profile.id else { return }
        isLoading = true
        do {
            orders = try await APIRouter.Orders.fetchUserOrders(userId: userId)
        } catch {
            print("Failed to load orders: \(error)")
        }
        isLoading = false
    }
}

struct OrderRow: View {
    let order: TransactionOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                StatusBadge(status: order.statusDisplay)
                Spacer()
                Text(order.createdAt?.toDateFromISO()?.timeAgo ?? "")
                    .font(.caption)
                    .foregroundColor(.lpavSecondaryText)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Order #\(order.orderId.prefix(8))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.lpavText)
                }

                Spacer()

                Text(order.totalAmount.formattedCurrency(order.currency))
                    .font(.headline)
                    .foregroundColor(.primaryGreen)
            }

            if let remaining = order.remainingBalance, remaining > 0 {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Remaining: \(remaining.formattedCurrency(order.currency))")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            if let points = order.pointsRedeemed, points > 0 {
                LPAVBadge(text: "\(points) pts redeemed", color: .primaryGreen)
            }
        }
        .padding(.vertical, 8)
    }
}
