import Foundation

// MARK: - Strand

enum StrandSlug: String, Codable, CaseIterable, Identifiable {
    case number
    case algebra
    case measurement
    case space
    case statistics

    var id: String { rawValue }
}

struct StrandColors: Codable {
    let primary: String
    let secondary: String
    let bg: String
    let bgDark: String
    let text: String
    let border: String
}

struct StrandDefinition: Codable, Identifiable {
    let slug: StrandSlug
    let name: String
    let fullName: String
    let description: String
    let icon: String
    let colors: StrandColors

    var id: String { slug.rawValue }
}

// MARK: - Level

struct LevelMeta: Codable, Identifiable {
    let slug: String
    let name: String
    let shortName: String
    let yearRange: String
    let description: String
    let color: String
    let order: Int
    let achievementStandard: String

    var id: String { slug }
}

// MARK: - Curriculum Bundle

struct CurriculumData: Codable {
    let strands: [StrandDefinition]
    let levels: [LevelMeta]
}

// MARK: - Strand Overview

struct StrandOverview: Identifiable {
    let strandSlug: StrandSlug
    let levelSlug: String
    let lessonCount: Int
    let practiceAvailable: Bool
    let description: String

    var id: String { "\(levelSlug)-\(strandSlug.rawValue)" }
}
