import Foundation
import GoogleSignIn
import Supabase

@Observable
final class AuthManager {
    static var currentUserId: String = ""

    var currentUser: User?
    var profile: Profile?
    var isLoading = false
    var errorMessage: String?

    var isLoggedIn: Bool {
        currentUser != nil
    }

    var isAgency: Bool {
        profile?.isAgency ?? false
    }

    var isTraveler: Bool {
        profile?.isTraveler ?? true
    }

    var isSuperAdmin: Bool {
        profile?.isSuperAdmin ?? false
    }

    var displayName: String {
        profile?.displayName ?? currentUser?.email ?? ""
    }

    var avatarUrl: String? {
        profile?.avatarUrl
    }

    func restoreSession() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await supabase.auth.session
            currentUser = session.user
            Self.currentUserId = session.user.id.uuidString
            try await fetchProfile()
        } catch {
            currentUser = nil
            profile = nil
        }
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let response = try await supabase.auth.signIn(email: email, password: password)
        currentUser = response.user
        Self.currentUserId = response.user.id.uuidString
        try await fetchProfile()
    }

    func signUp(email: String, password: String, fullName: String, isAgency: Bool) async throws {
        isLoading = true
        defer { isLoading = false }
        let roleName = isAgency ? "agency_admin" : "traveler"
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: [
                "full_name": AnyJSON(fullName),
                "role_name": AnyJSON(roleName)
            ]
        )
        currentUser = response.user
        Self.currentUserId = response.user.id.uuidString
        try await fetchProfile()
    }

    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = await windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        let idToken = gidSignInResult.user.idToken?.tokenString ?? ""
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let response = try await supabase.auth.signIn(
            credentials: .google(
                idToken: idToken,
                accessToken: accessToken
            )
        )
        currentUser = response.user
        Self.currentUserId = response.user.id.uuidString
        try await fetchProfile()
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        profile = nil
        Self.currentUserId = ""
    }

    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    func fetchProfile() async throws {
        guard let userId = currentUser?.id.uuidString else { return }
        let response: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        profile = response.first
    }

    func updateProfile(fullName: String?, phone: String?, avatarUrl: String?) async throws {
        guard let userId = currentUser?.id.uuidString else { return }
        var updateData: [String: AnyJSON] = [:]
        if let fullName { updateData["full_name"] = AnyJSON(fullName) }
        if let phone { updateData["phone"] = AnyJSON(phone) }
        if let avatarUrl { updateData["avatar_url"] = AnyJSON(avatarUrl) }
        try await supabase
            .from("profiles")
            .update(updateData)
            .eq("id", value: userId)
            .execute()
        try await fetchProfile()
    }
}

enum AuthError: LocalizedError {
    case noRootViewController

    var errorDescription: String? {
        switch self {
        case .noRootViewController: return "Unable to find root view controller for Google Sign-In"
        }
    }
}
