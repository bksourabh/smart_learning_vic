import SwiftUI

struct ScoreView: View {
    let viewModel: PracticeTestViewModel
    let onSave: () -> Void

    @State private var animatedPercentage: Double = 0
    @State private var showCelebration = false
    @State private var resultSaved = false
    @State private var glowOpacity: Double = 0

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Animated score circle with gradient stroke and glow
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(scoreColor.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)
                    .opacity(glowOpacity)

                Circle()
                    .stroke(lineWidth: 14)
                    .fill(.gray.opacity(0.15))
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: animatedPercentage / 100)
                    .stroke(
                        LinearGradient(
                            colors: [scoreColor.opacity(0.8), scoreColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 180, height: 180)
                    .animation(.easeOut(duration: 1.5), value: animatedPercentage)

                VStack(spacing: Spacing.xxs) {
                    Text("\(Int(animatedPercentage))%")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("\(viewModel.score)/\(viewModel.totalQuestions)")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }
            }

            // Result message
            VStack(spacing: Spacing.xs) {
                Text(resultTitle)
                    .font(.title.bold())
                    .fontDesign(.rounded)

                Text(resultMessage)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .staggeredEntrance(index: 1)

            // Animated XP earned
            HStack(spacing: Spacing.xs) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("+\(xpEarned) XP")
                    .font(.headline)
                    .fontDesign(.rounded)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                LinearGradient(colors: [.yellow.opacity(0.15), .orange.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
            .glow(color: .yellow, radius: 8)
            .staggeredEntrance(index: 2)

            Spacer()

            // Action buttons
            VStack(spacing: Spacing.sm) {
                Button {
                    viewModel.review()
                } label: {
                    Text("Review Answers")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)

                Button {
                    viewModel.restart()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, Spacing.xxl)
        }
        .overlay {
            if showCelebration {
                CelebrationView()
            }
        }
        .onAppear {
            if !resultSaved {
                onSave()
                resultSaved = true
            }
            withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                animatedPercentage = viewModel.percentage
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
                glowOpacity = 0.8
            }
            if viewModel.passed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Haptics.success()
                    showCelebration = true
                }
            }
        }
    }

    private var scoreColor: Color {
        if viewModel.isPerfect { return .yellow }
        if viewModel.passed { return .green }
        return .orange
    }

    private var resultTitle: String {
        if viewModel.isPerfect { return "Perfect Score!" }
        if viewModel.passed { return "Well Done!" }
        return "Keep Practising!"
    }

    private var resultMessage: String {
        if viewModel.isPerfect { return "You got every question right!" }
        if viewModel.passed { return "You passed the test. Great work!" }
        return "You didn't pass this time, but don't give up!"
    }

    private var xpEarned: Int {
        if viewModel.isPerfect { return AppConstants.xpBonusPerfect }
        if viewModel.passed { return AppConstants.xpPerPractice }
        return AppConstants.xpPracticeFail
    }
}
