import SwiftUI

@Observable
final class OrdersViewModel {
    var orders: [TransactionOrder] = []
    var isLoading = false
    var errorMessage: String?

    func loadOrders() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let userId = AuthManager.currentUserId
            let response: [TransactionOrder] = try await supabase
                .from("transaction_orders")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            orders = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func installments(for orderId: String) async -> [InstallmentSchedule] {
        do {
            let response: [InstallmentSchedule] = try await supabase
                .from("installment_schedules")
                .select()
                .eq("order_id", value: orderId)
                .order("installment_number", ascending: true)
                .execute()
                .value
            return response
        } catch {
            return []
        }
    }
}
