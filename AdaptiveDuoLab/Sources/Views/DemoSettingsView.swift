import SwiftUI

struct DemoSettingsView: View {
    @Binding var category: WorkCategory
    @Binding var presentation: CollectionPresentation
    @Binding var pose: DemoPose
    let totalItemCount: Int
    let filteredItemCount: Int
    let items: [WorkItem]

    @State private var showsAPILab = false

    var body: some View {
        Form {
            Section {
                Button {
                    showsAPILab = true
                } label: {
                    Label("打开 API 实验室", systemImage: "curlybraces")
                }
                .accessibilityIdentifier("settings.apiLab")
            } header: {
                Text("Apple API 示例")
            } footer: {
                Text("了解各个 API 的作用、可用条件，并体验实时系统布局示例。")
            }

            Section {
                Picker("分类", selection: $category) {
                    ForEach(WorkCategory.allCases) { option in
                        Label(option.title, systemImage: option.symbol)
                            .tag(option)
                    }
                }
                .accessibilityIdentifier("settings.category")
                .accessibilityValue(category.title)

                Picker("内容模式", selection: $presentation) {
                    ForEach(CollectionPresentation.allCases) { option in
                        Label(option.title, systemImage: option.symbol)
                            .tag(option)
                    }
                }
                .accessibilityIdentifier("settings.presentation")
                .accessibilityValue(presentation.title)

                Picker("预览姿态", selection: $pose) {
                    ForEach(DemoPose.allCases) { option in
                        Label(option.title, systemImage: option.symbol)
                            .tag(option)
                    }
                }
                .accessibilityIdentifier("settings.pose")
                .accessibilityValue(pose.title)
            } header: {
                Text("工作区配置")
            } footer: {
                Text("更改会应用到工作区和检查页面。预览姿态用于模拟内容布局；标签栏位置由系统决定。")
            }
            .pickerStyle(.menu)

            Section("记录") {
                recordCount("当前分类", count: filteredItemCount, id: "settings.filteredCount")
                recordCount("全部记录", count: totalItemCount, id: "settings.recordCount")
            }
        }
        .navigationTitle("设置")
        .fullScreenCover(isPresented: $showsAPILab) {
            APILabView(items: items, category: category)
        }
    }

    private func recordCount(_ title: String, count: Int, id: String) -> some View {
        LabeledContent(title, value: count.formatted())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(count.formatted())
            .accessibilityIdentifier(id)
    }
}

#if DEBUG
private struct DemoSettingsPreview: View {
    let items: [WorkItem]
    @State private var category: WorkCategory = .all
    @State private var presentation: CollectionPresentation = .automatic
    @State private var pose: DemoPose = .automatic

    private var filteredItems: [WorkItem] {
        category == .all ? items : items.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            DemoSettingsView(
                category: $category,
                presentation: $presentation,
                pose: $pose,
                totalItemCount: items.count,
                filteredItemCount: filteredItems.count,
                items: filteredItems
            )
        }
    }
}

#Preview("设置 · 可交互筛选") {
    SampleDataPreview { data in
        DemoSettingsPreview(items: data.items)
    }
}
#endif
