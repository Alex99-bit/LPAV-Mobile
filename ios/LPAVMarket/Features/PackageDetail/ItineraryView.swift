import SwiftUI

struct ItineraryView: View {
    let packageId: String
    @State private var itinerary: ItineraryResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LPAVLoadingView(message: "Generating your itinerary...")
                } else if itinerary == nil, let error = errorMessage {
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
                } else if let itinerary {
                    itineraryContent(itinerary)
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

    private func itineraryContent(_ itinerary: ItineraryResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let description = itinerary.description {
                    LPAVCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.primaryGreen)
                                Text("Overview")
                                    .font(.headline)
                                    .foregroundColor(.lpavText)
                            }
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.lpavSecondaryText)
                        }
                    }
                }

                ForEach(itinerary.days) { day in
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
            let authToken = try? await supabase.auth.session.accessToken
            let response = try await EdgeFunction.Functions.generateItinerary(
                packageId: packageId,
                authToken: authToken
            )
            itinerary = response
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
                    Text("Day \(day.dayNumber)")
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

                if !day.activities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activities")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.lightBlue)
                        ForEach(day.activities) { activity in
                            HStack(alignment: .top, spacing: 8) {
                                VStack(spacing: 2) {
                                    Text(activity.time)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.lightBlue)
                                }
                                .frame(width: 50, alignment: .leading)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(activity.description)
                                        .font(.subheadline)
                                        .foregroundColor(.lpavText)
                                    if let location = activity.location {
                                        Text(location)
                                            .font(.caption)
                                            .foregroundColor(.lpavSecondaryText)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
