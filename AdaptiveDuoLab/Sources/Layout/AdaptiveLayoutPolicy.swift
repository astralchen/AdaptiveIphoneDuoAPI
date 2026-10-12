import SwiftUI

enum AdaptiveLayoutPolicy {
    static func decision(
        width: CGFloat,
        pose: DemoPose,
        presentation: CollectionPresentation,
        height: CGFloat = .infinity,
        dynamicTypeSize: DynamicTypeSize = .large
    ) -> LayoutDecision {
        let contentPadding: CGFloat = width < 500 ? 16 : 24
        let needsReadableColumn = dynamicTypeSize.isAccessibilitySize
        // 模拟书本布局的分隔区域宽 26 pt，每个区域的左右内边距各为 14 pt。
        // 据此计算卡片实际可用的宽度。
        // 这是示例内容的适配规则，并非设备或显示屏的布局断点。
        let bookCardWidth = (width - contentPadding * 2 - 26) / 2 - 28
        let hasRoomForBook = bookCardWidth >= 280 && !needsReadableColumn
        // 此处按演示内容所需空间判断，不检测硬件或屏幕方向。
        // 当桌面姿态的占位区域挤占记录的可读空间时，保留所选姿态，
        // 同时将集合呈现为连续布局。
        let hasRoomForTabletop = height >= 520 && !needsReadableColumn
        let composition: AdaptiveComposition = switch pose {
        case .bookFold: hasRoomForBook ? .book : .single
        case .tabletop: hasRoomForTabletop ? .tabletop : .single
        default: .single
        }

        let automaticGrid = width >= 620 && !needsReadableColumn
        let usesGrid = switch presentation {
        case .automatic: automaticGrid
        case .list: false
        case .grid: true
        }

        let columns: Int
        if !usesGrid || needsReadableColumn {
            columns = 1
        } else if width >= 1_100 {
            columns = 4
        } else if width >= 820 {
            columns = 3
        } else if width >= 560 {
            columns = 2
        } else {
            columns = 1
        }

        return LayoutDecision(
            usesGrid: usesGrid,
            columnCount: composition == .book ? 2 : columns,
            composition: composition,
            contentPadding: contentPadding
        )
    }
}
