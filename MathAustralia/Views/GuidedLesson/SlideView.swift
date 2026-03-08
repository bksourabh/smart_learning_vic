import SwiftUI

struct SlideView: View {
    let slide: GuidedSlide
    let strandSlug: StrandSlug
    let slideIndex: Int

    @State private var appeared = false

    private var strandColor: Color {
        StrandColorSet.primary(for: strandSlug)
    }

    private var sectionIcon: String {
        switch slide.sectionType {
        case .introduction: return "book.fill"
        case .explanation: return "lightbulb.fill"
        case .example: return "pencil.and.outline"
        case .keyConcept: return "star.fill"
        case .practicePrompt: return "hand.point.right.fill"
        case .summary: return "checkmark.seal.fill"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Section type + title
                HStack(spacing: Spacing.xs) {
                    Image(systemName: sectionIcon)
                        .foregroundStyle(strandColor)
                        .font(.caption)

                    Text(sectionTypeName(slide.sectionType))
                        .font(.caption2.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(strandColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(strandColor.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()
                }

                Text(slide.title)
                    .font(.title3.bold())
                    .fontDesign(.rounded)

                // Visual component
                VisualComponentFactory.visualComponent(for: slide.visualContext)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .fill(.regularMaterial)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))

                // Text content
                SmartTextView(slide.displayContent)
                    .padding(.top, Spacing.xs)
            }
            .padding()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                appeared = true
            }
        }
    }

    private func sectionTypeName(_ type: SectionType) -> String {
        switch type {
        case .introduction: return "Introduction"
        case .explanation: return "Explanation"
        case .example: return "Example"
        case .keyConcept: return "Key Concept"
        case .practicePrompt: return "Practice"
        case .summary: return "Summary"
        }
    }
}
