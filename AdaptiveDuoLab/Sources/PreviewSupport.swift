#if DEBUG
import SwiftData
import SwiftUI

/// 每个预览宿主拥有独立的内存数据库；不与应用或其他 Canvas 共享记录。
@MainActor
final class PreviewSampleData: ObservableObject {
    let container: ModelContainer
    let items: [WorkItem]
    let longTextItem: WorkItem

    init() {
        do {
            container = try ModelContainer(
                for: WorkItem.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            let context = container.mainContext
            try DemoSeeder.seedIfNeeded(in: context, reset: false)
            items = try context.fetch(
                FetchDescriptor<WorkItem>(sortBy: [SortDescriptor(\WorkItem.updatedAt, order: .reverse)])
            )
        } catch {
            fatalError("无法创建预览示例数据：\(error)")
        }
        longTextItem = WorkItem(
            title: "检查辅助功能大字体下的自适应布局与完整内容展示",
            summary: "调整文字大小和窗口宽度，确认标题、摘要、分类和更新时间可以完整换行，记录卡片中的进度与状态仍然清晰可读。",
            category: .design,
            status: .inProgress,
            progress: 0.72,
            updatedAt: Date().addingTimeInterval(-900),
            symbolName: "textformat.size"
        )
    }
}

/// StateObject 将数据的生命周期绑定到预览身份，交互刷新时不重复填充示例。
@MainActor
struct SampleDataPreview<Content: View>: View {
    @StateObject private var data = PreviewSampleData()
    private let content: (PreviewSampleData) -> Content

    init(@ViewBuilder content: @escaping (PreviewSampleData) -> Content) {
        self.content = content
    }

    var body: some View {
        content(data)
            .modelContainer(data.container)
            .tint(.indigo)
    }
}
#endif
