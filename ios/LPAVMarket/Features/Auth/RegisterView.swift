import SwiftUI

struct RegisterView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.lpavBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.lpavText)

                        Text("Join the travel marketplace")
                            .font(.subheadline)
                            .foregroundColor(.lpavSecondaryText)
                    }
                    .padding(.top, 20)

                    LPAVTextField(
                        title: "Full Name",
                        text: $viewModel.fullName,
                        placeholder: "John Doe",
                        icon: "person"
                    )

                    LPAVTextField(
                        title: "Email",
                        text: $viewModel.email,
                        placeholder: "you@example.com",
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )

                    LPAVTextField(
                        title: "Password",
                        text: $viewModel.password,
                        placeholder: "Min. 6 characters",
                        icon: "lock",
                        isSecure: true
                    )

                    roleSelector

                    LPAVButton(
                        title: "Create Account",
                        isLoading: viewModel.isLoading
                    ) {
                        Task { await viewModel.signUp(authManager: authManager) }
                    }

                    if viewModel.requiresOnboarding {
                        LPAVBadge(
                            text: "You'll be asked about your preferences next",
                            color: .lightBlue
                        )
                    }

                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.lpavSecondaryText)
                        Button("Sign In") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryGreen)
                    }
                    .font(.subheadline)
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }

    private var roleSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("I am a")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.lpavSecondaryText)

            HStack(spacing: 12) {
                roleButton(title: "Traveler", icon: "airplane", role: "traveler")
                roleButton(title: "Agency", icon: "building.2", role: "agency")
            }
        }
    }

    private func roleButton(title: String, icon: String, role: String) -> some View {
        Button {
            withAnimation { viewModel.selectedRole = role }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(viewModel.selectedRole == role ? Color.primaryGreen.opacity(0.1) : Color.lpavSurface)
            .foregroundColor(viewModel.selectedRole == role ? .primaryGreen : .lpavSecondaryText)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        viewModel.selectedRole == role ? Color.primaryGreen : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}
