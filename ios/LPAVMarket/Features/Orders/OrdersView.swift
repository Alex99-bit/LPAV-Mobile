import SwiftUI

struct OrdersView: View {
    @State private var viewModel = OrdersViewModel()
    @State private var expandedOrderId: String?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.orders.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.loadOrders() }
                    }
                } else if viewModel.orders.isEmpty {
                    EmptyStateView(
                        icon: "bag",
                        title: "No orders yet",
                        message: "Your orders will appear here"
                    )
                } else {
                    ordersList
                }
            }
            .navigationTitle("My Orders")
            .refreshable {
                await viewModel.loadOrders()
            }
            .task {
                await viewModel.loadOrders()
            }
        }
    }

    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.orders) { order in
                    OrderCardView(
                        order: order,
                        isExpanded: expandedOrderId == order.id,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandedOrderId = expandedOrderId == order.id ? nil : order.id
                            }
                        }
                    )
                }
            }
            .padding(16)
        }
    }
}

struct OrderCardView: View {
    let order: TransactionOrder
    let isExpanded: Bool
    let onToggle: () -> Void

    @State private var installments: [InstallmentSchedule] = []
    @State private var isLoadingInstallments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packageTitle ?? "Package")
                        .font(.subheadline.bold())
                        .foregroundStyle(brandText)

                    Text(order.formattedTotal)
                        .font(.headline)
                        .foregroundStyle(brandPrimary)
                }

                Spacer()

                BadgeView(
                    text: order.paymentStatus.displayName,
                    color: statusColor(for: order.paymentStatus)
                )
            }

            HStack(spacing: 16) {
                if order.depositAmountMxn > 0 {
                    Label(order.formattedDeposit, systemImage: "banknote")
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                }

                if order.pointsUsed > 0 {
                    Label("\(order.pointsUsed) pts", systemImage: "star")
                        .font(.caption)
                        .foregroundStyle(brandAccent)
                }

                Label(formatDate(order.createdAt), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(brandSubtext)
            }

            if order.installmentPlan {
                Button {
                    onToggle()
                    if installments.isEmpty {
                        Task {
                            isLoadingInstallments = true
                            installments = await OrdersViewModel().installments(for: order.id)
                            isLoadingInstallments = false
                        }
                    }
                } label: {
                    HStack {
                        Text(isExpanded ? "Hide Installments" : "View Installments")
                            .font(.caption.bold())
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .foregroundStyle(brandPrimary)
                }

                if isExpanded {
                    Divider()
                    if isLoadingInstallments {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(installments) { installment in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(installment.installmentText)
                                        .font(.caption.bold())
                                        .foregroundStyle(brandText)
                                    Text(installment.formattedDueDate)
                                        .font(.caption2)
                                        .foregroundStyle(brandSubtext)
                                }
                                Spacer()
                                Text(installment.formattedAmount)
                                    .font(.caption)
                                    .foregroundStyle(brandText)
                                BadgeView(
                                    text: installment.paymentStatus.displayName,
                                    color: statusColor(for: installment.paymentStatus)
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.brandCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandBorder, lineWidth: 1)
        )
    }

    private func statusColor(for status: PaymentStatus) -> Color {
        switch status {
        case .pending: return .statusPending
        case .completed: return .statusCompleted
        case .failed: return .statusFailed
        case .partial: return .statusPartial
        case .refunded: return .brandPrimary
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
