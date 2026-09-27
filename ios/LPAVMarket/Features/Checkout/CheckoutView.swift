import SwiftUI
import PassKit

struct CheckoutView: View {
    @Environment(CheckoutViewModel.self) private var vm
    @Environment(AuthManager.self) private var authManager
    @State private var showStripeSheet = false
    @State private var showSuccess = false
    @State private var travelerName = ""
    @State private var travelerEmail = ""
    @State private var specialRequests = ""
    @State private var guestCount = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                travelerInfoSection

                orderSummary
                paymentSection
            }
            .padding()
        }
        .background(Color.lpavBackground)
        .navigationTitle("Checkout")
        .sheet(isPresented: $showStripeSheet) {
            if let url = vm.stripeURL {
                StripeCheckoutView(url: url) { success in
                    showStripeSheet = false
                    if success {
                        Task {
                            _ = await vm.completeOrder()
                            showSuccess = true
                        }
                    }
                }
            }
        }
        .alert("Order Complete", isPresented: $showSuccess) {
            Button("View Orders") {}
            Button("Continue Shopping", role: .cancel) {}
        } message: {
            Text("Your order has been placed successfully!")
        }
        .task {
            travelerName = authManager.currentUser?.profile.fullName ?? ""
            travelerEmail = authManager.currentUser?.profile.email ?? ""
        }
    }

    private var travelerInfoSection: some View {
        LPAVCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Traveler Information")
                    .font(.headline)
                    .foregroundColor(.lpavText)

                LPAVTextField(
                    title: "Name",
                    text: $travelerName,
                    placeholder: "Full name as on ID",
                    icon: "person"
                )

                LPAVTextField(
                    title: "Email",
                    text: $travelerEmail,
                    placeholder: "you@example.com",
                    icon: "envelope",
                    keyboardType: .emailAddress
                )

                HStack {
                    Text("Guests")
                        .font(.subheadline)
                        .foregroundColor(.lpavSecondaryText)
                    Spacer()
                    Stepper("\(guestCount)", value: $guestCount, in: 1...20)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Special Requests (optional)")
                        .font(.subheadline)
                        .foregroundColor(.lpavSecondaryText)
                    TextEditor(text: $specialRequests)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color.lpavSurface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                }
            }
        }
    }

    private var orderSummary: some View {
        LPAVCard {
            VStack(spacing: 10) {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text(vm.subtotal.formattedCurrency(vm.currency))
                }
                HStack {
                    Text("Platform Fee (5%)")
                    Spacer()
                    Text(vm.platformFee.formattedCurrency(vm.currency))
                }
                Divider()
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(vm.total.formattedCurrency(vm.currency))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
            }
            .font(.subheadline)
            .foregroundColor(.lpavSecondaryText)
            .padding(8)
        }
    }

    private var paymentSection: some View {
        VStack(spacing: 12) {
            LPAVButton(
                title: "Pay with Card (Stripe)",
                icon: "creditcard.fill",
                isLoading: vm.isProcessingPayment
            ) {
                Task { await vm.createCheckout() }
            }
            .onChange(of: vm.stripeURL) { _, newURL in
                if newURL != nil {
                    showStripeSheet = true
                }
            }

            if PKPaymentAuthorizationController.canMakePayments() {
                ApplePayButton(amount: vm.total, currency: vm.currency) { success in
                    if success {
                        Task {
                            _ = await vm.completeOrder()
                            showSuccess = true
                        }
                    }
                }
            }

            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
    }
}

struct ApplePayButton: View {
    let amount: Double
    let currency: String
    let onCompletion: (Bool) -> Void

    var body: some View {
        Button {
            presentApplePay()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                Text("Pay")
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    private func presentApplePay() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.lpavmarket"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "MX"
        request.currencyCode = currency
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "LPAV Market Booking", amount: NSDecimalNumber(value: amount))
        ]

        guard let controller = PKPaymentAuthorizationController(paymentRequest: request) else {
            onCompletion(false)
            return
        }

        let delegate = ApplePayDelegate(onCompletion: onCompletion)
        controller.delegate = delegate
        controller.present()
        self.applePayDelegateStorage = delegate
    }

    @State private var applePayDelegateStorage: ApplePayDelegate?

    final class ApplePayDelegate: NSObject, PKPaymentAuthorizationControllerDelegate {
        let onCompletion: (Bool) -> Void

        init(onCompletion: @escaping (Bool) -> Void) {
            self.onCompletion = onCompletion
        }

        func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
            controller.dismiss()
        }

        func paymentAuthorizationController(
            _ controller: PKPaymentAuthorizationController,
            didAuthorizePayment payment: PKPayment,
            completion: @escaping (PKPaymentAuthorizationResult) -> Void
        ) {
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            onCompletion(true)
        }

        nonisolated func paymentAuthorizationController(
            _ controller: PKPaymentAuthorizationController,
            didAuthorizePayment payment: PKPayment,
            handler: @escaping (PKPaymentAuthorizationResult) -> Void
        ) {
            handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
            DispatchQueue.main.async { self.onCompletion(true) }
        }
    }
}

struct StripeCheckoutView: UIViewControllerRepresentable {
    let url: URL
    let onCompletion: (Bool) -> Void

    func makeUIViewController(context: Context) -> StripeCheckoutViewController {
        StripeCheckoutViewController(url: url, onCompletion: onCompletion)
    }

    func updateUIViewController(_ uiViewController: StripeCheckoutViewController, context: Context) {}
}

final class StripeCheckoutViewController: UIViewController {
    let url: URL
    let onCompletion: (Bool) -> Void
    private var observations: [NSKeyValueObservation] = []

    init(url: URL, onCompletion: @escaping (Bool) -> Void) {
        self.url = url
        self.onCompletion = onCompletion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.open(url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.dismiss(animated: true)
            self?.onCompletion(true)
        }
    }
}
