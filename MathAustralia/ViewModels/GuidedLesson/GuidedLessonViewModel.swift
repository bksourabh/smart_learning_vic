import Foundation

// MARK: - Guided Lesson State

enum GuidedLessonState {
    case intro
    case playing
    case completed
}

// MARK: - Guided Slide

struct GuidedSlide: Identifiable {
    let id = UUID()
    let title: String
    let spokenContent: String
    let displayContent: String
    let visualContext: VisualContext
    let sectionType: SectionType
}

// MARK: - View Model

@Observable
final class GuidedLessonViewModel {
    let lesson: Lesson
    let speechService = SpeechService()

    private(set) var state: GuidedLessonState = .intro
    private(set) var slides: [GuidedSlide] = []
    private(set) var currentSlideIndex: Int = 0

    private var autoAdvanceTask: Task<Void, Never>?

    var currentSlide: GuidedSlide? {
        guard currentSlideIndex >= 0 && currentSlideIndex < slides.count else { return nil }
        return slides[currentSlideIndex]
    }

    var totalSlides: Int { slides.count }

    var progress: Double {
        guard totalSlides > 0 else { return 0 }
        return Double(currentSlideIndex + 1) / Double(totalSlides)
    }

    var isFirstSlide: Bool { currentSlideIndex == 0 }
    var isLastSlide: Bool { currentSlideIndex == totalSlides - 1 }

    init(lesson: Lesson) {
        self.lesson = lesson
        self.slides = Self.buildSlides(from: lesson)
        setupSpeechCallback()
    }

    // MARK: - State Machine

    func begin() {
        state = .playing
        currentSlideIndex = 0
        speakCurrentSlide()
    }

    func complete() {
        speechService.stop()
        autoAdvanceTask?.cancel()
        state = .completed
    }

    // MARK: - Navigation

    func nextSlide() {
        guard state == .playing else { return }
        speechService.stop()
        autoAdvanceTask?.cancel()

        if isLastSlide {
            complete()
        } else {
            currentSlideIndex += 1
            speakCurrentSlide()
        }
    }

    func previousSlide() {
        guard state == .playing, currentSlideIndex > 0 else { return }
        speechService.stop()
        autoAdvanceTask?.cancel()
        currentSlideIndex -= 1
        speakCurrentSlide()
    }

    func goToSlide(index: Int) {
        guard state == .playing, index >= 0, index < totalSlides else { return }
        speechService.stop()
        autoAdvanceTask?.cancel()
        currentSlideIndex = index
        speakCurrentSlide()
    }

    func restart() {
        state = .intro
        currentSlideIndex = 0
        speechService.stop()
        autoAdvanceTask?.cancel()
    }

    // MARK: - Speech

    func speakCurrentSlide() {
        guard let slide = currentSlide else { return }
        speechService.speak(slide.spokenContent)
    }

    func speakPreview() {
        speechService.speak("G'day! Welcome to \(lesson.title). Let's learn together!")
    }

    func stopSpeaking() {
        speechService.stop()
        autoAdvanceTask?.cancel()
    }

    private func setupSpeechCallback() {
        speechService.onFinishedSpeaking = { [weak self] in
            self?.scheduleAutoAdvance()
        }
    }

