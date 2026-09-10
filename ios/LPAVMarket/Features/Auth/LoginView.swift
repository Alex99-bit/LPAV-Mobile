import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel = AuthViewModel()
    @State private var showResetPassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    formSection
                    actionSection
                    socialSection
                    footerSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .background(Color.brandBackground)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Password Reset", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {}
            } message: {
                Text("Check your email for a password reset link.")
            }
            .sheet(isPresented: $showResetPassword) {
                resetPasswordSheet
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(brandPrimary)

            Text("LPAV Market")
                .font(.largeTitle.bold())
                .foregroundStyle(brandText)

            Text("Discover amazing travel packages")
                .font(.subheadline)
                .foregroundStyle(brandSubtext)
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "envelope")
                    .foregroundStyle(brandSubtext)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .padding()
            .background(Color.brandCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandBorder, lineWidth: 1)
            )

            HStack {
                Image(systemName: "lock")
                    .foregroundStyle(brandSubtext)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            }
            .padding()
            .background(Color.brandCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandBorder, lineWidth: 1)
            )

            Button("Forgot password?") {
                showResetPassword = true
            }
            .font(.subheadline)
            .foregroundStyle(brandPrimary)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 16) {
            Button {
                Task { await viewModel.signIn(authManager: authManager) }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                } else {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .background(brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!viewModel.isValidLogin || viewModel.isLoading)
        }
    }

    private var socialSection: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle().fill(brandBorder).frame(height: 1)
                Text("or continue with")
                    .font(.caption)
                    .foregroundStyle(brandSubtext)
                Rectangle().fill(brandBorder).frame(height: 1)
            }

            Button {
                Task { await viewModel.signInWithGoogle(authManager: authManager) }
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)
                    Text("Google")
                        .font(.headline)
                }
                .foregroundStyle(brandText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.brandCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandBorder, lineWidth: 1)
                )
            }
            .disabled(viewModel.isLoading)
        }
    }

    private var footerSection: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundStyle(brandSubtext)
            NavigationLink("Sign Up") {
                RegisterView()
                    .environment(authManager)
            }
            .foregroundStyle(brandPrimary)
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }

    private var resetPasswordSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Enter your email to receive a reset link.")
                    .font(.subheadline)
                    .foregroundStyle(brandSubtext)
                    .multilineTextAlignment(.center)

                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(brandSubtext)
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color.brandCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandBorder, lineWidth: 1)
                )

                Button {
                    Task { await viewModel.resetPassword(authManager: authManager) }
                } label: {
                    Text("Send Reset Link")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.email.isEmpty || viewModel.isLoading)
            }
            .padding(24)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(250)])
    }
}
