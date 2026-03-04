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

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(definitions) { definition in
                AchievementBadge(
                    definition: definition,
                    isUnlocked: isUnlocked(definition.id),
                    unlockedDate: unlockedDate(definition.id)
                )
            }
        }
    }
}

private struct AchievementBadge: View {
    let definition: AchievementDefinition
    let isUnlocked: Bool
    let unlockedDate: Date?

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? .yellow.opacity(0.2) : .gray.opacity(0.1))
                    .frame(width: 56, height: 56)

                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? .yellow : .gray)
            }

            Text(definition.name)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(definition.description)
                .font(.caption2)
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
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isUnlocked ? 1 : 0.6)
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
