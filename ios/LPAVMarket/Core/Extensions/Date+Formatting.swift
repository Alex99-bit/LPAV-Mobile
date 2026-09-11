import Foundation

extension Date {
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    func formatted(as format: String) -> String {
        Date.displayFormatter.dateFormat = format
        return Date.displayFormatter.string(from: self)
    }

    var shortDate: String {
        Date.displayFormatter.dateStyle = .short
        Date.displayFormatter.timeStyle = .none
        return Date.displayFormatter.string(from: self)
    }

    var mediumDateTime: String {
        Date.displayFormatter.dateStyle = .medium
        Date.displayFormatter.timeStyle = .short
        return Date.displayFormatter.string(from: self)
    }

    var timeAgo: String {
        let interval = -timeIntervalSinceNow
        switch interval {
        case 0..<60:
            return "Just now"
        case 60..<3600:
            let minutes = Int(interval / 60)
            return "\(minutes) min ago"
        case 3600..<86400:
            let hours = Int(interval / 3600)
            return "\(hours) hr ago"
        case 86400..<604800:
            let days = Int(interval / 86400)
            return days == 1 ? "Yesterday" : "\(days) days ago"
        default:
            return shortDate
        }
    }

    static func fromISOString(_ string: String) -> Date? {
        if let date = isoFormatter.date(from: string) {
            return date
        }
        let withoutFractional: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            return formatter
        }()
        return withoutFractional.date(from: string)
    }
}

extension String {
    func toDateFromISO() -> Date? {
        Date.fromISOString(self)
    }

    var truncatedAddress: String {
        guard count > 12 else { return self }
        let prefix = String(prefix(6))
        let suffix = String(suffix(4))
        return "\(prefix)...\(suffix)"
    }
}

extension Double {
    func formattedCurrency(_ currency: String = "MXN") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(currency) \(Int(self))"
    }

    var abbreviated: String {
        switch self {
        case 1_000_000...:
            return String(format: "%.1fM", self / 1_000_000)
        case 1_000...:
            return String(format: "%.1fK", self / 1_000)
        default:
            return String(format: "%.0f", self)
        }
    }
}

extension Int {
    func formattedPoints() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Optional where Wrapped == String {
    var orEmpty: String { self ?? "" }
}
