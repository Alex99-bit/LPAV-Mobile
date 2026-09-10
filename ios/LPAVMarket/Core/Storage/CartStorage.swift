import Foundation

final class CartStorage {
    static let shared = CartStorage()

    private let key = "lpav_cart_items"
    private let defaults = UserDefaults.standard

    private init() {}

    var items: [CartItem] {
        get {
            guard let data = defaults.data(forKey: key),
                  let items = try? JSONDecoder().decode([CartItem].self, from: data) else {
                return []
            }
            return items
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: key)
            }
        }
    }

    var itemCount: Int {
        items.count
    }

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    func addItem(_ item: CartItem) {
        var current = items
        if let index = current.firstIndex(where: { $0.packageId == item.packageId }) {
            current[index] = CartItem(
                id: current[index].id,
                packageId: item.packageId,
                packageTitle: item.packageTitle,
                coverImageUrl: item.coverImageUrl,
                region: item.region,
                priceMxn: item.priceMxn,
                pointsPrice: item.pointsPrice,
                quantity: current[index].quantity + 1
            )
        } else {
            current.append(item)
        }
        items = current
    }

    func removeItem(packageId: String) {
        items = items.filter { $0.packageId != packageId }
    }

    func updateQuantity(packageId: String, quantity: Int) {
        var current = items
        if let index = current.firstIndex(where: { $0.packageId == packageId }) {
            if quantity <= 0 {
                current.remove(at: index)
            } else {
                current[index] = CartItem(
                    id: current[index].id,
                    packageId: current[index].packageId,
                    packageTitle: current[index].packageTitle,
                    coverImageUrl: current[index].coverImageUrl,
                    region: current[index].region,
                    priceMxn: current[index].priceMxn,
                    pointsPrice: current[index].pointsPrice,
                    quantity: quantity
                )
            }
        }
        items = current
    }

    func clear() {
        items = []
    }
}
