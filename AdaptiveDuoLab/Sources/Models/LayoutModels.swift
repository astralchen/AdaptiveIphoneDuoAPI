import SwiftUI

enum CollectionPresentation: String, CaseIterable, Identifiable {
    /// 界面显示名称；rawValue 保持稳定以兼容存储和启动参数。
    var title: String {
        switch self {
        case .automatic: "自动"
        case .list: "列表"
        case .grid: "网格"
        }
    }

    case automatic = "Automatic"
    case list = "List"
    case grid = "Grid"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .automatic: "wand.and.stars"
        case .list: "list.bullet"
        case .grid: "square.grid.2x2"
        }
    }
}

enum DemoPose: String, CaseIterable, Identifiable {
    /// 界面显示名称；rawValue 保持稳定以兼容存储和启动参数。
    var title: String {
        switch self {
        case .automatic: "当前窗口"
        case .outerPortrait: "外屏竖向"
        case .outerLandscape: "外屏横向"
        case .innerOpen: "内屏展开"
        case .bookFold: "书本折叠"
        case .tabletop: "桌面模式"
        }
    }

    case automatic = "Current Window"
    case outerPortrait = "Outer Portrait"
    case outerLandscape = "Outer Landscape"
    case innerOpen = "Inner Open"
    case bookFold = "Book Fold"
    case tabletop = "Tabletop"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .automatic: "iphone"
        case .outerPortrait: "rectangle.portrait"
        case .outerLandscape: "rectangle"
        case .innerOpen: "rectangle.split.2x1"
        case .bookFold: "book.closed"
        case .tabletop: "rectangle.split.1x2"
        }
    }

    var explanation: String {
        switch self {
        case .automatic: "根据可用内容尺寸和文字大小调整布局。"
        case .outerPortrait: "竖向预览标签。调整窗口大小以测试狭窄区域中的内容。"
        case .outerLandscape: "横向预览标签。内容密度由实际内容宽度决定。"
        case .innerOpen: "展开屏幕预览标签。侧边栏是否显示由原生导航控制。"
        case .bookFold: "空间足以容纳卡片时模拟折叠区域，空间受限时使用单一集合。"
        case .tabletop: "空间允许时在记录上方模拟内容区域，否则回退为单一集合。"
        }
    }
}

enum AdaptiveComposition: Equatable {
    case single
    case book
    case tabletop
}

struct LayoutDecision: Equatable {
    let usesGrid: Bool
    let columnCount: Int
    let composition: AdaptiveComposition
    let contentPadding: CGFloat
}
