import SwiftUI

struct CartView: View {
    @Environment(CheckoutViewModel.self) private var vm

    var body: some View {
        Group {
            if vm.isLoading {
                LPAVLoadingView(message: "Loading cart...")
            } else if vm.cartPackages.isEmpty {
                LPAVEmptyState(
                    icon: "cart",
                    title: "Your Cart is Empty",
                    message: "Browse packages and add them to your cart to start planning your trip",
                    actionTitle: "Browse Packages"
                ) {
                    NotificationCenter.default.post(name: .navigateToPackage, object: nil)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(vm.cartPackages) { package in
                            CartPackageRow(package: package) {
                                vm.removePackage(package.packageId)
                            }
                        }

                        priceBreakdown

                        NavigationLink(destination: CheckoutView()) {
                            Text("Proceed to Checkout")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.primaryGreen)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .background(Color.lpavBackground)
            }
        }
        .navigationTitle("Cart")
        .task {
            await vm.loadCartPackages()
            await vm.loadWallet()
        }
    }

    private var priceBreakdown: some View {
        LPAVCard {
            VStack(spacing: 10) {
                HStack {
                    Text("Subtotal")
                        .foregroundColor(.lpavSecondaryText)
                    Spacer()
                    Text(vm.subtotal.formattedCurrency(vm.currency))
                        .foregroundColor(.lpavText)
                }
                HStack {
                    Text("Platform Fee (5%)")
                        .foregroundColor(.lpavSecondaryText)
                    Spacer()
                    Text(vm.platformFee.formattedCurrency(vm.currency))
                        .foregroundColor(.lpavText)
                }
                if vm.pointsDiscount > 0 {
                    HStack {
                        Text("Points Discount")
                            .foregroundColor(.primaryGreen)
                        Spacer()
                        Text("-\(vm.pointsDiscount.formattedCurrency(vm.currency))")
                            .foregroundColor(.primaryGreen)
                    }
                }
                Divider()
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                        .foregroundColor(.lpavText)
                    Spacer()
                    Text(vm.total.formattedCurrency(vm.currency))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
            }
            .font(.subheadline)
        }
    }
}

struct CartPackageRow: View {
    let package: TravelPackage
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: package.urlThumbnailStorage, placeholder: "airplane.departure", aspectRatio: 4/3)
                .frame(width: 80, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(package.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.lpavText)
                    .lineLimit(2)

                Text(package.region)
                    .font(.caption)
                    .foregroundColor(.lpavSecondaryText)

                Text(package.price.formattedCurrency(package.currency))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
            }

            Spacer()

            Button(role: .destructive) {
                onRemove()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(10)
        .background(Color.lpavCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}
