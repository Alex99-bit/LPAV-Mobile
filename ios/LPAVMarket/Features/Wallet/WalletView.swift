import SwiftUI

struct WalletView: View {
    @State private var viewModel = WalletViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.wallet == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.wallet == nil {
                    ErrorView(message: error) {
                        Task { await viewModel.loadWallet() }
                    }
                } else {
                    walletContent
                }
            }
            .navigationTitle("My Wallet")
            .refreshable {
                await viewModel.loadWallet()
            }
            .task {
                await viewModel.loadWallet()
                viewModel.listenForUpdates()
            }
        }
    }

    private var walletContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                balanceCard
                transactionsList
            }
            .padding(16)
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 40))
                .foregroundStyle(brandPrimary)

            VStack(spacing: 4) {
                Text("Points Balance")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Text(viewModel.formattedBalance)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text("Estimated Value")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(viewModel.estimatedMxn)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }

                Divider()
                    .frame(height: 30)
                    .background(.white.opacity(0.3))

                VStack(spacing: 2) {
                    Text("1 Point = $0.10 MXN")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Redeem on checkout")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [brandPrimary, brandPrimary.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: brandPrimary.opacity(0.3), radius: 10, y: 5)
    }

    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction History")
                .font(.headline)
                .foregroundStyle(brandText)

            if viewModel.transactions.isEmpty {
                EmptyStateView(
                    icon: "list.bullet",
                    title: "No transactions",
                    message: "Your point transactions will appear here"
                )
                .frame(height: 120)
            } else {
                ForEach(viewModel.transactions) { transaction in
                    transactionRow(transaction: transaction)
                }
            }
        }
    }

    private func transactionRow(transaction: WalletTransaction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForType(transaction.type))
                .font(.title3)
                .foregroundStyle(colorForType(transaction.type))
                .frame(width: 40, height: 40)
                .background(colorForType(transaction.type).opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.type.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(brandText)
                Text(transaction.description)
                    .font(.caption)
                    .foregroundStyle(brandSubtext)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount)
                    .font(.subheadline.bold())
                    .foregroundStyle(transaction.type.isPositive ? brandSuccess : brandError)
                Text(transaction.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(brandSubtext)
            }
        }
        .padding(12)
        .background(Color.brandCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandBorder, lineWidth: 1)
        )
    }

    private func iconForType(_ type: WalletTransactionType) -> String {
        switch type {
        case .purchase: return "cart.fill"
        case .redemption: return "tag.fill"
        case .refund: return "arrow.uturn.backward.circle.fill"
        case .bonus: return "gift.fill"
        case .commission: return "dollarsign.circle.fill"
        case .adjustment: return "slider.horizontal.3"
        }
    }

    private func colorForType(_ type: WalletTransactionType) -> Color {
        switch type {
        case .purchase: return brandPrimary
        case .redemption: return brandAccent
        case .refund: return brandSuccess
        case .bonus: return .purple
        case .commission: return .green
        case .adjustment: return .gray
        }
    }
}
