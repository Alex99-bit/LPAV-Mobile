import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        AsyncImageView(
                            url: authManager.avatarUrl,
                            width: 60,
                            height: 60
                        )
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.displayName)
                                .font(.headline)
                                .foregroundStyle(.lpavText)
                            Text(authManager.profile?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.lpavSecondaryText)
                            Text(authManager.profile?.roleName.capitalized ?? "Traveler")
                                .font(.caption)
                                .foregroundStyle(.primaryGreen)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Account") {
                    profileRow(icon: "person", title: "Edit Profile")
                    profileRow(icon: "creditcard", title: "Payment Methods")
                    profileRow(icon: "star.fill", title: "My Reviews")
                }

                Section("Notifications") {
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundStyle(.primaryGreen)
                                .frame(width: 24)
                            Text("Notifications")
                                .foregroundStyle(.lpavText)
                        }
                    }
                }

                Section("Support") {
                    profileRow(icon: "questionmark.circle", title: "Help Center")
                    profileRow(icon: "envelope", title: "Contact Us")
                    profileRow(icon: "doc.text", title: "Terms of Service")
                    profileRow(icon: "lock.shield", title: "Privacy Policy")
                }

                Section {
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundStyle(.red)
                            Text("Sign Out")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task { try? await authManager.signOut() }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private func profileRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.primaryGreen)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.lpavText)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.lpavSecondaryText)
        }
    }
}
