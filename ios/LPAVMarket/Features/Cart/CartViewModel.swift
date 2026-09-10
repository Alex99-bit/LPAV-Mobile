import SwiftUI

@Observable
final class CartViewModel {
    var items: [CartItem] = []
    var isLoading = false

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var itemCount: Int {
        items.count
    }

    var formattedTotal: String {
        "$\(Int(totalAmount).formatted()) MXN"
    }

    func loadItems() {
        items = CartStorage.shared.items
    }

    func removeItem(packageId: String) {
        CartStorage.shared.removeItem(packageId: packageId)
        items = CartStorage.shared.items
    }

    func updateQuantity(packageId: String, quantity: Int) {
        CartStorage.shared.updateQuantity(packageId: packageId, quantity: quantity)
        items = CartStorage.shared.items
    }

    func clearCart() {
        CartStorage.shared.clear()
        items = []
    }
}
