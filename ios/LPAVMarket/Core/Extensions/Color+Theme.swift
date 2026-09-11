import SwiftUI

extension Color {
    static let primaryGreen = Color(hex: "10B981")
    static let darkGreen = Color(hex: "059669")
    static let primaryBlue = Color(hex: "1E40AF")
    static let lightBlue = Color(hex: "3B82F6")
    static let lpavBackground = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "111827")
            : UIColor(hex: "F9FAFB")
    })
    static let lpavText = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "F9FAFB")
            : UIColor(hex: "111827")
    })
    static let lpavSecondaryText = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "9CA3AF")
            : UIColor(hex: "6B7280")
    })
    static let lpavCard = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "1F2937")
            : UIColor.white
    })
    static let lpavSurface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "374151")
            : UIColor(hex: "F3F4F6")
    })

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
