import SwiftUI

@Observable
final class WalletViewModel {
    var wallet: UserWallet?
    var transactions: [WalletTransaction] = []
    var isLoading = false
    var errorMessage: String?

    var balance: Int {
        wallet?.balance ?? 0
    }

    var formattedBalance: String {
        "\(balance.formatted()) pts"
    }

    var estimatedMxn: String {
        "$\(Int(wallet?.estimatedMxnValue ?? 0).formatted()) MXN"
    }

    func loadWallet() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let userId = AuthManager.currentUserId
            let walletResponse: [UserWallet] = try await supabase
                .from("wallets")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            wallet = walletResponse.first

            if let walletId = wallet?.id {
                let txResponse: [WalletTransaction] = try await supabase
                    .from("wallet_transactions")
                    .select()
                    .eq("wallet_id", value: walletId)
                    .order("created_at", ascending: false)
                    .limit(50)
                    .execute()
                    .value
                transactions = txResponse
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func listenForUpdates() {
        Task {
            let channel = supabase.realtime.channel("wallet-changes")
            let changes = channel.postgresChanges(
                action: .all,
                schema: "public",
                table: "wallet_transactions"
            )
            try await channel.subscribe()
            for await change in changes {
                _ = change
                await loadWallet()
            }
        }
    }
}
