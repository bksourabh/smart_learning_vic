import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var errorMessage: String?
    @State private var mascotOffset: CGFloat = 0
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Deep navy gradient background
            BrandColors.heroGradient
                .ignoresSafeArea()

            // Decorative math symbols
            MathSymbolsBackground()
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Mascot + branding
                VStack(spacing: Spacing.md) {
                    Image("KangarooMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                        .shadow(color: BrandColors.victorianGold.opacity(0.3), radius: 16, x: 0, y: 8)
                        .offset(y: mascotOffset)

                    Text("Math Australia")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Master Maths, One Level at a Time")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.8))

                    VictorianCurriculumBadge(size: .large)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                // Feature highlights
                VStack(spacing: Spacing.sm) {
                    FeatureCard(icon: "book.fill", text: "100+ interactive lessons", delay: 0.1)
                    FeatureCard(icon: "checkmark.circle.fill", text: "Practice tests with instant feedback", delay: 0.2)
                    FeatureCard(icon: "chart.line.uptrend.xyaxis", text: "Track progress & earn achievements", delay: 0.3)
                    FeatureCard(icon: "person.2.fill", text: "Parent dashboard for monitoring", delay: 0.4)
                }
                .padding(.horizontal, Spacing.xl)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.red)
                        .padding(.horizontal, Spacing.xl)
                }

                // Sign in with Apple
                VStack(spacing: Spacing.sm) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                    // Trust indicators
                    HStack(spacing: Spacing.md) {
                        TrustIndicator(icon: "lock.shield.fill", text: "Secure")
                        TrustIndicator(icon: "hand.raised.fill", text: "Private")
                        TrustIndicator(icon: "checkmark.seal.fill", text: "No Ads")
                    }
                    .padding(.top, Spacing.xs)

                    Text("Designed for Australian students & parents")
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, Spacing.xs)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                mascotOffset = -8
            }
        }
    }

    private func handleSignIn(result: Result<ASAuthorization, Error>) {
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unexpected credential type."
                return
            }

            let userID = credential.user
            let fullName = credential.fullName

            let authService = AuthService(modelContext: modelContext)
            do {
                let parent = try authService.signInWithApple(
                    userID: userID,
                    fullName: fullName,
                    email: credential.email
                )
                Haptics.success()
                appState.login(parent: parent)
            } catch {
                Haptics.error()
                errorMessage = error.localizedDescription
            }

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let icon: String
    let text: String
    let delay: Double

    @State private var appeared = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.victorianGold)
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundStyle(.white.opacity(0.9))

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Trust Indicator

private struct TrustIndicator: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2.bold())
                .fontDesign(.rounded)
        }
        .foregroundStyle(.white.opacity(0.6))
    }
}
