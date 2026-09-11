import SwiftUI

struct ItineraryView: View {
    let packageId: String
    @State private var itinerary: [ItineraryResponse.ItineraryDay] = []
    @State private var summary: String?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var preferences = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LPAVLoadingView(message: "Generating your itinerary...")
                } else if itinerary.isEmpty, let error = errorMessage {
                    VStack(spacing: 16) {
                        LPAVEmptyState(
                            icon: "exclamationmark.triangle",
                            title: "Generation Failed",
                            message: error,
                            actionTitle: "Try Again"
                        ) {
                            Task { await generate() }
                        }
                    }
                    .padding()
                } else {
                    itineraryContent
                }
            }
            .navigationTitle("AI Itinerary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await generate()
            }
        }
    }

    private var itineraryContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let summary {
                    LPAVCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.primaryGreen)
                                Text("AI Summary")
                                    .font(.headline)
                                    .foregroundColor(.lpavText)
                            }
                            Text(summary)
                                .font(.subheadline)
                                .foregroundColor(.lpavSecondaryText)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Customize (optional)")
                        .font(.subheadline)
                        .foregroundColor(.lpavSecondaryText)
                    HStack {
                        TextField("e.g., less hiking, more food", text: $preferences)
                        Button("Regenerate") {
                            Task { await generate() }
                        }
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                    }
                    .padding(10)
                    .background(Color.lpavSurface)
                    .cornerRadius(10)
                }

                ForEach(itinerary) { day in
                    ItineraryDayCard(day: day)
                }
            }
            .padding()
        }
        .background(Color.lpavBackground)
    }

    private func generate() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await EdgeFunction.Functions.generateItinerary(
                packageId: packageId,
                preferences: preferences.isEmpty ? nil : preferences
            )
            itinerary = response.itinerary
            summary = response.summary
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct ItineraryDayCard: View {
    let day: ItineraryResponse.ItineraryDay

    var body: some View {
        LPAVCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Day \(day.day)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen.opacity(0.1))
                        .cornerRadius(6)

                    Text(day.title)
                        .font(.headline)
                        .foregroundColor(.lpavText)
                }

                Text(day.description)
                    .font(.subheadline)
                    .foregroundColor(.lpavSecondaryText)

                if let activities = day.activities, !activities.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activities")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.lightBlue)
                        ForEach(activities, id: \.self) { activity in
                            HStack(spacing: 6) {
                                Circle().fill(Color.lightBlue).frame(width: 6, height: 6)
                                Text(activity)
                                    .font(.subheadline)
                                    .foregroundColor(.lpavText)
                            }
                        }
                    }
                }

                if let meals = day.meals, !meals.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Meals")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryGreen)
                        ForEach(meals, id: \.self) { meal in
                            HStack(spacing: 6) {
                                Circle().fill(Color.primaryGreen).frame(width: 6, height: 6)
                                Text(meal)
                                    .font(.subheadline)
                                    .foregroundColor(.lpavText)
                            }
                        }
                    }
                }
            }
        }
    }
}
