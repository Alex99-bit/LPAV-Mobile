import SwiftUI

@Observable
final class CheckoutViewModel {
    var walletBalance: Int = 0
    var pointsToRedeem: Int = 0
    var isLoading = false
    var isProcessingPayment = false
    var paymentSuccess = false
    var errorMessage: String?

    var subtotal: Double = 0
    var ivaRate: Double = 0.16

    var ivaAmount: Double {
        subtotal * ivaRate
    }

    var totalWithIva: Double {
        subtotal + ivaAmount
    }

    var pointsValueMxn: Double {
        Double(pointsToRedeem) * 0.10
    }

    var depositAmount: Double {
        totalWithIva * 0.30
    }

    var totalToPay: Double {
        max(depositAmount - pointsValueMxn, 0)
    }

    var formattedSubtotal: String {
        "$\(Int(subtotal).formatted()) MXN"
    }

    var formattedIva: String {
        "$\(Int(ivaAmount).formatted()) MXN"
    }

    var formattedTotal: String {
        "$\(Int(totalWithIva).formatted()) MXN"
    }

    var formattedDeposit: String {
        "$\(Int(depositAmount).formatted()) MXN"
    }

    var formattedToPay: String {
        "$\(Int(totalToPay).formatted()) MXN"
    }

    func loadWallet() async {
        guard let userId = AuthManager.currentUserId.isEmpty ? nil : AuthManager.currentUserId else { return }
        do {
            let response: [UserWallet] = try await supabase
                .from("wallets")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            walletBalance = response.first?.balance ?? 0
        } catch {
            walletBalance = 0
        }
    }

    func processPayment(items: [CartItem]) async {
        isProcessingPayment = true
        errorMessage = nil
        defer { isProcessingPayment = false }

        do {
            for item in items {
                let orderData: [String: AnyJSON] = [
                    "user_id": AnyJSON(AuthManager.currentUserId),
                    "package_id": AnyJSON(item.packageId),
                    "total_amount_mxn": AnyJSON(subtotal),
                    "deposit_amount_mxn": AnyJSON(depositAmount),
                    "points_used": AnyJSON(pointsToRedeem),
                    "points_value_mxn": AnyJSON(pointsValueMxn),
                    "iva_amount": AnyJSON(ivaAmount),
                    "total_with_iva": AnyJSON(totalWithIva),
                    "payment_status": AnyJSON("pending"),
                    "installment_plan": AnyJSON(false)
                ]
                try await supabase
                    .from("transaction_orders")
                    .insert(orderData)
                    .execute()
            }
            CartStorage.shared.clear()
            paymentSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
