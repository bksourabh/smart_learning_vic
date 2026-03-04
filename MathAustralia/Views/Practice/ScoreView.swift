import SwiftUI

struct ScoreView: View {
    let viewModel: PracticeTestViewModel
    let onSave: () -> Void

    @State private var animatedPercentage: Double = 0
    @State private var showCelebration = false
    @State private var resultSaved = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated score circle
            ZStack {
                Circle()
                    .stroke(lineWidth: 12)
                    .fill(.gray.opacity(0.2))

                Circle()
                    .trim(from: 0, to: animatedPercentage / 100)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: animatedPercentage)

                VStack(spacing: 4) {
                    Text("\(Int(animatedPercentage))%")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("\(viewModel.score)/\(viewModel.totalQuestions)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            // Result message
            VStack(spacing: 8) {
                Text(resultTitle)
                    .font(.title.bold())

                Text(resultMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // XP earned
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("+\(xpEarned) XP")
                    .font(.headline)
            }
            .padding()
            .background(.yellow.opacity(0.1))
            .clipShape(Capsule())

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    viewModel.review()
                } label: {
                    Text("Review Answers")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)

                Button {
                    viewModel.restart()
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
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
            if viewModel.passed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
