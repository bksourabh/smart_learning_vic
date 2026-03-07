import SwiftUI

enum AppConstants {
    static let siteName = "Math Australia"
    static let siteDescription = "Master Maths, One Level at a Time — Victorian Curriculum Aligned"

    static let xpPerLesson = 10
    static let xpPerPractice = 25
    static let xpBonusPerfect = 50
    static let xpPracticeFail = 5

    static let numericTolerance = 0.001

    static let childAvatars = ["🧒", "👦", "👧", "🧒🏻", "👦🏻", "👧🏻", "🧒🏽", "👦🏽", "👧🏽", "🧒🏿", "👦🏿", "👧🏿", "🦊", "🐻", "🐼", "🦁", "🐨", "🐯", "🦄", "🐸"]

    static let difficultyLabels: [String: String] = [
        "easy": "Beginner",
        "medium": "Intermediate",
        "hard": "Advanced"
    ]
}

// MARK: - Strand Colors

enum StrandColorSet {
    static func primary(for strand: StrandSlug) -> Color {
        switch strand {
        case .number: return Color(hex: "#f59e0b")      // Amber
        case .algebra: return Color(hex: "#8b5cf6")     // Purple
        case .measurement: return Color(hex: "#10b981") // Green
        case .space: return Color(hex: "#f43f5e")       // Rose
        case .statistics: return Color(hex: "#06b6d4")   // Cyan
        }
    }

    static func background(for strand: StrandSlug) -> Color {
        switch strand {
        case .number: return Color(hex: "#fffbeb")
        case .algebra: return Color(hex: "#f5f3ff")
        case .measurement: return Color(hex: "#ecfdf5")
        case .space: return Color(hex: "#fff1f2")
        case .statistics: return Color(hex: "#ecfeff")
        }
    }

    static func icon(for strand: StrandSlug) -> String {
        switch strand {
        case .number: return "number"
        case .algebra: return "x.squareroot"
        case .measurement: return "ruler"
        case .space: return "cube"
        case .statistics: return "chart.bar"
        }
    }

    static func gradient(for strand: StrandSlug) -> LinearGradient {
        let base = primary(for: strand)
        return LinearGradient(
            colors: [base.opacity(0.9), base],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func lightGradient(for strand: StrandSlug) -> LinearGradient {
        let base = primary(for: strand)
        return LinearGradient(
            colors: [base.opacity(0.08), base.opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func adaptiveBackground(for strand: StrandSlug, colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return primary(for: strand).opacity(0.15)
        }
        return background(for: strand)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
