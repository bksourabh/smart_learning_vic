import SwiftUI

struct SlideProgressBar: View {
    let totalSlides: Int
    let currentIndex: Int
    let strandColor: Color
    let onTapSlide: (Int) -> Void

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalSlides, id: \.self) { index in
                Button {
                    onTapSlide(index)
                } label: {
                    Capsule()
                        .fill(index <= currentIndex ? strandColor : strandColor.opacity(0.2))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}
