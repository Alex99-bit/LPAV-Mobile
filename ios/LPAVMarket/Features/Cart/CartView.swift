import SwiftUI

struct CartView: View {
    @State private var viewModel = CartViewModel()
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    EmptyStateView(
                        icon: "cart",
                        title: "Your cart is empty",
                        message: "Browse packages and add them to your cart"
                    )
                } else {
                    cartList
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                if !viewModel.items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear All") {
                            viewModel.clearCart()
                        }
                        .foregroundStyle(brandError)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !viewModel.items.isEmpty {
                    checkoutBar
                }
            }
            .onAppear {
                viewModel.loadItems()
            }
        }
    }

    private var cartList: some View {
        List {
            ForEach(viewModel.items) { item in
                cartItemRow(item: item)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.removeItem(packageId: item.packageId)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func cartItemRow(item: CartItem) -> some View {
        HStack(spacing: 12) {
            AsyncImageView(
                url: item.coverImageUrl,
                width: 80,
                height: 80
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.packageTitle)
                    .font(.subheadline.bold())
                    .foregroundStyle(brandText)
                    .lineLimit(2)

                Text(item.region)
                    .font(.caption)
                    .foregroundStyle(brandSubtext)

                HStack {
                    Text(item.formattedPrice)
                        .font(.subheadline.bold())
                        .foregroundStyle(brandPrimary)

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            viewModel.updateQuantity(
                                packageId: item.packageId,
                                quantity: item.quantity - 1
                            )
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(brandSubtext)
                        }

                        Text("\(item.quantity)")
                            .font(.subheadline.bold())
                            .frame(minWidth: 20)

                        Button {
                            viewModel.updateQuantity(
                                packageId: item.packageId,
                                quantity: item.quantity + 1
                            )
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(brandPrimary)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.brandCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(brandBorder, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var checkoutBar: some View {
        VStack(spacing: 12) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.itemCount) item(s)")
                        .font(.caption)
                        .foregroundStyle(brandSubtext)
                    Text(viewModel.formattedTotal)
                        .font(.title3.bold())
                        .foregroundStyle(brandText)
                }

                Spacer()

                NavigationLink {
                    CheckoutView(items: viewModel.items)
                        .environment(authManager)
                } label: {
                    Text("Checkout")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
        }
        .background(.ultraThinMaterial)
    }
}
