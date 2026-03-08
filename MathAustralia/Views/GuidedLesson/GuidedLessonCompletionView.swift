import SwiftUI

struct GuidedLessonCompletionView: View {
    let lesson: Lesson
    let totalSlides: Int
    let onMarkComplete: () -> Void
    let onPractice: () -> Void
    let onRestart: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var showCelebration = true

    private var strandColor: Color {
        StrandColorSet.primary(for: lesson.strandSlug)
    }

    var body: some View {
        ZStack {
            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(BrandColors.victorianGold)
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(.spring(duration: 0.6, bounce: 0.4).delay(0.3), value: appeared)

                VStack(spacing: Spacing.sm) {
                    Text("Lesson Complete!")
                        .font(.title.bold())
                        .fontDesign(.rounded)

                    Text("You've finished **\(lesson.title)**")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Stats
                HStack(spacing: Spacing.lg) {
                    miniStat(icon: "rectangle.stack.fill", value: "\(totalSlides)", label: "Slides")
                    miniStat(icon: "clock.fill", value: "\(lesson.estimatedMinutes)m", label: "Duration")
                    miniStat(icon: "star.fill", value: "+\(AppConstants.xpPerLesson)", label: "XP")
                }
                .padding(Spacing.md)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.medium))

                // Objectives covered
                if !lesson.objectives.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("What you covered")
                            .font(.subheadline.bold())
                            .fontDesign(.rounded)

                        ForEach(lesson.objectives, id: \.self) { objective in
                            HStack(alignment: .top, spacing: Spacing.xs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                                    .padding(.top, 2)
                                Text(objective)
                                    .font(.caption)
                                    .fontDesign(.rounded)
                            }
                        }
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                }

                Spacer()

                // Action buttons
                VStack(spacing: Spacing.sm) {
                    Button {
                        Haptics.success()
                        onMarkComplete()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Mark as Complete")
                        }
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(StrandColorSet.gradient(for: lesson.strandSlug))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                    .buttonStyle(.bounce)

                    Button {
                        Haptics.selection()
                        onPractice()
                    } label: {
                        HStack {
                            Image(systemName: "pencil.and.outline")
                            Text("Practice Now")
                        }
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(strandColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(strandColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }

                    HStack(spacing: Spacing.md) {
                        Button {
                            onRestart()
                        } label: {
                            Text("Replay")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            onDismiss()
                        } label: {
                            Text("Close")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, Spacing.xs)
                }
            }
            .padding(Spacing.xl)

            // Celebration overlay
            if showCelebration {
                CelebrationView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            showCelebration = false
                        }
                    }
            }
        }
        .onAppear { appeared = true }
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(strandColor)
            Text(value)
                .font(.subheadline.bold())
                .fontDesign(.rounded)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
