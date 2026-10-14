import Observation
import SwiftUI

/// 在现有演示应用中使用真实的系统工具栏进行实验。
/// 在呈现会话前确定偏好设置，使垂直工具栏的行为在会话期间的导航、
/// 滚动和窗口尺寸调整过程中保持稳定。
@MainActor
struct ToolbarAPIDemo: View {
    @State private var configuration = ToolbarDemoConfiguration()
    @State private var session = ToolbarDemoState()
    @State private var showingSession = false

    var body: some View {
        List {
            Section {
                Text("调整可用空间，比较系统标签栏、工具栏操作和溢出菜单的变化。检查、置顶和添加操作都会更新当前会话的本地记录。")
            }

			Section {
				Picker(
					"工具栏位置",
					selection: $configuration.vertical
				) {
					ForEach(ToolbarVerticalChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Picker(
					"压缩优先级",
					selection: $configuration.compression
				) {
					ForEach(ToolbarCompressionChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Picker(
					"检查控件的轴向",
					selection: $configuration.axis
				) {
					ForEach(ToolbarAxisChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Picker(
					"导航栏最小化",
					selection: $configuration.minimization
				) {
					ForEach(ToolbarMinimizationChoice.allCases) {
						Text($0.rawValue)
							.tag($0)
					}
				}

				Toggle(
					"优先显示检查操作",
					isOn: $configuration.prioritizeReview
				)
			} header: {
				Text("配置下次会话")
			} footer: {
				Text(
					"垂直工具栏是否可用由系统几何信息决定。" +
					"仅限水平工具栏的检查操作仍可从记录列表" +
					"和操作标签页访问。工具栏位置偏好在每次会话中保持不变。"
				)
			}


            availabilitySection

            Section("会话状态") {
                ToolbarSessionSummary(session: session)
                Text("关闭并重新打开预览会保留这些值。调整窗口大小不会重建记录模型。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("工具栏 API")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("apiLab.toolbarScreen")
        .fullScreenCover(isPresented: $showingSession) {
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                NativeToolbarSession(configuration: configuration, session: session)
            } else {
                BaselineToolbarSession(session: session)
            }
            #else
            BaselineToolbarSession(session: session)
            #endif
        }
    }

    @ViewBuilder
    private var availabilitySection: some View {
        Section {
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                Button("打开原生工具栏会话", systemImage: "play.rectangle") {
                    showingSession = true
                }
                .accessibilityIdentifier("apiLab.toolbar.openNative")
            } else {
                baselineLaunch("已包含原生工具栏源代码，需要 iOS 27.1 或更高版本。基础预览使用普通系统工具栏项。")
            }
            #else
            baselineLaunch("使用 iOS 27.1 SDK 并设置 DUO_SDK=1 构建，以启用上方的原生偏好设置。基础预览使用普通系统工具栏项。")
            #endif
        }
    }

    @ViewBuilder
    private func baselineLaunch(_ message: String) -> some View {
        Text(message).font(.footnote).foregroundStyle(.secondary)
        Button("打开基础工具栏预览", systemImage: "play.rectangle") {
            showingSession = true
        }
        .accessibilityIdentifier("apiLab.toolbar.openBaseline")
    }
}

private enum ToolbarVerticalChoice: String, CaseIterable, Identifiable {
    case automatic = "系统默认"
    case horizontal = "水平工具栏"
    var id: Self { self }
}

private enum ToolbarCompressionChoice: String, CaseIterable, Identifiable {
    case automatic = "自动"
    case tabs = "优先保留标签栏"
    case actions = "优先保留工具栏操作"
    var id: Self { self }
}

private enum ToolbarAxisChoice: String, CaseIterable, Identifiable {
    case automatic = "自动"
    case horizontal = "仅限水平"
    case vertical = "优先垂直"
    var id: Self { self }
}

private enum ToolbarMinimizationChoice: String, CaseIterable, Identifiable {
    case automatic = "自动"
    case never = "从不"
    case down = "向下滚动时"
    case up = "向上滚动时"
    var id: Self { self }
}

private struct ToolbarDemoConfiguration {
    var vertical: ToolbarVerticalChoice = .automatic
    var compression: ToolbarCompressionChoice = .actions
    var axis: ToolbarAxisChoice = .vertical
    var minimization: ToolbarMinimizationChoice = .down
    var prioritizeReview = true
}

@MainActor
@Observable
private final class ToolbarDemoState {
    var recordCount = 30
    var reviewCount = 0
    var isPinned = false
    var newestFirst = false
    var selectedTab = 0
    var activity: [String] = ["会话已就绪"]

    var records: [Int] {
        let values = Array(1...recordCount)
        return newestFirst ? Array(values.reversed()) : values
    }

    func review() {
        reviewCount += 1
        record("已检查当前记录 · \(reviewCount) 次")
    }

    func togglePin() {
        isPinned.toggle()
        record(isPinned ? "已置顶此集合" : "已取消置顶此集合")
    }

    func toggleSort() {
        newestFirst.toggle()
        record(newestFirst ? "最新记录优先" : "最早记录优先")
    }

    func addRecord() {
        recordCount += 1
        record("已添加示例记录 \(recordCount)")
    }

    private func record(_ message: String) {
        activity.insert(message, at: 0)
        activity = Array(activity.prefix(30))
    }
}

@MainActor
private struct ToolbarSessionSummary: View {
    let session: ToolbarDemoState

    var body: some View {
        LabeledContent("记录", value: session.recordCount.formatted())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("记录")
            .accessibilityValue(session.recordCount.formatted())
            .accessibilityIdentifier("apiLab.toolbar.recordCount")
        LabeledContent("检查次数", value: session.reviewCount.formatted())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("检查次数")
            .accessibilityValue(session.reviewCount.formatted())
            .accessibilityIdentifier("apiLab.toolbar.reviewCount")
        LabeledContent("集合", value: session.isPinned ? "已置顶" : "未置顶")
        Text(session.activity.first ?? "会话已就绪")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("apiLab.toolbar.lastAction")
    }
}

@MainActor
private struct ToolbarRecordList: View {
    let session: ToolbarDemoState

    var body: some View {
        List {
            Section("实时会话") {
                ToolbarSessionSummary(session: session)
                Button("检查记录", systemImage: "checkmark.seal") { session.review() }
                    .accessibilityIdentifier("apiLab.toolbar.reviewFallback")
            }
            Section("滚动以比较工具栏最小化效果") {
                ForEach(session.records, id: \.self) { number in
                    Label("示例记录 \(number)", systemImage: "doc.text")
                        .padding(.vertical, 4)
                }
            }
        }
    }
}

@MainActor
private struct ToolbarActionList: View {
    let session: ToolbarDemoState

    var body: some View {
        List {
            Section("所有操作均可访问") {
                Button("检查记录", systemImage: "checkmark.seal") { session.review() }
                Button(session.isPinned ? "取消置顶集合" : "置顶集合", systemImage: "pin") {
                    session.togglePin()
                }
                Button("反转记录顺序", systemImage: "arrow.up.arrow.down") { session.toggleSort() }
                Button("添加示例记录", systemImage: "plus") { session.addRecord() }
            }
            Section("会话状态") { ToolbarSessionSummary(session: session) }
        }
    }
}

@MainActor
private struct BaselineToolbarSession: View {
    let session: ToolbarDemoState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ToolbarRecordList(session: session)
                .navigationTitle("基础工具栏")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("关闭", systemImage: "xmark") { dismiss() }
                            .accessibilityIdentifier("apiLab.toolbar.close")
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("检查", systemImage: "checkmark.seal") { session.review() }
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        Menu("集合操作", systemImage: "ellipsis") {
                            Button("添加示例记录", systemImage: "plus") { session.addRecord() }
                            Button("反转记录顺序", systemImage: "arrow.up.arrow.down") { session.toggleSort() }
                        }
                    }
                }
        }
    }
}

#if DUO_SDK
@available(iOS 27.1, *)
@MainActor
private struct NativeToolbarSession: View {
    let configuration: ToolbarDemoConfiguration
    @Bindable var session: ToolbarDemoState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $session.selectedTab) {
            Tab("记录", systemImage: "doc.on.doc", value: 0) {
                NavigationStack {
                    NativeToolbarRecords(configuration: configuration, session: session, close: { dismiss() })
                }
            }
            Tab("操作历史", systemImage: "clock", value: 1) {
                NavigationStack {
                    List(Array(session.activity.enumerated()), id: \.offset) { _, message in
                        Text(message)
                    }
                    .navigationTitle("操作历史")
                    .toolbar { closeButton }
                }
            }
            Tab("操作", systemImage: "checklist", value: 2) {
                NavigationStack {
                    ToolbarActionList(session: session)
                        .navigationTitle("全部操作")
                        .toolbar { closeButton }
                }
            }
        }
        .toolbarVerticalBehavior(configuration.vertical == .horizontal ? .disabled : .automatic)
        .accessibilityIdentifier("apiLab.toolbar.nativeSession")
    }

    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("关闭", systemImage: "xmark") { dismiss() }
                .accessibilityIdentifier("apiLab.toolbar.close")
        }
    }
}

