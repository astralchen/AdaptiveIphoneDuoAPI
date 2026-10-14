#if DEBUG
import SwiftData
import SwiftUI
import XCTest
@testable import AdaptiveDuoLab

/// 挂载真实 SwiftUI 宿主，验证 StateObject 的生命周期与 SwiftData 隔离。
@MainActor
final class PreviewRuntimeTests: XCTestCase {
    private final class Probe {
        weak var data: PreviewSampleData?
        weak var container: ModelContainer?
    }

    func testMountedPreviewReleasesAndRecreatesItsStore() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        let probe = Probe()
        func content(_ revision: Int) -> SampleDataPreview<some View> {
            SampleDataPreview { data in
                Text("预览代次 \(revision)：\(data.items.first?.title ?? "")")
                    .onAppear {
                        probe.data = data
                        probe.container = data.container
                    }
            }
        }
        var host: UIHostingController? = UIHostingController(rootView: content(0))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }
        try await waitUntil { probe.data != nil }
        let firstIDs = try XCTUnwrap(probe.data).items.map(\.id)
        XCTAssertEqual(firstIDs.count, 8)
        XCTAssertTrue(try XCTUnwrap(probe.container).configurations.allSatisfy(\.isStoredInMemoryOnly))
        try autoreleasepool {
            let data = try XCTUnwrap(probe.data)
            data.items[0].title = "预览运行时修改"
            data.items[0].progress = 0.123
            try data.container.mainContext.save()
            let fetched = try data.container.mainContext.fetch(FetchDescriptor<WorkItem>())
            XCTAssertTrue(fetched.contains { $0.title == "预览运行时修改" && $0.progress == 0.123 })
            let independent = PreviewSampleData()
            XCTAssertFalse(independent.items.contains { $0.title == "预览运行时修改" })
            XCTAssertTrue(Set(firstIDs).isDisjoint(with: independent.items.map(\.id)))
        }
        host?.rootView = content(1)
        host?.view.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(probe.data?.items.map(\.id), firstIDs)
        XCTAssertEqual(probe.data?.items.first?.title, "预览运行时修改")

        window.isHidden = true
        window.rootViewController = nil
        host = nil
        try await waitUntil { probe.data == nil && probe.container == nil }
        XCTAssertNil(probe.data, "旧 StateObject 必须实际释放")
        XCTAssertNil(probe.container, "旧内存容器必须实际释放")

        host = UIHostingController(rootView: content(2))
        window.rootViewController = host
        window.makeKeyAndVisible()
        try await waitUntil { probe.data != nil }
        XCTAssertEqual(probe.data?.items.count, 8)
        XCTAssertEqual(probe.data?.items.first?.title, "自适应导航")
        XCTAssertEqual(probe.data?.items.first?.progress, 1)
        XCTAssertTrue(Set(firstIDs).isDisjoint(with: try XCTUnwrap(probe.data).items.map(\.id)))
        print("PREVIEW_RUNTIME: saved mutation; independent store isolated; StateObject and container released; 8 fresh seeded records restored")
    }

    func testFixedSizePreviewScrollRanges() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let scenarios: [(String, CGSize, DemoPose, CollectionPresentation, DynamicTypeSize, Int)] = [
            ("窄屏列表", CGSize(width: 390, height: 844), .automatic, .list, .large, 1),
            ("大字体列表", CGSize(width: 390, height: 844), .automatic, .list, .accessibility3, 1),
            ("宽屏网格", CGSize(width: 1000, height: 800), .automatic, .grid, .large, 1),
            ("书本双区域", CGSize(width: 1000, height: 800), .bookFold, .list, .large, 2),
            ("桌面模式", CGSize(width: 1000, height: 800), .tabletop, .grid, .large, 1)
        ]
        for (name, size, pose, presentation, fontSize, expectedCount) in scenarios {
            let window = UIWindow(windowScene: scene)
            let host = UIHostingController(rootView:
                SampleDataPreview { data in
                    NavigationStack {
                        DashboardView(items: data.items, selectedCategory: .all,
                                      presentation: .constant(presentation), pose: .constant(pose),
                                      showsAudit: .constant(false))
                    }
                }
                .environment(\.dynamicTypeSize, fontSize)
                .frame(width: size.width, height: size.height)
            )
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true; window.rootViewController = nil }
            func scrollViews(_ view: UIView) -> [UIScrollView] {
                (view as? UIScrollView).map { [$0] } ?? view.subviews.flatMap(scrollViews)
            }
            try await waitUntil {
                host.view.layoutIfNeeded()
                return scrollViews(host.view).filter { $0.contentSize.height > $0.bounds.height + 20 }.count == expectedCount
            }
            let views = scrollViews(host.view).filter { $0.contentSize.height > $0.bounds.height + 20 }
            XCTAssertEqual(views.count, expectedCount, name)
            for (index, scroll) in views.enumerated() {
                XCTAssertTrue(scroll.isScrollEnabled, name)
                XCTAssertTrue(scroll.panGestureRecognizer.isEnabled, name)
                let top = -scroll.adjustedContentInset.top
                var bottom = scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom
                XCTAssertGreaterThan(bottom, top + 20, name)
                // LazyVStack 在新记录布局后会更新估算高度，必须等真实末端稳定。
                for _ in 0..<20 {
                    bottom = scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom
                    scroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
                    try await Task.sleep(for: .milliseconds(50))
                    host.view.layoutIfNeeded()
                    let resolvedBottom = scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom
                    if abs(resolvedBottom - bottom) < 1 { break }
                }
                let resolvedBottom = scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom
                XCTAssertEqual(scroll.contentOffset.y, resolvedBottom, accuracy: 1, name)
                XCTAssertEqual(scroll.bounds.origin.y, resolvedBottom, accuracy: 1, name)
                let attachment = XCTAttachment(image: host.view.asImageForPreviewTest())
                attachment.name = "\(name)-区域\(index)-末尾"
                attachment.lifetime = .keepAlways
                add(attachment)
                scroll.setContentOffset(CGPoint(x: 0, y: top), animated: false)
                XCTAssertEqual(scroll.contentOffset.y, top, accuracy: 1, name)
                print("SCROLL_RANGE: \(name) region=\(index) bounds=\(scroll.bounds.size) content=\(scroll.contentSize) range=\(top)...\(resolvedBottom) bottom and top reached")
            }
        }
    }

    /// 仅在专用空白 Simulator 上生成跨进程验证夹具；普通测试运行跳过。
    /// 配合 UI 测试 testNormalLaunchesPreservePersistentRecord，按 README 顺序执行。
    func testPrepareDedicatedPersistentFixture() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]?.hasPrefix("AdaptiveDuoLab-Validation-") == true)
        XCTAssertFalse(ProcessInfo.processInfo.arguments.contains("-ui-testing"))
        XCTAssertNotEqual(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"], "1")
        let app = AdaptiveDuoLabApp()
        // 仅测试读取入口已创建的 private 容器，避免为验证增加业务公开 API。
        let container = try XCTUnwrap(Mirror(reflecting: app).children.first { $0.label == "container" }?.value as? ModelContainer)
        XCTAssertTrue(container.configurations.allSatisfy { !$0.isStoredInMemoryOnly })
        let items = try container.mainContext.fetch(FetchDescriptor<WorkItem>(sortBy: [SortDescriptor(\WorkItem.updatedAt, order: .reverse)]))
        XCTAssertEqual(items.count, 8)
        let item = try XCTUnwrap(items.first)
        item.title = "持久化对照标记"
        item.progress = 0.314
        try container.mainContext.save()
        print("PERSISTENCE_FIXTURE: id=\(item.id) title=\(item.title) progress=\(item.progress) url=\(container.configurations.first!.url.path)")
    }

    func testPreviewAppEntryUsesFreshMemoryWithoutChangingDisk() async throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]?.hasPrefix("AdaptiveDuoLab-Validation-") == true)
        let original = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        defer {
            if let original { setenv("XCODE_RUNNING_FOR_PREVIEWS", original, 1) }
            else { unsetenv("XCODE_RUNNING_FOR_PREVIEWS") }
        }
        func appContainer() throws -> ModelContainer {
            let app = AdaptiveDuoLabApp()
            return try XCTUnwrap(Mirror(reflecting: app).children.first { $0.label == "container" }?.value as? ModelContainer)
        }
        func records(_ container: ModelContainer) throws -> [WorkItem] {
            try ModelContext(container).fetch(FetchDescriptor<WorkItem>(sortBy: [SortDescriptor(\WorkItem.updatedAt, order: .reverse)]))
        }
        unsetenv("XCODE_RUNNING_FOR_PREVIEWS")
        let disk = try appContainer()
        let originalRecord = try XCTUnwrap(records(disk).first)
        let diskID = originalRecord.id
        let diskTitle = originalRecord.title
        let diskProgress = originalRecord.progress
        XCTAssertEqual(diskTitle, "持久化对照标记", "先运行持久化夹具测试")
        XCTAssertEqual(diskProgress, 0.314)
        setenv("XCODE_RUNNING_FOR_PREVIEWS", "1", 1)
        weak var released: ModelContainer?
        var memoryIDs: [UUID] = []
        try autoreleasepool {
            let memory = try appContainer()
            released = memory
            XCTAssertTrue(memory.configurations.allSatisfy(\.isStoredInMemoryOnly))
            let items = try records(memory)
            memoryIDs = items.map(\.id)
            XCTAssertEqual(items.count, 8)
            XCTAssertEqual(items.first?.title, "自适应导航")
            XCTAssertFalse(memoryIDs.contains(diskID))
            let context = memory.mainContext
            let first = try XCTUnwrap(context.fetch(FetchDescriptor<WorkItem>()).first)
            first.title = "入口内存修改"
            try context.save()
            XCTAssertTrue(try records(memory).contains { $0.title == "入口内存修改" })
        }
        try await waitUntil { released == nil }
        XCTAssertNil(released)
        let recreated = try appContainer()
        XCTAssertTrue(recreated.configurations.allSatisfy(\.isStoredInMemoryOnly))
        let restored = try records(recreated)
        XCTAssertEqual(restored.count, 8)
        XCTAssertEqual(restored.first?.title, "自适应导航")
        XCTAssertFalse(restored.contains { $0.title == "入口内存修改" })
        XCTAssertTrue(Set(memoryIDs).isDisjoint(with: restored.map(\.id)))
        unsetenv("XCODE_RUNNING_FOR_PREVIEWS")
        let reopened = try appContainer()
        XCTAssertTrue(reopened.configurations.allSatisfy { !$0.isStoredInMemoryOnly })
        let after = try XCTUnwrap(records(reopened).first)
        XCTAssertEqual(after.id, diskID)
        XCTAssertEqual(after.title, diskTitle)
        XCTAssertEqual(after.progress, diskProgress)
        print("APP_ENTRY_COMPARISON: real App.init normal disk -> Preview memory mutation/release/recreate -> normal disk; edited disk UUID/title/progress unchanged")
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        for _ in 0..<50 {
            if condition() { return }
            try await Task.sleep(for: .milliseconds(100))
        }
        XCTFail("宿主生命周期未在 5 秒内达到预期状态")
    }
}
private extension UIView {
    func asImageForPreviewTest() -> UIImage {
        UIGraphicsImageRenderer(bounds: bounds).image { context in
            layer.render(in: context.cgContext)
        }
    }
}
#endif
