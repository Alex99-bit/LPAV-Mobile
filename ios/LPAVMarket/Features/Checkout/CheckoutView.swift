import SwiftUI
import StripePayments

struct CheckoutView: View {
    let items: [CartItem]
    @State private var viewModel = CheckoutViewModel()
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                orderSummary
                ivaBreakdown
                depositSection
                pointsSection
                totalSection
                paymentButton
            }
            .padding(16)
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Payment Successful!", isPresented: $viewModel.paymentSuccess) {
            Button("View Orders") {
                dismiss()
            }
        } message: {
            Text("Your order has been placed successfully.")
        }
        .task {
            viewModel.subtotal = items.reduce(0) { $0 + $1.totalPrice }
            await viewModel.loadWallet()
        }
    }

    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)
                .foregroundStyle(brandText)

            ForEach(items) { item in
                HStack {
                    Text(item.packageTitle)
                        .font(.subheadline)
                        .foregroundStyle(brandText)
                        .lineLimit(1)
                    Spacer()
                    Text(item.formattedPrice)
                        .font(.subheadline)
                        .foregroundStyle(brandText)
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

    private var ivaBreakdown: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Subtotal")
                    .font(.subheadline)
                    .foregroundStyle(brandSubtext)
                Spacer()
                Text(viewModel.formattedSubtotal)
                    .font(.subheadline)
                    .foregroundStyle(brandText)
            }

            HStack {
                Text("IVA (16%)")
                    .font(.subheadline)
                    .foregroundStyle(brandSubtext)
                Spacer()
                Text(viewModel.formattedIva)
                    .font(.subheadline)
                    .foregroundStyle(brandText)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(brandText)
                Spacer()
                Text(viewModel.formattedTotal)
                    .font(.headline)
                    .foregroundStyle(brandText)
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

    private var depositSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(brandPrimary)
                Text("30% deposit required")
                    .font(.subheadline)
                    .foregroundStyle(brandText)
            }
            Text("Deposit to pay now: \(viewModel.formattedDeposit)")
                .font(.subheadline.bold())
                .foregroundStyle(brandPrimary)
        }
        .padding(16)
        .background(brandPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var pointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Redeem Points")
                    .font(.headline)
                    .foregroundStyle(brandText)
                Spacer()
                Text("\(viewModel.walletBalance) pts available")
                    .font(.caption)
                    .foregroundStyle(brandSubtext)
            }

            if viewModel.walletBalance > 0 {
                Slider(
                    value: Binding(
                        get: { Double(viewModel.pointsToRedeem) },
                        set: { viewModel.pointsToRedeem = Int($0) }
                    ),
                    in: 0...Double(viewModel.walletBalance),
                    step: 100
                )
                .tint(brandPrimary)

                HStack {
                    Text("0")
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                    Spacer()
                    Text("\(viewModel.pointsToRedeem) pts")
                        .font(.subheadline.bold())
                        .foregroundStyle(brandPrimary)
                    Spacer()
                    Text("\(viewModel.walletBalance)")
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                }

                if viewModel.pointsToRedeem > 0 {
                    HStack {
                        Text("Points value:")
                            .font(.caption)
                            .foregroundStyle(brandSubtext)
                        Text("-$\(Int(viewModel.pointsValueMxn).formatted()) MXN")
                            .font(.caption.bold())
                            .foregroundStyle(brandSuccess)
                    }
                }
            } else {
                Text("No points available to redeem")
                    .font(.subheadline)
                    .foregroundStyle(brandSubtext)
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

    private var totalSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total to Pay")
                    .font(.headline)
                    .foregroundStyle(brandText)
                Text("(30% deposit)")
                    .font(.caption)
                    .foregroundStyle(brandSubtext)
            }
            Spacer()
            Text(viewModel.formattedToPay)
                .font(.title2.bold())
                .foregroundStyle(brandPrimary)
        }
        .padding(16)
        .background(brandPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var paymentButton: some View {
        Button {
            Task { await viewModel.processPayment(items: items) }
        } label: {
            if viewModel.isProcessingPayment {
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Processing...")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack {
                    Image(systemName: "creditcard.fill")
                    Text("Pay with Stripe")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .disabled(viewModel.isProcessingPayment)
    }
}
