import SwiftUI

struct ItineraryView: View {
    let content: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(parseItinerary(), id: \.day) { day in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar.day.circle.fill")
                                .foregroundStyle(brandPrimary)
                            Text("Day \(day.day)")
                                .font(.headline)
                                .foregroundStyle(brandPrimary)
                        }

                        Text(day.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(brandText)

                        ForEach(day.activities, id: \.self) { activity in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(brandPrimary.opacity(0.3))
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                Text(activity)
                                    .font(.subheadline)
                                    .foregroundStyle(brandText)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.brandCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandBorder, lineWidth: 1)
                    )
                }
            }
            .padding(16)
        }
        .navigationTitle("Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct DayItinerary {
        let day: Int
        let title: String
        let activities: [String]
    }

    private func parseItinerary() -> [DayItinerary] {
        var days: [DayItinerary] = []
        let lines = content.components(separatedBy: "\n")
        var currentDay = 0
        var currentTitle = ""
        var currentActivities: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().hasPrefix("day ") {
                if currentDay > 0 {
                    days.append(DayItinerary(day: currentDay, title: currentTitle, activities: currentActivities))
                }
                let parts = trimmed.components(separatedBy: ":")
                if let dayNum = Int(parts[0].replacingOccurrences(of: "Day ", with: "")) {
                    currentDay = dayNum
                }
                currentTitle = parts.count > 1 ? parts[1...].joined(separator: ":").trimmingCharacters(in: .whitespaces) : ""
                currentActivities = []
            } else if !trimmed.isEmpty {
                currentActivities.append(trimmed.replacingOccurrences(of: "- ", with: "").replacingOccurrences(of: "• ", with: ""))
            }
        }
        if currentDay > 0 {
            days.append(DayItinerary(day: currentDay, title: currentTitle, activities: currentActivities))
        }
        return days
    }
}
