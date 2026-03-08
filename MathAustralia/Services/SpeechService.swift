import AVFoundation
import Combine

// MARK: - Math to Speech Converter

enum MathToSpeechConverter {
    /// Converts a string containing LaTeX math notation into spoken English.
    static func convert(_ text: String) -> String {
        var result = text

        // Strip dollar sign delimiters
        result = result.replacingOccurrences(of: "$$", with: "")
        result = result.replacingOccurrences(of: "$", with: "")

        // Strip \text{} wrappers
        result = replacePattern(#"\\text\{([^}]*)\}"#, in: result) { $0[1] }

        // Fractions: \frac{a}{b} → "a over b"
        result = replacePattern(#"\\frac\{([^}]*)\}\{([^}]*)\}"#, in: result) {
            "\($0[1]) over \($0[2])"
        }

        // Square root: \sqrt{x} → "the square root of x"
        result = replacePattern(#"\\sqrt\{([^}]*)\}"#, in: result) {
            "the square root of \($0[1])"
        }

        // Cubed: x^3 → "x cubed"
        result = replacePattern(#"(\w+)\^3"#, in: result) { "\($0[1]) cubed" }
        // Squared: x^2 → "x squared"
        result = replacePattern(#"(\w+)\^2"#, in: result) { "\($0[1]) squared" }
        // General power: x^{n} → "x to the power of n"
        result = replacePattern(#"(\w+)\^\{([^}]*)\}"#, in: result) {
            "\($0[1]) to the power of \($0[2])"
        }
        // Simple power: x^n → "x to the power of n"
        result = replacePattern(#"(\w+)\^(\w+)"#, in: result) {
            "\($0[1]) to the power of \($0[2])"
        }

        // Operators
        result = result.replacingOccurrences(of: "\\times", with: " times ")
        result = result.replacingOccurrences(of: "\\div", with: " divided by ")
        result = result.replacingOccurrences(of: "\\pm", with: " plus or minus ")
        result = result.replacingOccurrences(of: "\\leq", with: " is less than or equal to ")
        result = result.replacingOccurrences(of: "\\geq", with: " is greater than or equal to ")
        result = result.replacingOccurrences(of: "\\neq", with: " is not equal to ")
        result = result.replacingOccurrences(of: "\\approx", with: " is approximately ")
        result = result.replacingOccurrences(of: "\\cdot", with: " times ")

        // Greek letters
        result = result.replacingOccurrences(of: "\\pi", with: "pi")
        result = result.replacingOccurrences(of: "\\theta", with: "theta")
        result = result.replacingOccurrences(of: "\\alpha", with: "alpha")
        result = result.replacingOccurrences(of: "\\beta", with: "beta")

        // Common formatting
        result = result.replacingOccurrences(of: "\\%", with: " percent")
        result = result.replacingOccurrences(of: "\\,", with: " ")
        result = result.replacingOccurrences(of: "\\;", with: " ")
        result = result.replacingOccurrences(of: "\\quad", with: " ")

        // Strip remaining backslash commands (e.g. \left, \right, \mathbf)
        result = replacePattern(#"\\[a-zA-Z]+"#, in: result) { _ in "" }

        // Clean up braces and extra whitespace
        result = result.replacingOccurrences(of: "{", with: "")
        result = result.replacingOccurrences(of: "}", with: "")
        result = result.replacingOccurrences(of: "  ", with: " ")

        // Strip markdown bold/italic markers
        result = result.replacingOccurrences(of: "**", with: "")
        result = result.replacingOccurrences(of: "__", with: "")

        // Clean up markdown heading markers
        result = replacePattern(#"^#{1,6}\s*"#, in: result, options: .anchorsMatchLines) { _ in "" }

        // Clean up markdown horizontal rules
        result = replacePattern(#"^---+$"#, in: result, options: .anchorsMatchLines) { _ in "" }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func replacePattern(
        _ pattern: String,
        in text: String,
        options: NSRegularExpression.Options = [],
        using transform: ([String]) -> String
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return text
        }
        var result = text
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            var groups: [String] = []
            for i in 0..<match.numberOfRanges {
                if let range = Range(match.range(at: i), in: result) {
                    groups.append(String(result[range]))
                } else {
                    groups.append("")
                }
            }
            if let fullRange = Range(match.range, in: result) {
                result.replaceSubrange(fullRange, with: transform(groups))
            }
        }
        return result
    }
}

// MARK: - SSML Builder

/// Transforms plain spoken text into SSML with natural pauses, emphasis, and prosody
/// for a more human-sounding educational narration.
enum SSMLBuilder {

    static func build(_ plainText: String) -> String {
        var text = plainText

        // Escape XML special characters that aren't already part of SSML tags
        text = escapeXML(text)

        // --- Sentence-level pacing ---
        // Add a natural pause after full stops (sentence breaks)
        text = text.replacingOccurrences(of: ". ", with: ".\n<break time=\"350ms\"/> ")
        // Pause after colons (introducing explanations)
        text = text.replacingOccurrences(of: ": ", with: ":\n<break time=\"300ms\"/> ")
        // Pause after exclamation marks
        text = text.replacingOccurrences(of: "! ", with: "!\n<break time=\"350ms\"/> ")
        // Pause after question marks
        text = text.replacingOccurrences(of: "? ", with: "?\n<break time=\"400ms\"/> ")

        // --- Math operator pauses (make math feel deliberate, not rushed) ---
        text = text.replacingOccurrences(of: " plus ", with: " <break time=\"150ms\"/>plus<break time=\"150ms\"/> ")
        text = text.replacingOccurrences(of: " minus ", with: " <break time=\"150ms\"/>minus<break time=\"150ms\"/> ")
        text = text.replacingOccurrences(of: " times ", with: " <break time=\"150ms\"/>times<break time=\"150ms\"/> ")
        text = text.replacingOccurrences(of: " divided by ", with: " <break time=\"150ms\"/>divided by<break time=\"150ms\"/> ")
        text = text.replacingOccurrences(of: " equals ", with: " <break time=\"200ms\"/>equals<break time=\"200ms\"/> ")
        text = text.replacingOccurrences(of: " over ", with: " <break time=\"100ms\"/><prosody rate=\"92%\">over</prosody><break time=\"100ms\"/> ")

        // --- Emphasis on key educational phrases ---
        text = emphasise(text, phrase: "the answer is", level: "moderate")
        text = emphasise(text, phrase: "the key idea", level: "moderate")
        text = emphasise(text, phrase: "remember", level: "moderate")
        text = emphasise(text, phrase: "important", level: "moderate")
        text = emphasise(text, phrase: "notice that", level: "moderate")

        // --- Step markers: slow down for "Step N:" to let students follow ---
        text = addStepProsody(text)

        // --- Enumeration pauses (numbered list items) ---
        text = addEnumerationPauses(text)

        // Wrap in <speak> root and a gentle prosody for the entire utterance
        return """
        <speak version="1.1" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-AU">
        <prosody rate="97%" pitch="+3%">
        \(text)
        </prosody>
        </speak>
        """
    }

    // MARK: - Helpers

    private static func escapeXML(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private static func emphasise(_ text: String, phrase: String, level: String) -> String {
        text.replacingOccurrences(
            of: phrase,
            with: "<emphasis level=\"\(level)\">\(phrase)</emphasis>",
            options: .caseInsensitive
        )
    }

    /// "Step 1:" → slight pause, slower pace, then resume
    private static func addStepProsody(_ text: String) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: #"(Step \d+)"#,
            options: .caseInsensitive
        ) else { return text }

        var result = text
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            guard let range = Range(match.range(at: 1), in: result) else { continue }
            let step = String(result[range])
            result.replaceSubrange(
                range,
                with: "<break time=\"300ms\"/><prosody rate=\"88%\">\(step)</prosody><break time=\"200ms\"/>"
            )
        }
        return result
    }

    /// Adds a micro-pause before numbered items like "1. " "2. "
    private static func addEnumerationPauses(_ text: String) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: #"(\d+)\. "#,
            options: []
        ) else { return text }

        var result = text
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            guard let fullRange = Range(match.range, in: result),
                  let numRange = Range(match.range(at: 1), in: result) else { continue }
            let num = String(result[numRange])
            result.replaceSubrange(
                fullRange,
                with: "<break time=\"250ms\"/>\(num). "
            )
        }
        return result
    }
}

