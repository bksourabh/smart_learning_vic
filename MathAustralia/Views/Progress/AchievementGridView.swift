import SwiftUI

struct AchievementGridView: View {
    let child: ChildProfile
    @Environment(CurriculumService.self) private var curriculumService

    private var definitions: [AchievementDefinition] {
        curriculumService.getAchievementDefinitions()
    }

    private func isUnlocked(_ achievementId: String) -> Bool {
        child.achievements.contains { $0.achievementId == achievementId }
    }

    private func unlockedDate(_ achievementId: String) -> Date? {
        child.achievements.first { $0.achievementId == achievementId }?.unlockedAt
    }

    private var unlockedCount: Int {
        definitions.filter { isUnlocked($0.id) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Counter
            Text("\(unlockedCount)/\(definitions.count) Unlocked")
                .font(.caption.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ], spacing: Spacing.sm) {
                ForEach(Array(definitions.enumerated()), id: \.element.id) { index, definition in
                    AchievementBadge(
                        definition: definition,
                        isUnlocked: isUnlocked(definition.id),
                        unlockedDate: unlockedDate(definition.id)
                    )
                    .staggeredEntrance(index: index)
                }
            }
        }
    }
}

private struct AchievementBadge: View {
    let definition: AchievementDefinition
    let isUnlocked: Bool
    let unlockedDate: Date?

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                if isUnlocked {
                    // Gold gradient background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [BrandColors.victorianGoldLight.opacity(0.3), BrandColors.victorianGold.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [BrandColors.victorianGoldLight, BrandColors.victorianGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 56, height: 56)
                } else {
                    Circle()
                        .fill(.gray.opacity(0.08))
                        .frame(width: 56, height: 56)
                }

                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? BrandColors.victorianGold : .gray)
            }

            Text(definition.name)
                .font(.caption.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(definition.description)
                .font(.caption2)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .appCard()
        .opacity(isUnlocked ? 1 : 0.6)
        .overlay {
            if isUnlocked {
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .strokeBorder(
                        LinearGradient(
                            colors: [BrandColors.victorianGoldLight.opacity(0.4), BrandColors.victorianGold.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
    }

    private var iconName: String {
        switch definition.icon {
        case "Footprints": return "figure.walk"
        case "BookOpen": return "book.fill"
        case "Trophy": return "trophy.fill"
        case "Flame": return "flame.fill"
        case "Calendar": return "calendar"
        case "Award": return "medal.fill"
        case "Star": return "star.fill"
        case "Crown": return "crown.fill"
        default: return "star.fill"
        }
    }
}
