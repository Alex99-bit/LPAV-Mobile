import SwiftUI

@MainActor
@Observable
final class CheckoutViewModel {
    var cartPackages: [TravelPackage] = []
    var isLoading = false
    var isProcessingPayment = false
    var errorMessage: String?
    var stripeURL: URL?
    var appliedPoints = 0
    var pointsDiscount: Double = 0
    var wallet: UserWallet?

    var packageIds: [String] {
        CartManager.shared.packageIds
    }

    func loadCartPackages() async {
        guard !packageIds.isEmpty else {
            cartPackages = []
            return
        }
        isLoading = true
        defer { isLoading = false }

        var loaded: [TravelPackage] = []
        for id in packageIds {
            if let package = try? await APIRouter.Packages.fetchPackage(packageId: id) {
                loaded.append(package)
            }
        }
        cartPackages = loaded
    }

    func loadWallet() async {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return }
        do {
            wallet = try await APIRouter.Wallet.fetchWallet(userId: userId)
        } catch {
            print("Failed to load wallet: \(error)")
        }
    }

    var subtotal: Double {
        cartPackages.reduce(0) { $0 + $1.price }
    }

    var platformFee: Double {
        subtotal * 0.05
    }

    var total: Double {
        max(0, subtotal + platformFee - pointsDiscount)
    }

    var currency: String {
        cartPackages.first?.currency ?? "MXN"
    }

    func applyPoints(_ points: Int) {
        guard let wallet, points <= wallet.pointsBalance else { return }
        appliedPoints = points
        pointsDiscount = Double(points) * 0.01
    }

    func clearPoints() {
        appliedPoints = 0
        pointsDiscount = 0
    }

    var maxRedeemablePoints: Int {
        guard let wallet else { return 0 }
        let maxDiscount = subtotal * 0.3
        let maxPoints = Int(maxDiscount / 0.01)
        return min(wallet.pointsBalance, maxPoints)
    }

    func createCheckout() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }

        do {
            let successUrl = "lpavmarket://checkout/success"
            let cancelUrl = "lpavmarket://checkout/cancel"

            let response = try await EdgeFunction.Functions.createCheckoutSession(
                packageIds: packageIds,
                successUrl: successUrl,
                cancelUrl: cancelUrl
            )

            if let urlString = response.url, let url = URL(string: urlString) {
                stripeURL = url
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removePackage(_ packageId: String) {
        CartManager.shared.removePackage(packageId)
        cartPackages.removeAll { $0.packageId == packageId }
    }

    func completeOrder() async -> TransactionOrder? {
        guard let userId = AuthManager.shared.currentUser?.profile.id else { return nil }
        let order = TransactionOrder(
            userId: userId,
            totalAmount: total,
            currency: currency,
            pointsRedeemed: appliedPoints > 0 ? appliedPoints : nil,
            discountApplied: pointsDiscount > 0 ? pointsDiscount : nil
        )
        do {
            let created = try await APIRouter.Orders.create(order: order)
            CartManager.shared.clear()
            cartPackages.removeAll()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return created
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
