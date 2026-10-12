import SwiftData
import SwiftUI
import Testing
@testable import AdaptiveDuoLab

struct AdaptiveLayoutPolicyTests {
    @Test
    func compactAutomaticUsesList() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 390,
            pose: .automatic,
            presentation: .automatic
        )
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func innerOpenUsesAvailableWidth() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 900,
            pose: .innerOpen,
            presentation: .automatic
        )
        #expect(decision.usesGrid)
        #expect(decision.columnCount == 3)
    }

    @Test
    func narrowInnerOpenDoesNotForceDenseGrid() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 390,
            pose: .innerOpen,
            presentation: .automatic
        )
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func bookFoldUsesTwoRegions() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 760,
            pose: .bookFold,
            presentation: .grid
        )
        #expect(decision.composition == .book)
        #expect(decision.columnCount == 2)
    }

    @Test
    func narrowBookFoldKeepsOneContinuousCollection() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 390,
            pose: .bookFold,
            presentation: .automatic
        )
        #expect(decision.composition == .single)
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func bookFoldRequiresEnoughWidthForBothCards() {
        // 48 pt 外边距 + 26 pt 折叠区域 + 56 pt 区域内边距 + 2 × 280 pt 卡片宽度。
        for (width, expectedComposition) in [
            (CGFloat(689), AdaptiveComposition.single),
            (CGFloat(690), AdaptiveComposition.book)
        ] {
            let decision = AdaptiveLayoutPolicy.decision(
                width: width,
                pose: .bookFold,
                presentation: .grid
            )
            #expect(decision.composition == expectedComposition)
        }
    }

    @Test
    func explicitListOverridesWideWindow() {
        let decision = AdaptiveLayoutPolicy.decision(
            width: 1_200,
            pose: .innerOpen,
            presentation: .list
        )
        #expect(!decision.usesGrid)
        #expect(decision.columnCount == 1)
    }

    @Test
    func accessibilityTextUsesOneContinuousColumn() {
        for pose in [DemoPose.automatic, .bookFold, .tabletop] {
            for presentation in CollectionPresentation.allCases {
                let decision = AdaptiveLayoutPolicy.decision(
                    width: 1_200,
                    pose: pose,
                    presentation: presentation,
                    height: 900,
                    dynamicTypeSize: .accessibility1
                )
                #expect(decision.composition == .single)
                #expect(decision.columnCount == 1)
                // 保留所选的网格呈现样式，同时确保内容密度满足可读性要求。
                #expect(decision.usesGrid == (presentation == .grid))
            }
        }
    }

    @Test
    func tabletopRequiresEnoughLocalHeight() {
        for (height, expectedComposition) in [
            (CGFloat(519), AdaptiveComposition.single),
            (CGFloat(520), AdaptiveComposition.tabletop)
        ] {
            let decision = AdaptiveLayoutPolicy.decision(
                width: 900,
                pose: .tabletop,
                presentation: .list,
                height: height
            )
            #expect(decision.composition == expectedComposition)
            #expect(!decision.usesGrid)
        }
    }

    @Test
    func accessibilityBoundaryChangesDensityAndComposition() {
        for (textSize, expectedComposition, expectedColumns) in [
            (DynamicTypeSize.xxxLarge, AdaptiveComposition.book, 2),
            (DynamicTypeSize.accessibility1, AdaptiveComposition.single, 1)
        ] {
            let decision = AdaptiveLayoutPolicy.decision(
                width: 900,
                pose: .bookFold,
                presentation: .grid,
                height: 900,
                dynamicTypeSize: textSize
            )
            #expect(decision.composition == expectedComposition)
            #expect(decision.columnCount == expectedColumns)
        }
    }
}

/// 翻译已有示例时，验证持久化状态与用户编辑内容不会被重置。
struct DemoSampleTranslationTests {
    @Test @MainActor
    func translatesLegacySamplesWithoutResettingState() throws {
        let container = try ModelContainer(
            for: WorkItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let date = Date(timeIntervalSince1970: 1_000)
        let sample = WorkItem(
            title: "Adaptive navigation",
            summary: "Move naturally between collapsed and multi-column navigation.",
            category: .engineering, status: .inProgress,
            progress: 0.42, updatedAt: date, symbolName: "sidebar.left"
        )
        let edited = WorkItem(
            title: "Adaptive navigation", summary: "用户编辑的说明",
            category: .design, status: .planned,
            progress: 0.2, updatedAt: date, symbolName: "paintpalette"
        )
        let id = sample.id
        context.insert(sample)
        context.insert(edited)
        try context.save()

        try DemoSeeder.seedIfNeeded(in: context, reset: false)
        try DemoSeeder.seedIfNeeded(in: context, reset: false)

        #expect(try context.fetchCount(FetchDescriptor<WorkItem>()) == 2)
        #expect(sample.title == "自适应导航")
        #expect(sample.summary == "在折叠导航与多栏导航之间自然切换。")
        #expect(sample.id == id)
        #expect(sample.progress == 0.42)
        #expect(sample.updatedAt == date)
        #expect(sample.categoryRawValue == "Engineering")
        #expect(sample.statusRawValue == "In progress")
        #expect(sample.category == .engineering)
        #expect(sample.status == .inProgress)
        #expect(edited.title == "Adaptive navigation")
        #expect(edited.summary == "用户编辑的说明")
    }
}
