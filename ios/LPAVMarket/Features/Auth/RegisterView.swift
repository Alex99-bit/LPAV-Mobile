import SwiftUI

struct RegisterView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                formSection
                accountTypeSection
                actionSection
                footerSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .background(Color.brandBackground)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Create Account")
                .font(.largeTitle.bold())
                .foregroundStyle(brandText)

            Text("Join LPAV Market today")
                .font(.subheadline)
                .foregroundStyle(brandSubtext)
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person")
                    .foregroundStyle(brandSubtext)
                TextField("Full Name", text: $viewModel.fullName)
                    .textContentType(.name)
            }
            .padding()
            .background(Color.brandCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandBorder, lineWidth: 1)
            )

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
                    .textContentType(.newPassword)
            }
            .padding()
            .background(Color.brandCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandBorder, lineWidth: 1)
            )

            HStack {
                Image(systemName: "lock.fill")
                    .foregroundStyle(brandSubtext)
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textContentType(.newPassword)
            }
            .padding()
            .background(Color.brandCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(brandBorder, lineWidth: 1)
            )

            if !viewModel.password.isEmpty && viewModel.password != viewModel.confirmPassword {
                Text("Passwords do not match")
                    .font(.caption)
                    .foregroundStyle(brandError)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var accountTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Type")
                .font(.headline)
                .foregroundStyle(brandText)

            HStack(spacing: 16) {
                accountTypeButton(
                    title: "Traveler",
                    icon: "figure.walk",
                    isSelected: !viewModel.isAgency
                ) {
                    viewModel.isAgency = false
                }

                accountTypeButton(
                    title: "Agency",
                    icon: "building.2",
                    isSelected: viewModel.isAgency
                ) {
                    viewModel.isAgency = true
                }
            }
        }
    }

    private func accountTypeButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundStyle(isSelected ? .white : brandText)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? brandPrimary : Color.brandCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? brandPrimary : brandBorder, lineWidth: 1)
            )
        }
    }

    private var actionSection: some View {
        VStack(spacing: 16) {
            Button {
                Task { await viewModel.signUp(authManager: authManager) }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .background(brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!viewModel.isValidRegister || viewModel.isLoading)
        }
    }

    private var footerSection: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundStyle(brandSubtext)
            Button("Sign In") {
                dismiss()
            }
            .foregroundStyle(brandPrimary)
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
