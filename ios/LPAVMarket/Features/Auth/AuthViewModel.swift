import SwiftUI
import AuthenticationServices

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var fullName = ""
    var selectedRole = "traveler"
    var isLoading = false
    var errorMessage: String?
    var showError = false
    var requiresOnboarding = false

    func signIn(authManager: AuthManager) async {
        guard validateEmailAndPassword() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func signUp(authManager: AuthManager) async {
        guard validateEmailAndPassword() else { return }
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your full name"
            showError = true
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let roleName = selectedRole == "agency" ? "Agency_Admin" : "traveler"
            try await authManager.signUp(email: email, password: password, fullName: fullName, roleName: roleName)
            if selectedRole == "traveler" {
                requiresOnboarding = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func signInWithGoogle(authManager: AuthManager) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let idToken = try await performGoogleSignIn()
            try await authManager.signInWithGoogle(idToken: idToken)
        } catch let error as ASWebAuthenticationSessionError {
            if error.code == .canceledLogin { return }
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func authenticateWithBiometrics(authManager: AuthManager) async {
        let success = await authManager.biometricAuthenticate()
        if success {
            isLoading = true
            defer { isLoading = false }
            guard let credentials = KeychainManager.shared.getCredentials() else { return }
            do {
                try await authManager.signIn(email: credentials.email, password: credentials.password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func performGoogleSignIn() async throws -> String {
        let clientID = "com.googleusercontent.apps.YOUR_CLIENT_ID"
        let redirectURI = "com.lpavmarket:/oauth2redirect/google"

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid email profile"),
            URLQueryItem(name: "nonce", value: UUID().uuidString)
        ]

        return try await withCheckedThrowingContinuation { continuation in
            guard let authURL = components.url else {
                continuation.resume(throwing: NSError(domain: "OAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }

            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "com.lpavmarket"
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: NSError(domain: "OAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "No code received"]))
                    return
                }

                Task {
                    do {
                        let response = try await EdgeFunction.invokeDecodable(
                            function: "google-auth",
                            body: ["code": code, "redirect_uri": redirectURI]
                        ) as GoogleAuthResponse
                        continuation.resume(returning: response.idToken)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            session.presentationContextProvider = ASAuthPresentationProvider.shared
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    func signOut(authManager: AuthManager) async {
        await authManager.signOut()
    }

    func resetPassword(authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authManager.resetPassword(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validateEmailAndPassword() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return false
        }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        return true
    }
}

struct GoogleAuthResponse: Codable, Sendable {
    let idToken: String
    let accessToken: String?
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

final class ASAuthPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = ASAuthPresentationProvider()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
}
