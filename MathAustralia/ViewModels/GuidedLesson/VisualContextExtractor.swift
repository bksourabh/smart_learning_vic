import Foundation

// MARK: - Math Operation

enum MathOperation: String, CaseIterable {
    case addition
    case subtraction
    case multiplication
    case division

    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }
}

// MARK: - Visual Component Type

enum VisualComponentType {
    case numberLine
    case placeValueBlocks
    case fractionBars
    case shapeDisplay
    case patternSequence
    case measurementScale
    case generic
}

// MARK: - Visual Context

struct VisualContext {
    let numbers: [Double]
    let fractions: [(Int, Int)]
    let operation: MathOperation?
    let keywords: [String]
    let strandSlug: StrandSlug
    let componentType: VisualComponentType

    static func empty(strand: StrandSlug) -> VisualContext {
        VisualContext(
            numbers: [],
            fractions: [],
            operation: nil,
            keywords: [],
            strandSlug: strand,
            componentType: .generic
        )
    }
}

// MARK: - Visual Context Extractor

enum VisualContextExtractor {

    static func extract(from content: String, sectionType: SectionType, strand: StrandSlug) -> VisualContext {
        let numbers = extractNumbers(from: content)
        let fractions = extractFractions(from: content)
        let operation = extractOperation(from: content)
        let keywords = extractKeywords(from: content)

        let componentType = determineComponentType(
            strand: strand,
            keywords: keywords,
            hasFractions: !fractions.isEmpty,
            operation: operation,
            sectionType: sectionType
        )

        return VisualContext(
            numbers: numbers,
            fractions: fractions,
            operation: operation,
            keywords: keywords,
            strandSlug: strand,
            componentType: componentType
        )
    }

    // MARK: - Number Extraction

    private static func extractNumbers(from content: String) -> [Double] {
        let pattern = #"(?<![a-zA-Z])(\d+\.?\d*)(?![a-zA-Z])"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))

        var numbers: [Double] = []
        for match in matches.prefix(6) {
            if let range = Range(match.range(at: 1), in: content),
               let num = Double(content[range]) {
                numbers.append(num)
            }
        }
        return numbers
    }

    // MARK: - Fraction Extraction

    private static func extractFractions(from content: String) -> [(Int, Int)] {
        let pattern = #"\\frac\{(\d+)\}\{(\d+)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))

        var fractions: [(Int, Int)] = []
        for match in matches.prefix(4) {
            if let numRange = Range(match.range(at: 1), in: content),
               let denRange = Range(match.range(at: 2), in: content),
               let num = Int(content[numRange]),
               let den = Int(content[denRange]) {
                fractions.append((num, den))
            }
        }
        return fractions
    }

    // MARK: - Operation Extraction

    private static func extractOperation(from content: String) -> MathOperation? {
        let lower = content.lowercased()
        if lower.contains("\\times") || lower.contains("multiply") || lower.contains("multiplication") || lower.contains("product") {
            return .multiplication
        }
        if lower.contains("\\div") || lower.contains("divide") || lower.contains("division") || lower.contains("quotient") {
            return .division
        }
        if lower.contains("subtract") || lower.contains("minus") || lower.contains("difference") || lower.contains("take away") {
            return .subtraction
        }
        if lower.contains("addition") || lower.contains("add ") || lower.contains("plus") || lower.contains("sum ") {
            return .addition
        }
        return nil
    }

    // MARK: - Keyword Extraction

    private static func extractKeywords(from content: String) -> [String] {
        let lower = content.lowercased()
        let allKeywords = [
            "fraction", "decimal", "percentage", "percent",
            "place value", "number line", "rounding",
            "area", "perimeter", "angle", "triangle", "rectangle", "circle", "square", "polygon", "shape",
            "pattern", "sequence", "algebra", "equation", "variable",
            "length", "mass", "capacity", "volume", "temperature", "time", "unit", "convert",
            "data", "graph", "chart", "mean", "median", "mode", "probability",
            "negative", "integer", "whole number", "counting",
            "symmetry", "reflection", "rotation", "translation",
        ]
        return allKeywords.filter { lower.contains($0) }
    }

    // MARK: - Component Type Determination

    private static func determineComponentType(
        strand: StrandSlug,
        keywords: [String],
        hasFractions: Bool,
        operation: MathOperation?,
        sectionType: SectionType
    ) -> VisualComponentType {
        // Fractions take priority if present
        if hasFractions || keywords.contains("fraction") || keywords.contains("decimal") || keywords.contains("percentage") || keywords.contains("percent") {
            return .fractionBars
        }

        // Strand-specific defaults
        switch strand {
        case .number:
            if keywords.contains("place value") {
                return .placeValueBlocks
            }
            if keywords.contains("number line") || keywords.contains("rounding") || keywords.contains("negative") || keywords.contains("integer") {
                return .numberLine
            }
            if operation != nil {
                return .numberLine
            }
            return .placeValueBlocks

        case .algebra:
            return .patternSequence

        case .measurement:
            return .measurementScale

        case .space:
            return .shapeDisplay

        case .statistics:
            if keywords.contains("pattern") || keywords.contains("sequence") {
                return .patternSequence
            }
            return .generic
        }
    }
}
