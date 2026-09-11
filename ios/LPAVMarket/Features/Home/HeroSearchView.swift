import SwiftUI

struct HeroSearchView: View {
    @Environment(HomeViewModel.self) private var vm
    @State private var query = ""
    @State private var isFocused = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.primaryGreen)
                    Text("AI-Powered Search")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryGreen)
                        .textCase(.uppercase)
                }

                Text("Discover Your Next Adventure")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.lpavText)
                    .multilineTextAlignment(.center)

                Text("Describe your dream trip — our AI will find the perfect package for you")
                    .font(.subheadline)
                    .foregroundColor(.lpavSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.lpavSecondaryText)
                    TextField("e.g., beach vacation with snorkeling under $2000", text: $query)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            Task { await vm.searchWithGemini(query) }
                        }
                }
                .padding(12)
                .background(Color.lpavSurface)
                .cornerRadius(12)

                Button {
                    Task { await vm.searchWithGemini(query) }
                } label: {
                    if vm.isGeminiSearching {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                    }
                }
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(12)
                .background(query.isEmpty ? Color.gray : Color.primaryGreen)
                .cornerRadius(12)
                .disabled(query.isEmpty || vm.isGeminiSearching)
            }

            if !vm.geminiSuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.geminiSuggestions, id: \.self) { suggestion in
                            Button {
                                query = suggestion
                                Task { await vm.searchWithGemini(suggestion) }
                            } label: {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.primaryGreen.opacity(0.1))
                                    .foregroundColor(.primaryGreen)
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
            }

            if let error = vm.searchError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.primaryGreen.opacity(0.05), Color.lightBlue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}
