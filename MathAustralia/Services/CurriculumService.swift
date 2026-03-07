import Foundation

@Observable
final class CurriculumService {
    private var curriculumData: CurriculumData?
    private var lessonsCache: [String: [Lesson]] = [:]
    private var practiceCache: [String: PracticeTest] = [:]
    private var achievementDefinitions: [AchievementDefinition]?

    var levels: [LevelMeta] {
        loadCurriculumIfNeeded()
        return curriculumData?.levels.sorted(by: { $0.order < $1.order }) ?? []
    }

    var strands: [StrandDefinition] {
        loadCurriculumIfNeeded()
        return curriculumData?.strands ?? []
    }

    // MARK: - Curriculum

    func getLevel(bySlug slug: String) -> LevelMeta? {
        levels.first { $0.slug == slug }
    }

    func getStrand(bySlug slug: StrandSlug) -> StrandDefinition? {
        strands.first { $0.slug == slug }
    }

    func getStrandsForLevel(_ levelSlug: String) -> [StrandOverview] {
        StrandSlug.allCases.map { strandSlug in
            let lessons = getLessons(levelSlug: levelSlug, strandSlug: strandSlug.rawValue)
            let practice = getPractice(levelSlug: levelSlug, strandSlug: strandSlug.rawValue)
            let strand = getStrand(bySlug: strandSlug)
            return StrandOverview(
                strandSlug: strandSlug,
                levelSlug: levelSlug,
                lessonCount: lessons.count,
                practiceAvailable: practice != nil,
                description: strand?.description ?? ""
            )
        }
    }

    // MARK: - Lessons

    func getLessons(levelSlug: String, strandSlug: String) -> [Lesson] {
        let key = "\(levelSlug)/\(strandSlug)"
        if let cached = lessonsCache[key] {
            return cached
        }

        guard let url = Bundle.main.url(
            forResource: "lessons",
            withExtension: "json",
            subdirectory: "Data/levels/\(levelSlug)/\(strandSlug)"
        ) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let lessons = try JSONDecoder().decode([Lesson].self, from: data)
            let sorted = lessons.sorted(by: { $0.order < $1.order })
            lessonsCache[key] = sorted
            return sorted
        } catch {
            print("Error loading lessons for \(key): \(error)")
            return []
        }
    }

    func getLesson(levelSlug: String, strandSlug: String, lessonSlug: String) -> Lesson? {
        getLessons(levelSlug: levelSlug, strandSlug: strandSlug)
            .first { $0.slug == lessonSlug }
    }

    func getAllLessons() -> [Lesson] {
        var all: [Lesson] = []
        for level in levels {
            for strand in StrandSlug.allCases {
                all.append(contentsOf: getLessons(levelSlug: level.slug, strandSlug: strand.rawValue))
            }
        }
        return all
    }

    // MARK: - Practice

    func getPractice(levelSlug: String, strandSlug: String) -> PracticeTest? {
        let key = "\(levelSlug)/\(strandSlug)"
        if let cached = practiceCache[key] {
            return cached
        }

        guard let url = Bundle.main.url(
            forResource: "practice",
            withExtension: "json",
            subdirectory: "Data/levels/\(levelSlug)/\(strandSlug)"
        ) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let practice = try JSONDecoder().decode(PracticeTest.self, from: data)
            practiceCache[key] = practice
            return practice
        } catch {
            print("Error loading practice for \(key): \(error)")
            return nil
        }
    }

    func getAllPracticeTests() -> [PracticeTest] {
        var all: [PracticeTest] = []
        for level in levels {
            for strand in StrandSlug.allCases {
                if let practice = getPractice(levelSlug: level.slug, strandSlug: strand.rawValue) {
                    all.append(practice)
                }
            }
        }
        return all
    }

    // MARK: - Achievements

    func getAchievementDefinitions() -> [AchievementDefinition] {
        if let cached = achievementDefinitions {
            return cached
        }

        guard let url = Bundle.main.url(forResource: "achievements", withExtension: "json", subdirectory: "Data") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let definitions = try JSONDecoder().decode([AchievementDefinition].self, from: data)
            achievementDefinitions = definitions
            return definitions
        } catch {
            print("Error loading achievements: \(error)")
            return []
        }
    }

    // MARK: - Preloading

    /// Pre-warm all lesson and practice caches. File I/O runs on a background queue,
    /// cache writes happen on main thread for @Observable safety.
    func preloadAll() {
        loadCurriculumIfNeeded()
        guard let data = curriculumData else { return }

        // Collect all keys that need loading (skip already-cached)
        var keysToLoad: [(levelSlug: String, strandSlug: String)] = []
        for level in data.levels {
            for strand in StrandSlug.allCases {
                let key = "\(level.slug)/\(strand.rawValue)"
                if lessonsCache[key] == nil || practiceCache[key] == nil {
                    keysToLoad.append((level.slug, strand.rawValue))
                }
            }
        }
        guard !keysToLoad.isEmpty else { return }

        // Read and decode files off the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            var lessons: [String: [Lesson]] = [:]
            var practice: [String: PracticeTest] = [:]

            for (levelSlug, strandSlug) in keysToLoad {
                let key = "\(levelSlug)/\(strandSlug)"

                if let url = Bundle.main.url(forResource: "lessons", withExtension: "json",
                                             subdirectory: "Data/levels/\(levelSlug)/\(strandSlug)"),
                   let fileData = try? Data(contentsOf: url),
                   let decoded = try? JSONDecoder().decode([Lesson].self, from: fileData) {
                    lessons[key] = decoded.sorted(by: { $0.order < $1.order })
                }

                if let url = Bundle.main.url(forResource: "practice", withExtension: "json",
                                             subdirectory: "Data/levels/\(levelSlug)/\(strandSlug)"),
                   let fileData = try? Data(contentsOf: url),
                   let decoded = try? JSONDecoder().decode(PracticeTest.self, from: fileData) {
                    practice[key] = decoded
                }
            }

            // Merge into caches on main thread
            DispatchQueue.main.async { [self] in
                for (key, value) in lessons {
                    if lessonsCache[key] == nil { lessonsCache[key] = value }
                }
                for (key, value) in practice {
                    if practiceCache[key] == nil { practiceCache[key] = value }
                }
            }
        }
    }

    // MARK: - Private

    private func loadCurriculumIfNeeded() {
        guard curriculumData == nil else { return }

        guard let url = Bundle.main.url(forResource: "curriculum", withExtension: "json", subdirectory: "Data") else {
            print("curriculum.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            curriculumData = try JSONDecoder().decode(CurriculumData.self, from: data)
        } catch {
            print("Error loading curriculum: \(error)")
        }
    }
}
