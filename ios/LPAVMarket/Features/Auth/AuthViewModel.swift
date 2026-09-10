import SwiftUI

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var fullName = ""
    var isAgency = false
    var isLoading = false
    var errorMessage: String?
    var showSuccessAlert = false

    var isValidLogin: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var isValidRegister: Bool {
        !fullName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }

    func signIn(authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authManager.signUp(
                email: email,
                password: password,
                fullName: fullName,
                isAgency: isAgency
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle(authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authManager.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword(authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authManager.resetPassword(email: email)
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
        isAgency = false
        errorMessage = nil
    }
}
