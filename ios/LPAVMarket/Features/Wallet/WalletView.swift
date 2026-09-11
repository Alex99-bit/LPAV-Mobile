import SwiftUI

struct WalletView: View {
    @Environment(WalletViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.wallet == nil {
                    LPAVLoadingView(message: "Loading wallet...")
                } else if let error = viewModel.errorMessage, viewModel.wallet == nil {
                    LPAVEmptyState(
                        icon: "exclamationmark.triangle",
                        title: "Error",
                        message: error,
                        actionTitle: "Retry"
                    ) {
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
            }
        }
    }

    private var walletContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                PointsBalanceBadge(
                    balance: viewModel.pointsBalance,
                    tier: viewModel.tier
                )

                LPAVCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Points Value")
                            .font(.subheadline)
                            .foregroundColor(.lpavSecondaryText)
                        Text(viewModel.pointsValue, format: .currency(code: "MXN"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.lpavText)
                    }
                }

                LPAVCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(.lpavText)

                        if viewModel.transactions.isEmpty {
                            LPAVEmptyState(
                                icon: "tray",
                                title: "No Transactions",
                                message: "Your points transaction history will appear here"
                            )
                        } else {
                            ForEach(viewModel.transactions) { transaction in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.reason.capitalized)
                                            .font(.subheadline)
                                            .foregroundColor(.lpavText)
                                        if let createdAt = transaction.createdAt {
                                            Text(createdAt)
                                                .font(.caption)
                                                .foregroundColor(.lpavSecondaryText)
                                        }
                                    }
                                    Spacer()
                                    Text("\(transaction.points > 0 ? "+" : "")\(transaction.points)")
                                        .font(.headline)
                                        .foregroundColor(transaction.points > 0 ? .primaryGreen : .red)
                                }
                                .padding(.vertical, 4)

                                if transaction.id != viewModel.transactions.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.lpavBackground)
    }
}
