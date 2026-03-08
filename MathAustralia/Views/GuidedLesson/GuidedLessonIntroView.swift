import SwiftUI

struct GuidedLessonIntroView: View {
    let lesson: Lesson
    let speechService: SpeechService
    let onBegin: () -> Void

    @State private var appeared = false

    private var strandColor: Color {
        StrandColorSet.primary(for: lesson.strandSlug)
    }

    private var qualityColor: Color {
        switch speechService.voiceQualityLevel {
        case .premium: return .green
        case .enhanced: return .blue
        case .standard: return .orange
        }
    }

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            // Strand icon
            StrandIconView(strand: lesson.strandSlug, size: 64, showBackground: true)
                .scaleEffect(appeared ? 1 : 0.5)
                .animation(.spring(duration: 0.6, bounce: 0.3), value: appeared)

            // Title
            VStack(spacing: Spacing.sm) {
                Text("Guided Lesson")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)

                Text(lesson.title)
                    .font(.title.bold())
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
            }

            // Objectives
            if !lesson.objectives.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("What you'll learn")
                        .font(.subheadline.bold())
                        .fontDesign(.rounded)

                    ForEach(lesson.objectives, id: \.self) { objective in
                        HStack(alignment: .top, spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(strandColor)
                                .font(.caption)
                                .padding(.top, 2)
                            Text(objective)
                                .font(.subheadline)
                                .fontDesign(.rounded)
                        }
                    }
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(strandColor.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            }

            // Info row
            HStack(spacing: Spacing.lg) {
                Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                Label(lesson.difficulty.label, systemImage: "speedometer")
            }
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)

            // Voice preview
            VStack(spacing: Spacing.sm) {
                Button {
                    Haptics.selection()
                    speechService.speak("G'day! Welcome to \(lesson.title). Let's learn some maths together!")
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "waveform.circle.fill")
                        Text("Tap to hear a sample")
                    }
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(strandColor)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(strandColor.opacity(0.1))
                    .clipShape(Capsule())
                }

                // Voice quality hint
                HStack(spacing: 4) {
                    Circle()
                        .fill(qualityColor)
                        .frame(width: 6, height: 6)
                    Text("\(speechService.voiceQualityLevel.rawValue) voice")
                        .font(.caption2)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                }

                if speechService.shouldSuggestVoiceDownload {
                    Text("For a more natural voice, download \"Karen\" or \"Lee\" in Settings > Accessibility > Spoken Content > Voices")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
            }

            Spacer()

            // Begin button
            Button {
                Haptics.impact(.medium)
                speechService.stop()
                onBegin()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Begin")
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
        }
        .padding(Spacing.xl)
        .onAppear { appeared = true }
    }
}