// MARK: - Voice Gender

enum VoiceGender: String, CaseIterable {
    case female
    case male

    var label: String {
        switch self {
        case .female: return "Karen"
        case .male: return "Lee"
        }
    }

    var icon: String {
        switch self {
        case .female: return "person.circle"
        case .male: return "person.circle.fill"
        }
    }
}

// MARK: - Voice Quality Level (for UI display)

enum VoiceQualityLevel: String {
    case standard = "Standard"
    case enhanced = "Enhanced"
    case premium = "Premium"

    var description: String {
        switch self {
        case .standard: return "Basic voice — download a better one in Settings for a more natural experience."
        case .enhanced: return "Enhanced voice — good quality neural voice."
        case .premium: return "Premium voice — the most natural-sounding experience."
        }
    }
}

// MARK: - Speech Service

@Observable
final class SpeechService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()

    private(set) var isSpeaking = false
    private(set) var isPaused = false
    private(set) var voiceQualityLevel: VoiceQualityLevel = .standard
    var voiceGender: VoiceGender = .female {
        didSet { refreshVoiceQuality() }
    }
    var rate: Float = 0.48 // Slightly slower than default 0.5 for educational clarity
    var onFinishedSpeaking: (() -> Void)?

    /// Whether the best available voice is only default-tier (user should download a better one).
    var shouldSuggestVoiceDownload: Bool { voiceQualityLevel == .standard }

    // MARK: - Voice Selection

    /// Selects the best available en-AU voice: premium > enhanced > default.
    private var selectedVoice: AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-AU" }

        // Tier the voices: premium first, then enhanced, then everything
        let premium = voices.filter { $0.quality == .premium }
        let enhanced = voices.filter { $0.quality == .enhanced }

        let pool: [AVSpeechSynthesisVoice]
        if !premium.isEmpty {
            pool = premium
        } else if !enhanced.isEmpty {
            pool = enhanced
        } else {
            pool = voices
        }

        let voice: AVSpeechSynthesisVoice?
        switch voiceGender {
        case .female:
            voice = pool.first(where: { $0.name.lowercased().contains("karen") })
                ?? pool.first(where: { $0.gender == .female })
                ?? pool.first
        case .male:
            voice = pool.first(where: {
                $0.name.lowercased().contains("lee") || $0.name.lowercased().contains("gordon")
            })
                ?? pool.first(where: { $0.gender == .male })
                ?? pool.first
        }

        return voice
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
        refreshVoiceQuality()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // Non-fatal — speech will still work with default session
        }
    }

    private func refreshVoiceQuality() {
        if let voice = selectedVoice {
            switch voice.quality {
            case .premium: voiceQualityLevel = .premium
            case .enhanced: voiceQualityLevel = .enhanced
            default: voiceQualityLevel = .standard
            }
        } else {
            voiceQualityLevel = .standard
        }
    }

    // MARK: - Speaking

    /// Primary speech method — uses SSML for natural prosody with pauses, emphasis, and pacing.
    func speak(_ text: String) {
        stop()

        let ssml = SSMLBuilder.build(text)

        if let utterance = AVSpeechUtterance(ssmlRepresentation: ssml) {
            // SSML path — natural prosody baked in
            utterance.voice = selectedVoice ?? AVSpeechSynthesisVoice(language: "en-AU")
            utterance.rate = rate
            utterance.prefersAssistiveTechnologySettings = false
            utterance.preUtteranceDelay = 0.15
            utterance.postUtteranceDelay = 0.0
            isSpeaking = true
            isPaused = false
            synthesizer.speak(utterance)
        } else {
            // Fallback — SSML parsing failed, use plain text with tuned parameters
            speakPlain(text)
        }
    }

    /// Fallback when SSML is unavailable or parsing fails.
    private func speakPlain(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoice ?? AVSpeechSynthesisVoice(language: "en-AU")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.05 // Slightly warmer/friendlier tone
        utterance.preUtteranceDelay = 0.15
        utterance.postUtteranceDelay = 0.0
        utterance.prefersAssistiveTechnologySettings = false
        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
    }

    // MARK: - Playback Controls

    func pause() {
        guard isSpeaking, !isPaused else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
    }

    func togglePlayPause() {
        if isPaused {
            resume()
        } else if isSpeaking {
            pause()
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        onFinishedSpeaking?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
    }
}
