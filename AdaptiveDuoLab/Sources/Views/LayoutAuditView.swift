import SwiftUI

struct LayoutAuditView: View {
    let itemCount: Int
    let pose: DemoPose
    let presentation: CollectionPresentation
    var category: WorkCategory = .all

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            LayoutAuditContent(
                itemCount: itemCount,
                pose: pose,
                presentation: presentation,
                category: category
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("audit.done")
                }
            }
        }
        .accessibilityIdentifier("audit.sheet")
    }
}

/// 同一份配置指导可通过标签页或模态 sheet 呈现。
struct LayoutAuditContent: View {
    let itemCount: Int
    let pose: DemoPose
    let presentation: CollectionPresentation
    let category: WorkCategory

    private var recommendations: [String] {
        var values = [
            "使用局部几何信息和 Size Class，避免根据设备类型或方向判断布局。",
            "将可交互的前景控件保持在安全区域内。",
            "允许装饰性背景延伸到系统栏后方。"
        ]

        if pose == .bookFold {
            values.append("将每张卡片完整放在一个区域内，并避开折叠处。")
        } else if pose == .tabletop {
            values.append("将便于浏览的内容放在折叠处上方，常用控件放在下方。")
        } else if presentation == .list {
            values.append("保持列表连续，避免单独移动某些行。")
        } else {
            values.append("确认当前宽度下的每个网格项都清晰可读且可交互。")
        }

        return values
    }

    var body: some View {
        List {
            Section("当前配置") {
                configurationRow("分类", value: category.title, id: "review.category")
                configurationRow("姿态", value: pose.title, id: "review.pose")
                configurationRow("内容模式", value: presentation.title, id: "review.presentation")
                configurationRow("记录", value: itemCount.formatted(), id: "review.recordCount")
            }

            Section("布局检查项") {
                ForEach(recommendations, id: \.self) {
                    Label($0, systemImage: "checkmark.seal")
                }
            }

            Section {
                Text("这些检查项基于所选配置。使用 API 实验室查看实际系统几何信息，再调整窗口大小以验证布局。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("布局检查")
    }

    private func configurationRow(_ title: String, value: String, id: String) -> some View {
        LabeledContent(title, value: value)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(value)
            .accessibilityIdentifier(id)
    }
}

#if DEBUG
#Preview("布局检查 · Sheet") {
    LayoutAuditView(itemCount: 8, pose: .bookFold, presentation: .grid)
}

#Preview("布局检查 · 导航页面") {
    NavigationStack {
        LayoutAuditContent(itemCount: 8, pose: .automatic, presentation: .automatic, category: .all)
    }
}
#endif
