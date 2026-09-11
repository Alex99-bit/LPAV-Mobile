import Foundation
import Supabase

@MainActor
@Observable
final class AuthManager {
    static let shared = AuthManager()
    static var currentUserId: String = ""

    var currentUser: AppUser?
    var isAuthenticated = false
    var isBiometricEnabled = false
    var isBiometricAuthenticated = false
    var authenticationState: AuthenticationState = .loading

    var isLoggedIn: Bool { currentUser != nil }
    var isAgency: Bool { currentUser?.profile.roleName.hasPrefix("Agency_") ?? false }
    var isTraveler: Bool { currentUser?.profile.roleName == "traveler" }
    var isSuperAdmin: Bool { currentUser?.profile.roleName == "super_admin" }

    var displayName: String {
        currentUser?.profile.fullName ?? currentUser?.profile.email ?? ""
    }

    var avatarUrl: String? {
        currentUser?.profile.avatarUrl
    }

    enum AuthenticationState {
        case loading
        case unauthenticated
        case authenticated
        case requiresBiometric
    }

    private init() {
        isBiometricEnabled = KeychainManager.shared.getBiometricEnabled()
    }

    func restoreSession() async {
        authenticationState = .loading
        do {
            let session = try await supabase.auth.session
            let profile = try await APIRouter.Auth.fetchProfile(userId: session.user.id.uuidString)
            currentUser = AppUser(session: session, profile: profile)
            isAuthenticated = true
            Self.currentUserId = session.user.id.uuidString

            if isBiometricEnabled && !isBiometricAuthenticated {
                authenticationState = .requiresBiometric
            } else {
                authenticationState = .authenticated
            }
        } catch {
            authenticationState = .unauthenticated
        }
    }

    func refreshSessionIfNeeded() async {
        guard isAuthenticated else { return }
        do {
            let session = try await supabase.auth.refreshSession()
            let profile = try await APIRouter.Auth.fetchProfile(userId: session.user.id.uuidString)
            currentUser = AppUser(session: session, profile: profile)
        } catch {
            await signOut()
        }
    }

    func signUp(email: String, password: String, fullName: String, roleName: String?) async throws {
        let profile = try await APIRouter.Auth.signUp(email: email, password: password, fullName: fullName, roleName: roleName)
        let session = try await supabase.auth.session
        currentUser = AppUser(session: session, profile: profile)
        isAuthenticated = true
        authenticationState = .authenticated
        Self.currentUserId = session.user.id.uuidString
    }

    func signIn(email: String, password: String) async throws {
        let profile = try await APIRouter.Auth.signIn(email: email, password: password)
        let session = try await supabase.auth.session
        currentUser = AppUser(session: session, profile: profile)
        isAuthenticated = true
        authenticationState = .authenticated
        Self.currentUserId = session.user.id.uuidString
        saveCredentials(email: email, password: password)
    }

    func signInWithGoogle(idToken: String) async throws {
        let profile = try await APIRouter.Auth.signInWithGoogle(idToken: idToken)
        let session = try await supabase.auth.session
        currentUser = AppUser(session: session, profile: profile)
        isAuthenticated = true
        authenticationState = .authenticated
        Self.currentUserId = session.user.id.uuidString
    }

    func signOut() async {
        do {
            try await APIRouter.Auth.signOut()
        } catch {
            print("Sign out error: \(error)")
        }
        currentUser = nil
        isAuthenticated = false
        isBiometricAuthenticated = false
        authenticationState = .unauthenticated
        Self.currentUserId = ""
        KeychainManager.shared.clearCredentials()
    }

    func biometricAuthenticate() async -> Bool {
        let success = await BiometricAuth.shared.authenticate()
        if success {
            isBiometricAuthenticated = true
            authenticationState = .authenticated
        }
        return success
    }

    func enableBiometric() {
        isBiometricEnabled = true
        KeychainManager.shared.setBiometricEnabled(true)
    }

    func disableBiometric() {
        isBiometricEnabled = false
        isBiometricAuthenticated = false
        KeychainManager.shared.setBiometricEnabled(false)
        KeychainManager.shared.clearCredentials()
    }

    private func saveCredentials(email: String, password: String) {
        guard isBiometricEnabled else { return }
        KeychainManager.shared.saveCredentials(email: email, password: password)
    }

    func updateProfile(fullName: String? = nil, avatarUrl: String? = nil) async throws {
        guard var user = currentUser else { return }
        var updatedProfile = user.profile
        if let fullName { updatedProfile = Profile(id: updatedProfile.id, tenantId: updatedProfile.tenantId, roleName: updatedProfile.roleName, fullName: fullName, email: updatedProfile.email, avatarUrl: updatedProfile.avatarUrl) }
        if let avatarUrl { updatedProfile = Profile(id: updatedProfile.id, tenantId: updatedProfile.tenantId, roleName: updatedProfile.roleName, fullName: updatedProfile.fullName, email: updatedProfile.email, avatarUrl: avatarUrl) }

        try await supabase.database
            .from("profiles")
            .update([
                "full_name": updatedProfile.fullName,
                "avatar_url": updatedProfile.avatarUrl as Any
            ])
            .eq("id", value: updatedProfile.id)
            .execute()

        currentUser = AppUser(session: user.session, profile: updatedProfile)
    }

    func registerDeviceToken(_ token: String) async {
        guard let userId = currentUser?.profile.id else { return }
        do {
            try await supabase.database
                .from("device_tokens")
                .upsert([
                    "user_id": userId,
                    "token": token,
                    "platform": "ios"
                ])
                .execute()
        } catch {
            print("Failed to register device token: \(error)")
        }
    }

    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }
}

struct AppUser: Sendable {
    let session: Session
    let profile: Profile
}
