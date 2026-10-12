import Foundation
import SwiftData

enum DemoSeeder {
    static func seedIfNeeded(in context: ModelContext, reset: Bool) throws {
        if reset {
            try context.delete(model: WorkItem.self)
        }

        let count = try context.fetchCount(FetchDescriptor<WorkItem>())
        guard count == 0 else {
            try translateExistingSamples(in: context)
            return
        }

        let now = Date()
        let records: [(String, String, WorkCategory, WorkStatus, Double, String)] = [
            ("自适应导航", "在折叠导航与多栏导航之间自然切换。", .engineering, .complete, 1.0, "sidebar.left"),
            ("安全区域检查", "让前景控件避开摄像头、系统栏和不对称边距。", .design, .inProgress, 0.72, "rectangle.inset.filled"),
            ("均衡网格列", "折叠处分隔可用内容区域时，优先采用均衡列布局。", .design, .inProgress, 0.56, "square.grid.2x2"),
            ("Appium 设备流程", "记录客户端、服务器、XCUITest Driver、WDA 和 XCTest 的调用链路。", .research, .complete, 1.0, "point.3.connected.trianglepath.dotted"),
            ("桌面模式控件", "让内容显示在折叠处上方，触摸控件位于下方区域。", .engineering, .planned, 0.2, "rectangle.split.1x2"),
            ("布局检查", "查看针对所选姿态和内容模式的本地指导。", .research, .inProgress, 0.65, "checkmark.seal"),
            ("垂直工具栏检查", "使用符号和系统位置，使控件适应垂直边缘。", .design, .planned, 0.35, "rectangle.trailinghalf.inset.filled"),
            ("感知场景的几何信息", "根据局部几何信息做出决策，避免依赖对主屏幕的假设。", .engineering, .complete, 1.0, "macwindow.on.rectangle")
        ]

        for (index, record) in records.enumerated() {
            context.insert(
                WorkItem(
                    title: record.0,
                    summary: record.1,
                    category: record.2,
                    status: record.3,
                    progress: record.4,
                    updatedAt: now.addingTimeInterval(TimeInterval(-index * 900)),
                    symbolName: record.5
                )
            )
        }
        try context.save()
    }

    /// 兼容已安装版本的内置示例数据；用户改过的标题或摘要保持不变。
    private static func translateExistingSamples(in context: ModelContext) throws {
        let translations: [(oldTitle: String, oldSummary: String, title: String, summary: String)] = [
            ("Adaptive navigation", "Move naturally between collapsed and multi-column navigation.", "自适应导航", "在折叠导航与多栏导航之间自然切换。"),
            ("Safe-area review", "Keep foreground controls clear of cameras, bars, and asymmetric insets.", "安全区域检查", "让前景控件避开摄像头、系统栏和不对称边距。"),
            ("Even grid columns", "Prefer balanced columns when a fold divides the available content region.", "均衡网格列", "折叠处分隔可用内容区域时，优先采用均衡列布局。"),
            ("Appium device flow", "Document the client, server, XCUITest Driver, WDA, and XCTest chain.", "Appium 设备流程", "记录客户端、服务器、XCUITest Driver、WDA 和 XCTest 的调用链路。"),
            ("Tabletop controls", "Keep content visible above the fold and touch controls in the lower region.", "桌面模式控件", "让内容显示在折叠处上方，触摸控件位于下方区域。"),
            ("Layout review", "Review local guidance for the selected pose and content mode.", "布局检查", "查看针对所选姿态和内容模式的本地指导。"),
            ("Vertical toolbar audit", "Use symbols and system placements so controls adapt to a vertical edge.", "垂直工具栏检查", "使用符号和系统位置，使控件适应垂直边缘。"),
            ("Scene-aware geometry", "Make decisions from local geometry instead of main-screen assumptions.", "感知场景的几何信息", "根据局部几何信息做出决策，避免依赖对主屏幕的假设。"),
        ]
        let items = try context.fetch(FetchDescriptor<WorkItem>())
        var changed = false
        for item in items {
            guard let translation = translations.first(where: {
                item.title == $0.oldTitle && item.summary == $0.oldSummary
            }) else { continue }
            item.title = translation.title
            item.summary = translation.summary
            changed = true
        }
        if changed { try context.save() }
    }
}