@available(iOS 27.1, *)
@MainActor
private struct NativeToolbarRecords: View {
    let configuration: ToolbarDemoConfiguration
    let session: ToolbarDemoState
    let close: () -> Void
    @Environment(\.toolbarVerticalEdge) private var preferredVerticalEdge
    @State private var showingSummary = false

    var body: some View {
        ToolbarRecordList(session: session)
            .navigationTitle("工具栏记录")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭", systemImage: "xmark", action: close)
                        .accessibilityIdentifier("apiLab.toolbar.close")
                }
                ToolbarItem(placement: .primaryAction) {
                    NativeReviewControl(reviewCount: session.reviewCount, action: session.review)
                }
                .visibilityPriority(configuration.prioritizeReview ? .high : .automatic)
                .axisBehavior(axisBehavior)

                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button(session.isPinned ? "取消置顶" : "置顶", systemImage: session.isPinned ? "pin.fill" : "pin") {
                        session.togglePin()
                    }
                    .accessibilityIdentifier("apiLab.toolbar.pin")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("反转顺序", systemImage: "arrow.up.arrow.down") { session.toggleSort() }
                }
                .visibilityPriority(.low)

                ToolbarOverflowMenu {
                    Button("添加示例记录", systemImage: "plus") { session.addRecord() }
                        .accessibilityIdentifier("apiLab.toolbar.overflowAdd")
                    Button("会话摘要", systemImage: "chart.bar") { showingSummary = true }
                    Button("检查记录", systemImage: "checkmark.seal") { session.review() }
                }
            }
            .toolbarVerticalCompressionBehavior(compressionBehavior)
            .toolbarMinimizationBehavior(minimizationBehavior, for: .navigationBar)
            .sheet(isPresented: $showingSummary) {
                NavigationStack {
                    List {
                        Section("实时数据") { ToolbarSessionSummary(session: session) }
                        Section("垂直工具栏偏好") {
                            Text(edgeDescription)
                            Text("此边缘信息表示系统偏好，并不代表工具栏当前可见。示例不会绘制自定义侧边工具栏。")
                        }
                    }
                    .navigationTitle("会话摘要")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") { showingSummary = false }
                        }
                    }
                }
            }
    }

    private var axisBehavior: ToolbarItemAxisBehavior {
        switch configuration.axis {
        case .automatic: .automatic
        case .horizontal: .horizontalOnly
        case .vertical: .verticalPreferred
        }
    }

    private var compressionBehavior: ToolbarVerticalCompressionBehavior {
        switch configuration.compression {
        case .automatic: .automatic
        case .tabs: .prefersTabBar
        case .actions: .prefersToolbarItems
        }
    }

    private var minimizationBehavior: ToolbarMinimizationBehavior {
        switch configuration.minimization {
        case .automatic: .automatic
        case .never: .never
        case .down: .onScrollDown
        case .up: .onScrollUp
        }
    }

    private var edgeDescription: String {
        guard let preferredVerticalEdge else { return "当前环境中无此偏好" }
        return preferredVerticalEdge == .leading ? "优先起始侧边缘" : "优先末尾侧边缘"
    }
}

@available(iOS 27.1, *)
@MainActor
private struct NativeReviewControl: View {
    let reviewCount: Int
    let action: () -> Void
    @Environment(\.toolbarVerticalEdge) private var preferredVerticalEdge

    var body: some View {
        Button(action: action) {
            if preferredVerticalEdge == nil {
                Label("检查", systemImage: "checkmark.seal")
            } else {
                Label("检查", systemImage: "checkmark.seal")
                    .labelStyle(.iconOnly)
            }
        }
        .accessibilityLabel("检查记录")
        .accessibilityValue("已检查 \(reviewCount) 次")
        .accessibilityIdentifier("apiLab.toolbar.review")
    }
}
#endif

#if DEBUG
#Preview("SwiftUI 工具栏") {
    NavigationStack {
        ToolbarAPIDemo()
    }
}
#endif
