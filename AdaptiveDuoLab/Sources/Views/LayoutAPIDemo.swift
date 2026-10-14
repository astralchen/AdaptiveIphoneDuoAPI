import SwiftUI

/// 使用当前视图的几何信息；窗口尺寸变化时仅调整布局，保持视图模型不变。
struct LayoutAPIDemo: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var preferStack = false
    @State private var title = "完成自适应布局"
    @State private var completed = 2

    var body: some View {
        GeometryReader { geometry in
            let useStack = preferStack || geometry.size.width < 640 || dynamicTypeSize.isAccessibilitySize
            let layout = useStack
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 16))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 16))

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("重新布局并保留状态").font(.title2.bold())
                        Text("编辑任务后，调整窗口大小或切换布局。字段及其值会保持不变。")
                            .foregroundStyle(.secondary)
                        Toggle("优先使用垂直布局", isOn: $preferStack)
                            .accessibilityIdentifier("apiLab.layout.preferStack")
                        Text(useStack ? "垂直布局" : "水平布局")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("apiLab.layout.mode")
                    }

                    // 将两个子视图保留在同一个 AnyLayout 中。
                    // 若改为独立的 if/else 子树，会改变子视图的身份。
                    layout {
                        editor
                        summary
                    }
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: useStack)

                    Divider()
                    if #available(iOS 26.0, *) {
                        ConcentricCornerDemo()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("同心圆角").font(.title2.bold())
                            Text("在 iOS 26 或更高版本上可比较 ConcentricRectangle 与固定半径圆角。上方的重新布局示例支持 iOS 17 及更高版本。")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 1000, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("重新布局与圆角")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("apiLab.layout.screen")
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("任务编辑器").font(.headline)
            TextField("任务标题", text: $title, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("apiLab.layout.title")
            Stepper("已完成：\(completed)/5", value: $completed, in: 0...5)
                .accessibilityIdentifier("apiLab.layout.completed")
            ProgressView(value: Double(completed), total: 5)
                .accessibilityLabel("任务进度")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("实时摘要").font(.headline)
            Text(title.isEmpty ? "未命名任务" : title)
                .font(.title3)
                .fixedSize(horizontal: false, vertical: true)
            Text("还剩 \(5 - completed) 步")
                .foregroundStyle(.secondary)
            Label("布局变化时保留状态", systemImage: "checkmark.circle")
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
    }
}

@available(iOS 26.0, *)
private struct ConcentricCornerDemo: View {
    @State private var inset = 12.0
    @State private var useConcentric = true

    private let outerShape = RoundedRectangle(cornerRadius: 40)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("随容器调整的圆角").font(.title2.bold())
            Toggle("使用同心圆角", isOn: $useConcentric)
                .accessibilityIdentifier("apiLab.corners.concentric")
            VStack(alignment: .leading, spacing: 8) {
                Text("内边距：\(inset.formatted(.number.precision(.fractionLength(0)))) pt")
                Slider(value: $inset, in: 8...32, step: 1)
                    .accessibilityLabel("卡片内边距")
                    .accessibilityIdentifier("apiLab.corners.inset")
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("自适应卡片", systemImage: "rectangle.inset.filled")
                    .font(.headline)
                Text("调整内边距，比较内外圆角曲线。")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if useConcentric {
                    ConcentricRectangle().fill(.background)
                } else {
                    RoundedRectangle(cornerRadius: 24).fill(.background)
                }
            }
            .padding(CGFloat(inset))
            .containerShape(outerShape)
            .background(outerShape.fill(.indigo.opacity(0.22)))
            .accessibilityIdentifier("apiLab.corners.preview")

            Text(useConcentric
                 ? "ConcentricRectangle 根据容器形状和内边距计算各个内侧圆角。"
                 : "无论距离外边缘多远，内侧圆角半径都保持为 24 pt。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("重新布局与圆角") {
    NavigationStack {
        LayoutAPIDemo()
    }
}
#endif
