import SwiftUI

struct PresentationAPIDemo: View {
    @State private var showsSheet = false
    @State private var showsPopover = false
    @State private var showsAlert = false
    @State private var draft = "检查自适应布局"
    @State private var lastAction = "尚未执行操作"

    var body: some View {
        Form {
            Section("呈现方式") {
                Button("在 Sheet 中编辑") { showsSheet = true }
                    .accessibilityIdentifier("presentations.sheet")
                Button("显示 Popover") { showsPopover = true }
                    .popover(isPresented: $showsPopover) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("此操作的上下文").font(.headline)
                            Text("系统会根据可用空间调整呈现方式。")
                            Button("关闭") { showsPopover = false }
                        }
                        .padding()
                    }
                Button("显示提醒") { showsAlert = true }
                Menu("操作", systemImage: "ellipsis.circle") {
                    Button("标记为已检查", systemImage: "checkmark") { lastAction = "已检查" }
                    Button("置顶笔记", systemImage: "pin") { lastAction = "已置顶" }
                }
            }
            Section("共享状态") {
                Text(draft).accessibilityIdentifier("presentations.draftSummary")
                LabeledContent("上次操作", value: lastAction)
            }
            Section("试一试") {
                Text("保持 Sheet 打开，尝试调整窗口大小、旋转设备或更改受支持的设备配置。草稿会保留在父视图中。")
            }
        }
        .navigationTitle("呈现方式")
        .sheet(isPresented: $showsSheet) {
            NavigationStack {
                Form {
                    TextField("笔记", text: $draft, axis: .vertical)
                        .accessibilityIdentifier("presentations.draft")
                }
                .navigationTitle("编辑笔记")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { showsSheet = false }
                            .accessibilityIdentifier("presentations.done")
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert("将此笔记标记为已检查？", isPresented: $showsAlert) {
            Button("取消", role: .cancel) {}
            Button("标记为已检查") { lastAction = "已检查" }
        } message: {
            Text("此操作仅更改当前示例的本地状态。")
        }
    }
}
