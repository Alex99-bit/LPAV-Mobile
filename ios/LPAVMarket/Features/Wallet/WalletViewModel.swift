import SwiftUI

@MainActor
@Observable
final class WalletViewModel {
    var wallet: UserWallet?
    var transactions: [WalletTransaction] = []
    var isLoading = false
    var errorMessage: String?

    func loadWallet() async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            wallet = try await APIRouter.Wallet.fetchWallet(userId: userId)
            transactions = try await APIRouter.Wallet.fetchPointsHistory(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func redeemPoints(_ points: Int) async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        do {
            wallet = try await APIRouter.Wallet.redeemPoints(userId: userId, points: points)
            transactions = try await APIRouter.Wallet.fetchPointsHistory(userId: userId)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var pointsBalance: Int {
        wallet?.pointsBalance ?? 0
    }

    var pointsValue: Double {
        wallet?.pointsValue ?? 0
    }

    var tier: String {
        wallet?.tierDisplay ?? "Standard"
    }

    var tierColor: String {
        wallet?.tierColor ?? "blue"
    }

    var lifetimePoints: Int {
        wallet?.lifetimePoints ?? 0
    }

    var formattedBalance: String {
        pointsBalance.formattedPoints()
    }
}
