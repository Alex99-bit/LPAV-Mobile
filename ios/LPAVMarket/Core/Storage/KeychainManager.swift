import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.lpavmarket.app"
    private let account = "lpav_user"
    private let biometricKey = "com.lpavmarket.biometric_enabled"

    private init() {}

    func saveCredentials(email: String, password: String) {
        guard let passwordData = password.data(using: .utf8) else { return }

        deleteCredentials()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            UserDefaults.standard.set(email, forKey: "lpavmarket_biometric_email")
        }
    }

    func getCredentials() -> (email: String, password: String)? {
        guard let email = UserDefaults.standard.string(forKey: "lpavmarket_biometric_email") else {
            return nil
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return (email, password)
    }

    func deleteCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        UserDefaults.standard.removeObject(forKey: "lpavmarket_biometric_email")
    }

    func clearCredentials() {
        deleteCredentials()
    }

    func getBiometricEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: biometricKey)
    }

    func setBiometricEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: biometricKey)
        if !enabled {
            deleteCredentials()
        }
    }

    func saveJWTToken(_ token: String) {
        guard let tokenData = token.data(using: .utf8) else { return }
        deleteJWTToken()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "lpavmarket_jwt",
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func getJWTToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "lpavmarket_jwt",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }

    func deleteJWTToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "lpavmarket_jwt"
        ]
        SecItemDelete(query as CFDictionary)
    }

    func saveAPIKey(_ key: String, for service: String) {
        guard let keyData = key.data(using: .utf8) else { return }
        deleteAPIKey(for: service)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: "lpavmarket_apikey_\(service)",
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func getAPIKey(for service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: "lpavmarket_apikey_\(service)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        return key
    }

    func deleteAPIKey(for service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: "lpavmarket_apikey_\(service)"
        ]
        SecItemDelete(query as CFDictionary)
    }
}
