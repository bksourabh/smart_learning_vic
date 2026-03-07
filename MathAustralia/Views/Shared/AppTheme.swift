import SwiftUI
import UIKit

// MARK: - Brand Colors

enum BrandColors {
    static let victorianNavy = Color(hex: "#1a1a2e")
    static let victorianGold = Color(hex: "#C5A547")
    static let victorianGoldLight = Color(hex: "#D4B85A")
    static let victorianGoldDark = Color(hex: "#A88B35")

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e"), Color(hex: "#0f3460")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [victorianGoldLight, victorianGold, victorianGoldDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Spacing Scale

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}

// MARK: - Corner Radius Scale

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Shadow System

enum AppShadow {
    static func small(_ color: Color = .black.opacity(0.08)) -> some View {
        Color.clear.shadow(color: color, radius: 4, x: 0, y: 2)
    }

    static func medium(_ color: Color = .black.opacity(0.1)) -> some View {
        Color.clear.shadow(color: color, radius: 8, x: 0, y: 4)
    }

    static func large(_ color: Color = .black.opacity(0.12)) -> some View {
        Color.clear.shadow(color: color, radius: 16, x: 0, y: 8)
    }
}

// MARK: - App Card ViewModifier

struct AppCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowColor: Color

    init(cornerRadius: CGFloat = CornerRadius.medium, shadowColor: Color = .black.opacity(0.08)) {
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
    }

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
    }
}

extension View {
    func appCard(cornerRadius: CGFloat = CornerRadius.medium, shadowColor: Color = .black.opacity(0.08)) -> some View {
        modifier(AppCardModifier(cornerRadius: cornerRadius, shadowColor: shadowColor))
    }
}

// MARK: - Victorian Curriculum Badge

struct VictorianCurriculumBadge: View {
    enum BadgeSize {
        case small, medium, large
    }

    let size: BadgeSize

    init(size: BadgeSize = .medium) {
        self.size = size
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 14
        case .medium: return 18
        case .large: return 22
        }
    }

    private var fontSize: Font {
        switch size {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .subheadline
        }
    }

    private var paddingH: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return 10
        case .large: return 14
        }
    }

    private var paddingV: CGFloat {
        switch size {
        case .small: return 4
        case .medium: return 5
        case .large: return 7
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "seal.fill")
                .font(.system(size: iconSize))
                .foregroundStyle(BrandColors.victorianGold)

            Text("Victorian Curriculum")
                .font(fontSize.weight(.semibold))
                .fontDesign(.rounded)
                .foregroundStyle(BrandColors.victorianGold)
        }
        .padding(.horizontal, paddingH)
        .padding(.vertical, paddingV)
        .background(BrandColors.victorianGold.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Haptic Feedback Utility

enum Haptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Animated Press Button Style

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressButtonStyle {
    static var press: PressButtonStyle { PressButtonStyle() }
}

// MARK: - Rounded Font Design Extension

extension View {
    func roundedFont() -> some View {
        fontDesign(.rounded)
    }
}

// MARK: - Decorative Math Symbols Background

struct MathSymbolsBackground: View {
    let symbols = ["+", "-", "×", "÷", "=", "π", "√", "∑", "%", "∞"]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { index in
                let seed = index
                Text(symbols[seed % symbols.count])
                    .font(.system(size: CGFloat(14 + (seed * 7) % 20)))
                    .foregroundStyle(.white.opacity(0.06))
                    .position(
                        x: CGFloat((seed * 97 + 23) % Int(max(geo.size.width, 1))),
                        y: CGFloat((seed * 67 + 41) % Int(max(geo.size.height, 1)))
                    )
                    .rotationEffect(.degrees(Double((seed * 37) % 360)))
            }
        }
    }
}

// MARK: - Gradient Icon Circle

struct GradientIconCircle: View {
    let systemName: String
    let gradient: LinearGradient
    let size: CGFloat
    let iconSize: CGFloat

    init(systemName: String, gradient: LinearGradient, size: CGFloat = 48, iconSize: CGFloat = 24) {
        self.systemName = systemName
        self.gradient = gradient
        self.size = size
        self.iconSize = iconSize
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: iconSize))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.25))
    }
}

// MARK: - Staggered Entrance Animation

private struct StaggeredEntranceModifier: ViewModifier {
    let index: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(
                .spring(duration: 0.45, bounce: 0.15)
                    .delay(min(Double(index) * 0.06, 0.6)),
                value: appeared
            )
            .onAppear { appeared = true }
    }
}

extension View {
    func staggeredEntrance(index: Int) -> some View {
        modifier(StaggeredEntranceModifier(index: index))
    }
}

// MARK: - Glass Card Modifier

private struct GlassCardModifier: ViewModifier {
    let tint: Color

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .strokeBorder(tint.opacity(0.12), lineWidth: 0.5)
            )
            .shadow(color: tint.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func glassCard(tint: Color = .blue) -> some View {
        modifier(GlassCardModifier(tint: tint))
    }
}

// MARK: - Glow Effect

extension View {
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.3), radius: radius / 2)
            .shadow(color: color.opacity(0.15), radius: radius)
    }
}

// MARK: - Bounce Button Style

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(duration: 0.25, bounce: 0.4), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BounceButtonStyle {
    static var bounce: BounceButtonStyle { BounceButtonStyle() }
}
