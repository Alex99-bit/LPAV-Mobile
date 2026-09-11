import LocalAuthentication
import Foundation

actor BiometricAuth {
    static let shared = BiometricAuth()

    private let context = LAContext()

    var biometricType: LABiometryType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }

    var isAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    var biometryName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "none"
        @unknown default: return "unknown"
        }
    }

    func authenticate(reason: String = "Unlock LPAV Market to access your account") async -> Bool {
        guard isAvailable else { return false }

        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
        } catch {
            print("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }

    func authenticateForPayment(amount: Double, currency: String) async -> Bool {
        let reason = "Confirm payment of \(String(format: "%.2f", amount)) \(currency)"
        return await authenticate(reason: reason)
    }
}
