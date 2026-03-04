import Foundation

// MARK: - Section Type

enum SectionType: String, Codable {
    case introduction
    case explanation
    case example
    case keyConcept = "key-concept"
    case practicePrompt = "practice-prompt"
    case summary
}

// MARK: - Difficulty

enum Difficulty: String, Codable {
    case easy
    case medium
    case hard

    var label: String {
        switch self {
        case .easy: return "Beginner"
        case .medium: return "Intermediate"
        case .hard: return "Advanced"
        }
    }
}

// MARK: - Lesson Section

struct LessonSection: Codable, Identifiable {
    let id: String?
    let type: SectionType
    let title: String?
    let content: String
    let steps: [String]?
    let hint: String?

    var stableId: String {
        id ?? "\(type.rawValue)-\(title ?? "untitled")"
    }

    enum CodingKeys: String, CodingKey {
        case id, type, title, content, steps, hint
    }
}

// MARK: - Worked Example

struct WorkedExample: Codable, Identifiable {
    let id: String?
    let title: String
    let problem: String
    let steps: [String]
    let answer: String
    let explanation: String

    var stableId: String {
        id ?? title
    }

    enum CodingKeys: String, CodingKey {
        case id, title, problem, steps, answer, solution, explanation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        problem = try container.decode(String.self, forKey: .problem)
        steps = try container.decode([String].self, forKey: .steps)
        // Handle both "answer" and "solution" keys
        if let ans = try container.decodeIfPresent(String.self, forKey: .answer) {
            answer = ans
        } else if let sol = try container.decodeIfPresent(String.self, forKey: .solution) {
            answer = sol
        } else {
            answer = ""
        }
        explanation = try container.decode(String.self, forKey: .explanation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(problem, forKey: .problem)
        try container.encode(steps, forKey: .steps)
        try container.encode(answer, forKey: .answer)
        try container.encode(explanation, forKey: .explanation)
    }
}

// MARK: - Lesson

struct Lesson: Codable, Identifiable {
    let slug: String
    let title: String
    let description: String
    let strandSlug: StrandSlug
    let levelSlug: String
    let order: Int
    let difficulty: Difficulty
    let estimatedMinutes: Int
    let sections: [LessonSection]
    let workedExamples: [WorkedExample]
    let prerequisites: [String]
    let objectives: [String]

    var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case id, slug, title, description, strandSlug, levelSlug
        case order, difficulty, estimatedMinutes, sections
        case workedExamples, prerequisites, objectives
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Use "slug" if present, otherwise fall back to "id"
        if let s = try container.decodeIfPresent(String.self, forKey: .slug) {
            slug = s
        } else {
            slug = try container.decode(String.self, forKey: .id)
        }
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        strandSlug = try container.decode(StrandSlug.self, forKey: .strandSlug)
        levelSlug = try container.decode(String.self, forKey: .levelSlug)
        order = try container.decode(Int.self, forKey: .order)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        estimatedMinutes = try container.decode(Int.self, forKey: .estimatedMinutes)
        sections = try container.decode([LessonSection].self, forKey: .sections)
        workedExamples = try container.decodeIfPresent([WorkedExample].self, forKey: .workedExamples) ?? []
        prerequisites = try container.decodeIfPresent([String].self, forKey: .prerequisites) ?? []
        objectives = try container.decodeIfPresent([String].self, forKey: .objectives) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(slug, forKey: .slug)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(strandSlug, forKey: .strandSlug)
        try container.encode(levelSlug, forKey: .levelSlug)
        try container.encode(order, forKey: .order)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(estimatedMinutes, forKey: .estimatedMinutes)
        try container.encode(sections, forKey: .sections)
        try container.encode(workedExamples, forKey: .workedExamples)
        try container.encode(prerequisites, forKey: .prerequisites)
        try container.encode(objectives, forKey: .objectives)
    }
}
