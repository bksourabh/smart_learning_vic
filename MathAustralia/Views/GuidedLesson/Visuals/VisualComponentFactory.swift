import SwiftUI

enum VisualComponentFactory {

    @ViewBuilder
    static func visualComponent(for context: VisualContext) -> some View {
        let color = StrandColorSet.primary(for: context.strandSlug)

        switch context.componentType {
        case .numberLine:
            NumberLineView(
                numbers: context.numbers.isEmpty ? [3, 7] : Array(context.numbers.prefix(4)),
                operation: context.operation,
                strandColor: color
            )

        case .placeValueBlocks:
            PlaceValueBlocksView(
                numbers: context.numbers.isEmpty ? [345] : context.numbers,
                strandColor: color
            )

        case .fractionBars:
            FractionBarsView(
                fractions: context.fractions.isEmpty ? [(1, 2), (3, 4)] : context.fractions,
                strandColor: color
            )

        case .shapeDisplay:
            ShapeDisplayView(
                keywords: context.keywords,
                numbers: context.numbers,
                strandColor: color
            )

        case .patternSequence:
            PatternSequenceView(
                numbers: context.numbers,
                strandColor: color
            )

        case .measurementScale:
            MeasurementScaleView(
                numbers: context.numbers,
                keywords: context.keywords,
                strandColor: color
            )

        case .generic:
            GenericIllustrationView(
                strandSlug: context.strandSlug,
                strandColor: color
            )
        }
    }
}
