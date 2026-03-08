import SwiftUI

struct GuidedLessonView: View {
    let lesson: Lesson

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GuidedLessonViewModel
    @State private var slideDirection: SlideDirection = .forward
    @State private var navigateToPractice = false

    private var strandColor: Color {
        StrandColorSet.primary(for: lesson.strandSlug)
    }

    init(lesson: Lesson) {
        self.lesson = lesson
        self._viewModel = State(initialValue: GuidedLessonViewModel(lesson: lesson))
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    StrandColorSet.background(for: lesson.strandSlug),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                switch viewModel.state {
                case .intro:
                    introContent

                case .playing:
                    playingContent

                case .completed:
                    completionContent
                }
            }
        }
        .onDisappear {
            viewModel.stopSpeaking()
        }
    }

    // MARK: - Intro

    private var introContent: some View {
        ZStack(alignment: .topLeading) {
            GuidedLessonIntroView(
                lesson: lesson,
                speechService: viewModel.speechService,
                onBegin: { viewModel.begin() }
            )

            closeButton
        }
    }

    // MARK: - Playing

    private var playingContent: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                closeButton

                Spacer()

                // Slide counter
                Text("\(viewModel.currentSlideIndex + 1) / \(viewModel.totalSlides)")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, Spacing.md)
            }

            // Progress bar
            SlideProgressBar(
                totalSlides: viewModel.totalSlides,
                currentIndex: viewModel.currentSlideIndex,
                strandColor: strandColor,
                onTapSlide: { index in
                    slideDirection = index > viewModel.currentSlideIndex ? .forward : .backward
                    viewModel.goToSlide(index: index)
                }
            )
            .padding(.vertical, Spacing.xs)

            // Slide content with swipe gestures
            if let slide = viewModel.currentSlide {
                SlideView(
                    slide: slide,
                    strandSlug: lesson.strandSlug,
                    slideIndex: viewModel.currentSlideIndex
                )
                .id(viewModel.currentSlideIndex)
                .transition(slideTransition)
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if value.translation.width < -50 {
                                slideDirection = .forward
                                viewModel.nextSlide()
                            } else if value.translation.width > 50 {
                                slideDirection = .backward
                                viewModel.previousSlide()
                            }
                        }
                )
            }

            Spacer(minLength: 0)

            // Speech controls
            SpeechControlBar(
                speechService: viewModel.speechService,
                strandColor: strandColor,
                onPrevious: {
                    slideDirection = .backward
                    viewModel.previousSlide()
                },
                onNext: {
                    slideDirection = .forward
                    viewModel.nextSlide()
                }
            )
        }
        .animation(.spring(duration: 0.4), value: viewModel.currentSlideIndex)
    }

    // MARK: - Completion

    private var completionContent: some View {
        ZStack(alignment: .topLeading) {
            GuidedLessonCompletionView(
                lesson: lesson,
                totalSlides: viewModel.totalSlides,
                onMarkComplete: { markComplete() },
                onPractice: {
                    markComplete()
                    dismiss()
                },
                onRestart: { viewModel.restart() },
                onDismiss: { dismiss() }
            )

            closeButton
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button {
            viewModel.stopSpeaking()
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.md)
    }

    // MARK: - Slide Transition

    private var slideTransition: AnyTransition {
        switch slideDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    // MARK: - Actions

    private func markComplete() {
        guard let child = appState.activeChild else { return }
        Haptics.success()
        let progressService = ProgressService(modelContext: modelContext)
        progressService.completeLesson(lesson, for: child)
        let achievementService = AchievementService(
            modelContext: modelContext,
            curriculumService: CurriculumService(),
            progressService: progressService,
            streakService: StreakService(modelContext: modelContext)
        )
        achievementService.checkAndUnlock(for: child)
    }
}

// MARK: - Slide Direction

private enum SlideDirection {
    case forward, backward
}
