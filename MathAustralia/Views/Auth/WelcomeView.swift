import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo area
                VStack(spacing: 16) {
                    Image(systemName: "function")
                        .font(.system(size: 72))
                        .foregroundStyle(.blue)
                        .symbolEffect(.pulse)

                    Text("Math Australia")
                        .font(.system(size: 34, weight: .bold))

                    Text("Master Maths, One Level at a Time")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Victorian Curriculum Aligned")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Feature highlights
                VStack(spacing: 12) {
                    FeatureRow(icon: "book.fill", text: "100+ interactive lessons")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Practice tests with instant feedback")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track progress & earn achievements")
                    FeatureRow(icon: "person.2.fill", text: "Parent dashboard for monitoring")
                }
                .padding(.horizontal, 24)

                Spacer()

                // Auth buttons
                VStack(spacing: 12) {
                    Button {
                        showRegister = true
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        showLogin = true
                    } label: {
                        Text("I Already Have an Account")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
