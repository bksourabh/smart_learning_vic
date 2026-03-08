import SwiftUI

struct SpeechControlBar: View {
    let speechService: SpeechService
    let strandColor: Color
    let onPrevious: () -> Void
    let onNext: () -> Void

    @State private var showVoiceTip = false

    private var speedLabel: String {
        let r = speechService.rate
        if r <= 0.4 { return "0.75x" }
        if r <= 0.52 { return "1x" }
        return "1.25x"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Voice quality tip banner
            if showVoiceTip && speechService.shouldSuggestVoiceDownload {
                voiceDownloadTip
            }

            HStack(spacing: Spacing.xl) {
                // Voice gender toggle + quality indicator
                Button {
                    Haptics.selection()
                    speechService.voiceGender = speechService.voiceGender == .female ? .male : .female
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: speechService.voiceGender.icon)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        qualityDot
                    }
                }

                // Speed control
                Button {
                    Haptics.selection()
                    cycleSpeed()
                } label: {
                    Text(speedLabel)
                        .font(.caption.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                }

                // Previous
                Button {
                    Haptics.selection()
                    onPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }

                // Play/Pause (large, centered)
                Button {
                    Haptics.impact(.medium)
                    if speechService.isSpeaking || speechService.isPaused {
                        speechService.togglePlayPause()
                    }
                } label: {
                    Image(systemName: speechService.isSpeaking && !speechService.isPaused
                          ? "pause.circle.fill"
                          : "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(strandColor)
                        .symbolRenderingMode(.hierarchical)
                }

                // Next
                Button {
                    Haptics.selection()
                    onNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }

                // Voice quality info button
                Button {
                    Haptics.selection()
                    withAnimation(.spring(duration: 0.3)) {
                        showVoiceTip.toggle()
                    }
                } label: {
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                    .frame(width: 8)
            }
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Voice Quality Dot

    private var qualityDot: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(qualityColor)
                .frame(width: 5, height: 5)
            Text(speechService.voiceQualityLevel.rawValue)
                .font(.system(size: 8, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var qualityColor: Color {
        switch speechService.voiceQualityLevel {
        case .premium: return .green
        case .enhanced: return .blue
        case .standard: return .orange
        }
    }

    // MARK: - Voice Download Tip

    private var voiceDownloadTip: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.orange)
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 2) {
                Text("Get a more natural voice")
                    .font(.caption.bold())
                    .fontDesign(.rounded)
                Text("Settings > Accessibility > Spoken Content > Voices > English (Australia) — download \"Karen\" or \"Lee\" Enhanced/Premium")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation { showVoiceTip = false }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding(Spacing.sm)
        .background(.orange.opacity(0.08))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Speed Cycling

    private func cycleSpeed() {
        if speechService.rate <= 0.4 {
            speechService.rate = 0.48 // 1x (default educational pace)
        } else if speechService.rate <= 0.52 {
            speechService.rate = 0.58 // 1.25x
        } else {
            speechService.rate = 0.38 // 0.75x
        }
    }
}