    private func scheduleAutoAdvance() {
        autoAdvanceTask?.cancel()
        guard state == .playing, !isLastSlide else {
            if state == .playing && isLastSlide {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.complete()
                }
            }
            return
        }
        autoAdvanceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            self?.nextSlide()
        }
    }

    // MARK: - Slide Builder

    static func buildSlides(from lesson: Lesson) -> [GuidedSlide] {
        var slides: [GuidedSlide] = []

        // 1. Intro slide
        let introDisplay = buildIntroDisplay(lesson)
        let introSpoken = "Welcome to \(lesson.title). " +
            (lesson.objectives.isEmpty ? lesson.description :
                "Today we'll learn: " + lesson.objectives.joined(separator: ". "))
        slides.append(GuidedSlide(
            title: lesson.title,
            spokenContent: introSpoken,
            displayContent: introDisplay,
            visualContext: .empty(strand: lesson.strandSlug),
            sectionType: .introduction
        ))

        // 2. Section slides
        for section in lesson.sections {
            let fullContent = buildSectionContent(section)
            let spokenContent = MathToSpeechConverter.convert(fullContent)
            let visualContext = VisualContextExtractor.extract(
                from: section.content,
                sectionType: section.type,
                strand: lesson.strandSlug
            )
            slides.append(GuidedSlide(
                title: section.title ?? sectionTypeTitle(section.type),
                spokenContent: spokenContent,
                displayContent: fullContent,
                visualContext: visualContext,
                sectionType: section.type
            ))
        }

        // 3. Worked example slides
        for example in lesson.workedExamples {
            // Problem slide
            let problemSpoken = MathToSpeechConverter.convert(
                "Let's work through an example: \(example.title). \(example.problem)"
            )
            let problemVisual = VisualContextExtractor.extract(
                from: example.problem,
                sectionType: .example,
                strand: lesson.strandSlug
            )
            slides.append(GuidedSlide(
                title: example.title,
                spokenContent: problemSpoken,
                displayContent: "**Problem:**\n\n\(example.problem)",
                visualContext: problemVisual,
                sectionType: .example
            ))

            // Solution slide
            let stepsText = example.steps.enumerated()
                .map { "\($0 + 1). \($1)" }
                .joined(separator: "\n")
            let solutionContent = "**Steps:**\n\n\(stepsText)\n\n**Answer:** \(example.answer)"
            let solutionSpoken = MathToSpeechConverter.convert(
                "Here's how we solve it. " +
                example.steps.enumerated().map { "Step \($0 + 1): \($1)" }.joined(separator: ". ") +
                ". The answer is \(example.answer). " + example.explanation
            )
            slides.append(GuidedSlide(
                title: "\(example.title) — Solution",
                spokenContent: solutionSpoken,
                displayContent: solutionContent,
                visualContext: problemVisual,
                sectionType: .example
            ))
        }

        // 4. Summary slide
        let summaryDisplay = buildSummaryDisplay(lesson)
        let summarySpoken = "Great work! Let's review what we covered in \(lesson.title). " +
            lesson.objectives.joined(separator: ". ") +
            ". You're ready to practise what you've learned!"
        slides.append(GuidedSlide(
            title: "Summary",
            spokenContent: summarySpoken,
            displayContent: summaryDisplay,
            visualContext: .empty(strand: lesson.strandSlug),
            sectionType: .summary
        ))

        return slides
    }

    // MARK: - Content Builders

    private static func buildIntroDisplay(_ lesson: Lesson) -> String {
        var parts: [String] = []
        parts.append("### \(lesson.title)")
        parts.append(lesson.description)
        if !lesson.objectives.isEmpty {
            parts.append("**What you'll learn:**")
            parts.append(lesson.objectives.map { "- \($0)" }.joined(separator: "\n"))
        }
        return parts.joined(separator: "\n\n")
    }

    private static func buildSectionContent(_ section: LessonSection) -> String {
        var parts: [String] = []
        if let title = section.title {
            parts.append("### \(title)")
        }
        parts.append(section.content)
        if let steps = section.steps, !steps.isEmpty {
            parts.append(steps.enumerated()
                .map { "\($0 + 1). \($1)" }
                .joined(separator: "\n"))
        }
        if let hint = section.hint {
            parts.append("**Hint:** \(hint)")
        }
        return parts.joined(separator: "\n\n")
    }

    private static func buildSummaryDisplay(_ lesson: Lesson) -> String {
        var parts: [String] = []
        parts.append("### Summary")
        parts.append("Well done! You've completed **\(lesson.title)**.")
        if !lesson.objectives.isEmpty {
            parts.append("**Key takeaways:**")
            parts.append(lesson.objectives.map { "- \($0)" }.joined(separator: "\n"))
        }
        return parts.joined(separator: "\n\n")
    }

    private static func sectionTypeTitle(_ type: SectionType) -> String {
        switch type {
        case .introduction: return "Introduction"
        case .explanation: return "Explanation"
        case .example: return "Example"
        case .keyConcept: return "Key Concept"
        case .practicePrompt: return "Try It Yourself"
        case .summary: return "Summary"
        }
    }
}
