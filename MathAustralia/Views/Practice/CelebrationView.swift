import SwiftUI

struct CelebrationView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var startTime: Date?

    private let strandColors: [Color] = [
        Color(hex: "#f59e0b"), // Amber
        Color(hex: "#8b5cf6"), // Purple
        Color(hex: "#10b981"), // Green
        Color(hex: "#f43f5e"), // Rose
        Color(hex: "#06b6d4"), // Cyan
        .yellow, .blue, .pink, .orange
    ]

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                Canvas { context, size in
                    for particle in particles {
                        guard particle.opacity > 0 else { continue }
                        var transform = CGAffineTransform.identity
                        transform = transform.translatedBy(x: particle.position.x, y: particle.position.y)
                        transform = transform.rotated(by: particle.rotation * .pi / 180)
                        transform = transform.translatedBy(x: -particle.size / 2, y: -particle.size / 2)
                        context.opacity = particle.opacity
                        context.fill(
                            particle.path.applying(transform),
                            with: .color(particle.color)
                        )
                    }
                }
                .onChange(of: timeline.date) { _, now in
                    updateParticles(in: geo.size, now: now)
                }
            }

            // Screen glow
            RadialGradient(
                colors: [.yellow.opacity(0.08), .clear],
                center: .center,
                startRadius: 0,
                endRadius: geo.size.height * 0.5
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            Color.clear
                .onAppear {
                    Haptics.success()
                    createParticles(in: geo.size)
                    startTime = Date()
                }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<50).map { index in
            let shapeType = index % 3
            let pSize = CGFloat.random(in: 6...16)
            let path: Path
            if shapeType == 0 {
                path = Path(ellipseIn: CGRect(origin: .zero, size: CGSize(width: pSize, height: pSize)))
            } else if shapeType == 1 {
                path = Path(roundedRect: CGRect(origin: .zero, size: CGSize(width: pSize, height: pSize * 0.6)), cornerRadius: 2)
            } else {
                path = Star().path(in: CGRect(origin: .zero, size: CGSize(width: pSize, height: pSize)))
            }
            return ConfettiParticle(
                path: path,
                color: strandColors[index % strandColors.count],
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: -40...(-10))
                ),
                size: pSize,
                rotation: Double.random(in: 0...360),
                opacity: 1.0,
                velocity: CGFloat.random(in: 2...5),
                horizontalDrift: CGFloat.random(in: -2...2)
            )
        }
    }

    private func updateParticles(in size: CGSize, now: Date) {
        guard let start = startTime else { return }
        let elapsed = now.timeIntervalSince(start)
        if elapsed > 4.0 { return } // Stop after 4 seconds

        for i in particles.indices {
            particles[i].position.y += particles[i].velocity
            particles[i].position.x += particles[i].horizontalDrift
            particles[i].rotation += Double.random(in: -3...3)

            if particles[i].position.y > size.height * 0.7 {
                particles[i].opacity -= 0.025
            }
        }
    }
}

// MARK: - Star Shape

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5

        var path = Path()
        for i in 0..<points * 2 {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let path: Path
    let color: Color
    var position: CGPoint
    let size: CGFloat
    var rotation: Double
    var opacity: Double
    let velocity: CGFloat
    let horizontalDrift: CGFloat
}
