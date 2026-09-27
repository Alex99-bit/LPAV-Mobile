import SwiftUI

@MainActor
@Observable
final class CheckoutViewModel {
    var cartPackages: [TravelPackage] = []
    var isLoading = false
    var isProcessingPayment = false
    var errorMessage: String?
    var stripeURL: URL?

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

    var subtotal: Double {
        cartPackages.reduce(0) { $0 + $1.price }
    }

    var platformFee: Double {
        subtotal * 0.05
    }

    var total: Double {
        max(0, subtotal + platformFee)
    }

    var currency: String {
        cartPackages.first?.currency ?? "MXN"
    }

    func createCheckout() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }

        guard let firstPackageId = cartPackages.first?.packageId else {
            errorMessage = "No hay paquetes en el carrito"
            return
        }

        do {
            let authToken = try? await supabase.auth.session.accessToken

            let response = try await EdgeFunction.Functions.createCheckoutSession(
                packageId: firstPackageId,
                depositPercent: 0.2,
                authToken: authToken
            )

            if let url = URL(string: response.url) {
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
            currency: currency
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
