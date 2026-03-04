import XCTest
@testable import MathAustralia

final class CurriculumServiceTests: XCTestCase {
    var service: CurriculumService!

    override func setUp() {
        super.setUp()
        service = CurriculumService()
    }

    func testLoadLevels() {
        let levels = service.levels
        XCTAssertEqual(levels.count, 11, "Should load 11 levels")
        XCTAssertEqual(levels.first?.slug, "foundation")
        XCTAssertEqual(levels.last?.slug, "level-10")
    }

    func testLoadStrands() {
        let strands = service.strands
        XCTAssertEqual(strands.count, 5, "Should load 5 strands")
        let slugs = Set(strands.map { $0.slug })
        XCTAssertTrue(slugs.contains(.number))
        XCTAssertTrue(slugs.contains(.algebra))
        XCTAssertTrue(slugs.contains(.measurement))
        XCTAssertTrue(slugs.contains(.space))
        XCTAssertTrue(slugs.contains(.statistics))
    }

    func testGetLevelBySlug() {
        let level = service.getLevel(bySlug: "level-5")
        XCTAssertNotNil(level)
        XCTAssertEqual(level?.name, "Level 5")
        XCTAssertEqual(level?.order, 5)
    }

    func testGetStrandBySlug() {
        let strand = service.getStrand(bySlug: .number)
        XCTAssertNotNil(strand)
        XCTAssertEqual(strand?.name, "Number")
    }

    func testLoadLessons() {
        let lessons = service.getLessons(levelSlug: "foundation", strandSlug: "number")
        XCTAssertFalse(lessons.isEmpty, "Should load lessons for foundation/number")
        XCTAssertEqual(lessons.first?.levelSlug, "foundation")
        XCTAssertEqual(lessons.first?.strandSlug, .number)
    }

    func testLoadPractice() {
        let practice = service.getPractice(levelSlug: "foundation", strandSlug: "number")
        XCTAssertNotNil(practice, "Should load practice for foundation/number")
        XCTAssertEqual(practice?.levelSlug, "foundation")
        XCTAssertFalse(practice?.questions.isEmpty ?? true)
    }

    func testLoadAchievements() {
        let achievements = service.getAchievementDefinitions()
        XCTAssertEqual(achievements.count, 8, "Should load 8 achievements")
    }

    func testGetStrandsForLevel() {
        let strandOverviews = service.getStrandsForLevel("foundation")
        XCTAssertEqual(strandOverviews.count, 5)
        XCTAssertTrue(strandOverviews.allSatisfy { $0.levelSlug == "foundation" })
    }

    func testAllLevelsHaveContent() {
        for level in service.levels {
            for strand in StrandSlug.allCases {
                let lessons = service.getLessons(levelSlug: level.slug, strandSlug: strand.rawValue)
                XCTAssertFalse(lessons.isEmpty, "Missing lessons for \(level.slug)/\(strand.rawValue)")

                let practice = service.getPractice(levelSlug: level.slug, strandSlug: strand.rawValue)
                XCTAssertNotNil(practice, "Missing practice for \(level.slug)/\(strand.rawValue)")
            }
        }
    }
}
