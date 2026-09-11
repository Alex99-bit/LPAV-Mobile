import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel = AuthViewModel()
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lpavBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        emailField
                        passwordField
                        signInButton
                        googleSignInButton
                        biometricButton
                        registerSection
                    }
                    .padding(24)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.primaryGreen)

            Text("Welcome to LPAV Market")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.lpavText)

            Text("Your travel marketplace")
                .font(.subheadline)
                .foregroundColor(.lpavSecondaryText)
        }
        .padding(.top, 40)
        .padding(.bottom, 8)
    }

    private var emailField: some View {
        LPAVTextField(
            title: "Email",
            text: $viewModel.email,
            placeholder: "you@example.com",
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
    }

    private var passwordField: some View {
        LPAVTextField(
            title: "Password",
            text: $viewModel.password,
            placeholder: "Your password",
            icon: "lock",
            isSecure: true
        )
    }

    private var signInButton: some View {
        LPAVButton(
            title: "Sign In",
            icon: "arrow.right",
            isLoading: viewModel.isLoading
        ) {
            Task { await viewModel.signIn(authManager: authManager) }
        }
    }

    private var googleSignInButton: some View {
        Button {
            Task { await viewModel.signInWithGoogle(authManager: authManager) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "g.circle.fill")
                    .font(.title3)
                Text("Continue with Google")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.lpavSurface)
            .foregroundColor(.lpavText)
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private var biometricButton: some View {
        if AuthManager.shared.isBiometricEnabled {
            Button {
                Task { await viewModel.authenticateWithBiometrics(authManager: authManager) }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: BiometricAuth.shared.biometryName == "Face ID" ? "faceid" : "touchid")
                        .font(.title3)
                    Text("Sign in with \(BiometricAuth.shared.biometryName)")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.primaryGreen.opacity(0.1))
                .foregroundColor(.primaryGreen)
                .cornerRadius(12)
            }
        }
    }

    private var registerSection: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.lpavSecondaryText)
            Button("Sign Up") {
                showRegister = true
            }
            .fontWeight(.semibold)
            .foregroundColor(.primaryGreen)
        }
        .font(.subheadline)
    }
}
