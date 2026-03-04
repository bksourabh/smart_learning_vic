import Foundation
import SwiftData

@Observable
final class AchievementService {
    private let modelContext: ModelContext
    private let curriculumService: CurriculumService
    private let progressService: ProgressService
    private let streakService: StreakService

    init(modelContext: ModelContext, curriculumService: CurriculumService,
         progressService: ProgressService, streakService: StreakService) {
        self.modelContext = modelContext
        self.curriculumService = curriculumService
        self.progressService = progressService
        self.streakService = streakService
    }

    func checkAndUnlock(for child: ChildProfile) {
        let definitions = curriculumService.getAchievementDefinitions()
        let unlockedIds = Set(child.achievements.map { $0.achievementId })

        for definition in definitions {
            guard !unlockedIds.contains(definition.id) else { continue }

            if shouldUnlock(definition: definition, for: child) {
                let record = AchievementRecord(achievementId: definition.id)
                record.child = child
                modelContext.insert(record)
            }
        }

        try? modelContext.save()
    }

    func isUnlocked(achievementId: String, for child: ChildProfile) -> Bool {
        child.achievements.contains { $0.achievementId == achievementId }
    }

    func unlockedCount(for child: ChildProfile) -> Int {
        child.achievements.count
    }

    // MARK: - Private

    private func shouldUnlock(definition: AchievementDefinition, for child: ChildProfile) -> Bool {
        switch definition.condition {
        case .firstLesson:
            return progressService.completedLessonsCount(for: child) >= definition.value

        case .lessonsCompleted:
            return progressService.completedLessonsCount(for: child) >= definition.value

        case .perfectScore:
            return progressService.hasPerfectScore(for: child)

        case .streak:
            return streakService.currentStreak(for: child) >= definition.value

        case .strandCompleted:
            // Check if any strand in any level is fully completed
            for level in curriculumService.levels {
                for strand in StrandSlug.allCases {
                    let totalLessons = curriculumService.getLessons(
                        levelSlug: level.slug, strandSlug: strand.rawValue
                    ).count
                    let completedLessons = progressService.completedLessonsCount(
                        levelSlug: level.slug, strandSlug: strand.rawValue, for: child
                    )
                    if totalLessons > 0 && completedLessons >= totalLessons {
                        return true
                    }
                }
            }
            return false
        }
    }
}
