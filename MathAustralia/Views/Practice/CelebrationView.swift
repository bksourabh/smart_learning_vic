import SwiftUI

struct CelebrationView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    private let colors: [Color] = [
        Color(hex: "#f59e0b"), // Amber
        Color(hex: "#8b5cf6"), // Purple
        Color(hex: "#10b981"), // Green
        Color(hex: "#f43f5e"), // Rose
        Color(hex: "#06b6d4"), // Cyan
        .yellow, .blue, .pink, .orange
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Text(particle.emoji)
                        .font(.system(size: particle.size))
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                createParticles(in: geo.size)
                animateParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            ConfettiParticle(
                emoji: ["🎉", "⭐", "✨", "🌟", "💫", "🎊"].randomElement()!,
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                size: CGFloat.random(in: 14...28),
                rotation: Double.random(in: 0...360),
                opacity: 1.0,
                velocity: CGFloat.random(in: 2...6),
                horizontalDrift: CGFloat.random(in: -2...2)
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            var allDone = true
            for i in particles.indices {
                particles[i].position.y += particles[i].velocity
                particles[i].position.x += particles[i].horizontalDrift
                particles[i].rotation += Double.random(in: -5...5)

                if particles[i].position.y > size.height * 0.7 {
                    particles[i].opacity -= 0.02
                }

                if particles[i].opacity > 0 {
                    allDone = false
                }
            }

            if allDone {
                timer.invalidate()
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    let size: CGFloat
    var rotation: Double
    var opacity: Double
    let velocity: CGFloat
    let horizontalDrift: CGFloat
}
