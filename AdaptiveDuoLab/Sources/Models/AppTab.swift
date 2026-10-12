import Foundation

/// 新旧原生标签页容器共用的稳定导航目标。
enum AppTab: String, CaseIterable, Identifiable {
    /// 界面显示名称；rawValue 保持稳定以兼容存储和启动参数。
    var title: String {
        switch self {
        case .workspace: "工作区"
        case .review: "检查"
        case .settings: "设置"
        }
    }

    case workspace = "Workspace"
    case review = "Review"
    case settings = "Settings"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .workspace: "square.grid.2x2"
        case .review: "checkmark.seal"
        case .settings: "gearshape"
        }
    }

    var accessibilityIdentifier: String {
        "tabs.\(rawValue.lowercased())"
    }
}
