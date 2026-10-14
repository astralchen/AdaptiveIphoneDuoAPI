import SwiftUI

/// 通过条件编译兼容不包含 27.1 符号的 SDK。
/// 另行通过运行时检查兼容运行较早系统版本的设备。
struct SystemArrangementDemo: View {
    let items: [WorkItem]
    let category: WorkCategory

    var body: some View {
        content
            .navigationTitle("系统布局")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("apiLab.systemScreen")
    }

    @ViewBuilder
    private var content: some View {
        #if DUO_SDK
        if #available(iOS 27.1, *) {
            NativeArrangementContent(items: items, category: category)
        } else {
            fallback("此构建版本已包含原生示例，请在 iOS 27.1 或更高版本上运行。")
        }
        #else
        fallback("已包含原生 API 源代码，但当前构建未启用。使用 iOS 27.1 SDK 并设置 DUO_SDK=1 构建即可启用。")
        #endif
    }

    private func fallback(_ message: String) -> some View {
        List {
            Section("原生示例可用条件") {
                Text(message).accessibilityIdentifier("apiLab.nativeStatus")
                Text("当前构建保留普通的连续列表，不会人为添加铰链间隙。")
            }
            Section {
                APILabSummary(items: items, category: category)
            }
            Section("筛选后的全部记录") {
                ForEach(items) { item in
                    WorkItemCard(item: item, compact: false)
                }
            }
        }
    }
}

private struct APILabSummary: View {
    let items: [WorkItem]
    let category: WorkCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("摘要").font(.title2.bold())
            LabeledContent("分类", value: category.title)
            LabeledContent("记录", value: items.count.formatted())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("记录")
                .accessibilityValue(items.count.formatted())
                .accessibilityIdentifier("apiLab.recordCount")
            LabeledContent("已完成", value: items.filter { $0.status == .complete }.count.formatted())
            LabeledContent("进行中", value: items.filter { $0.status == .inProgress }.count.formatted())
            Text("主区域包含筛选后的全部记录。未显示次级区域时，仍可通过工具栏访问此摘要。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DUO_SDK
@available(iOS 27.1, *)
private struct NativeArrangementContent: View {
    let items: [WorkItem]
    let category: WorkCategory
    @State private var hinge: DeviceHinge?
    @State private var receivedHingeEvent = false

    var body: some View {
        GeometryReader { proxy in
            let divisions = proxy.reservedRegions(kind: .division, options: .includeInactive)
            let occlusions = proxy.reservedRegions(kind: .occlusion, options: .includeInactive)

            ArrangementView {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        Text("全部 \(items.count) 条记录")
                            .font(.headline)
                            .accessibilityLabel("记录")
                            .accessibilityValue(items.count.formatted())
                            .accessibilityIdentifier("apiLab.recordCount")
                        ForEach(items) { item in
                            WorkItemCard(item: item, compact: false)
                        }
                    }
                    .padding()
                }
                .accessibilityIdentifier("apiLab.nativeRecords")
            } secondary: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        APILabSummary(items: items, category: category)
                        SplitArrangementReadout()
                        Divider()
                        Text("系统几何信息").font(.headline)
                        LabeledContent("生效的分隔区域", value: divisions.filter(\.isActive).count.formatted())
                        LabeledContent("生效的遮挡区域", value: occlusions.filter(\.isActive).count.formatted())
                        Text(hingeDescription).font(.footnote).foregroundStyle(.secondary)
                        Text("ArrangementView 决定这两个区域的关系。此页面不由角度阈值或模拟姿态值驱动。")
                            .font(.footnote)
                    }
                    .padding()
                }
                .splitArrangementLayoutRatio(0.35)
            }
            .arrangementViewStyle(.split.axes([.horizontal, .vertical]))
        }
        .onHingeChange(isEnabled: true) { _, context in
            receivedHingeEvent = true
            hinge = context.hinge
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink {
                        ScrollView {
                            APILabSummary(items: items, category: category).padding()
                        }
                        .navigationTitle("摘要")
                    } label: {
                        Label("摘要", systemImage: "chart.bar")
                    }
                    NavigationLink {
                        NativeRegionInspector()
                    } label: {
                        Label("查看保留区域", systemImage: "viewfinder")
                    }
                    NavigationLink {
                        NativeRegionAvoidanceDemo(items: items, category: category)
                    } label: {
                        Label("移动自定义控件", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                    }
                    NavigationLink {
                        NativeOverlayArrangementDemo(items: items, category: category)
                    } label: {
                        Label("叠层排列", systemImage: "square.2.layers.3d")
                    }
                } label: {
                    Label("系统布局详情", systemImage: "info.circle")
                }
                .accessibilityIdentifier("apiLab.nativeDetails")
            }
        }
    }

    private var hingeDescription: String {
        guard receivedHingeEvent else { return "铰链：等待系统事件。" }
        guard let hinge else { return "铰链：最新事件未报告铰链信息。" }
        return "铰链角度：\(hinge.angle.degrees.formatted(.number.precision(.fractionLength(0))))°。仅供只读诊断。"
    }
}

@available(iOS 27.1, *)
private struct SplitArrangementReadout: View {
    @Environment(\.splitArrangementAxis) private var axis

    var body: some View {
        LabeledContent("分割轴向", value: axisDescription)
            .font(.footnote)
    }

    private var axisDescription: String {
        switch axis {
        case .horizontal: "水平"
        case .vertical: "垂直"
        case nil: "未分割"
        @unknown default: "系统选择"
        }
    }
}

/// 演示前景与背景的层级关系，与分栏导航保持独立。
/// 控件读取排列状态，不依赖设备名称或铰链角度阈值。
@available(iOS 27.1, *)
private struct NativeOverlayArrangementDemo: View {
    let items: [WorkItem]
    let category: WorkCategory
    @State private var completedOnly = false

    private var selectedItems: [WorkItem] {
        completedOnly ? items.filter { $0.status == .complete } : items
    }

    var body: some View {
        ArrangementView {
            OverlayReviewControls(completedOnly: $completedOnly, count: selectedItems.count)
                .overlayArrangementEdge(.trailing)
        } secondary: {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("检查看板").font(.largeTitle.bold())
                    Text(category.title).font(.title2)
                    Text(selectedItems.count.formatted())
                        .font(.system(size: 76, weight: .semibold, design: .rounded))
                        .contentTransition(.numericText())
                    Text(completedOnly ? "已完成的记录" : "筛选后的全部记录")
                        .font(.title3)
                    Text("控件位于前景层。系统分离图层时，控件会在各自区域内展开。")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                // 为背景内容预留滚动空间，使其能够移出覆盖层的遮挡范围。
                .padding(.bottom, 240)
            }
            .background(.blue.opacity(0.08))
        }
        .arrangementViewStyle(.overlay.axes([.horizontal, .vertical]))
        .navigationTitle("叠层排列")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    List(selectedItems) { item in
                        WorkItemCard(item: item, compact: false)
                    }
                    .navigationTitle("检查记录")
                } label: {
                    Label("检查记录", systemImage: "list.bullet")
                }
            }
        }
        .accessibilityIdentifier("apiLab.overlayScreen")
    }
}

@available(iOS 27.1, *)
private struct OverlayReviewControls: View {
    @Environment(\.overlayArrangementZIndex) private var zIndex
    @Binding var completedOnly: Bool
    let count: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if zIndex == 0 {
                    Text("检查控件").font(.title2.bold())
                    Text("这些控件现在拥有独立区域。")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Toggle("仅显示已完成", isOn: $completedOnly)
                    .accessibilityIdentifier("apiLab.overlayCompletedOnly")
                Text("显示 \(count) 条记录")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .frame(maxWidth: 360, maxHeight: zIndex == 0 ? .infinity : 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

@available(iOS 27.1, *)
private struct NativeRegionAvoidanceDemo: View {
    let items: [WorkItem]
    let category: WorkCategory
    // 在确定自定义按钮适配 Dynamic Type 后的实际尺寸前，保持按钮隐藏。
    @State private var controlSize = CGSize.zero
    @State private var showsRegions = true
    @State private var prefersBottom = false
    @State private var showsSummary = false

    var body: some View {
        GeometryReader { proxy in
            let regions = proxy.reservedRegions(kind: .division, options: .includeInactive)
                + proxy.reservedRegions(kind: .occlusion, options: .includeInactive)
            let bounds = CGRect(
                x: 12, y: 12,
                width: max(0, proxy.size.width - 24),
                height: max(0, proxy.size.height - 24)
            )
            let preferred = CGPoint(x: bounds.midX, y: prefersBottom ? bounds.maxY : bounds.midY)
            let placement = ReservedRegionPlacement.frame(
                for: controlSize,
                in: bounds,
                avoiding: regions.map { .init(frame: $0.frame, isActive: $0.isActive) },
                preferredCenter: preferred
            )

            ZStack(alignment: .topLeading) {
                Color.blue.opacity(0.06)
                if showsRegions {
                    ForEach(Array(regions.enumerated()), id: \.offset) { _, region in
                        Rectangle()
                            .fill(region.isActive ? Color.orange.opacity(0.28) : Color.gray.opacity(0.12))
                            .overlay {
                                Rectangle().strokeBorder(
                                    region.isActive ? Color.orange : Color.gray,
                                    style: StrokeStyle(lineWidth: 1, dash: region.isActive ? [] : [4, 4])
                                )
                            }
                            .frame(width: max(0, region.frame.width), height: max(0, region.frame.height))
                            .position(x: region.frame.midX, y: region.frame.midY)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                Button {
                    showsSummary = true
                } label: {
                    Label("检查记录", systemImage: "checklist")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .fixedSize()
                .onGeometryChange(for: CGSize.self) { $0.size } action: { controlSize = $0 }
                .position(x: placement?.midX ?? bounds.midX, y: placement?.midY ?? bounds.midY)
                .opacity(placement == nil ? 0 : 1)
                .allowsHitTesting(placement != nil)
                .accessibilityHidden(placement == nil)
                .accessibilityIdentifier("apiLab.avoidingControl")
            }
            .clipped()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("检查按钮会避开生效的区域。如果没有足够空间，请使用工具栏中的检查操作。")
                Text("橙色：生效 • 灰色：未生效。区域边框已包含交互边距。")
                    .foregroundStyle(.secondary)
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial)
        }
        .navigationTitle("自定义控件位置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("检查", systemImage: "checklist") { showsSummary = true }
                    .accessibilityIdentifier("apiLab.reviewFallback")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("显示保留区域", isOn: $showsRegions)
                    Toggle("优先底部居中", isOn: $prefersBottom)
                    NavigationLink("几何信息详情") { NativeRegionInspector() }
                } label: {
                    Label("位置选项", systemImage: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showsSummary) {
            NavigationStack {
                List {
                    Section { APILabSummary(items: items, category: category) }
                    Section("记录") {
                        ForEach(items) { WorkItemCard(item: $0, compact: false) }
                    }
                }
                .navigationTitle("检查记录")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { showsSummary = false }
                    }
                }
            }
        }
        .accessibilityIdentifier("apiLab.regionAvoidanceScreen")
    }
}

@available(iOS 27.1, *)
private struct NativeRegionInspector: View {
    var body: some View {
        GeometryReader { proxy in
            let divisions = proxy.reservedRegions(kind: .division, options: .includeInactive)
            let occlusions = proxy.reservedRegions(kind: .occlusion, options: .includeInactive)
            List {
                Section {
                    Text("这些值描述当前检查器的局部坐标空间。此处显式包含未生效区域；避让决策应仅考虑生效区域。")
                    Text("局部尺寸：\(number(proxy.size.width)) × \(number(proxy.size.height)) pt")
                }
                regionSection("分隔区域", regions: divisions)
                regionSection("遮挡区域", regions: occlusions)
            }
        }
        .navigationTitle("保留区域")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func regionSection(_ title: String, regions: [ReservedRegion]) -> some View {
        Section(title) {
            if regions.isEmpty {
                Text("没有相交的区域。这是有效结果。")
            }
            ForEach(Array(regions.enumerated()), id: \.offset) { index, region in
                VStack(alignment: .leading, spacing: 6) {
                    Text("区域 \(index + 1)：\(region.isActive ? "生效" : "未生效")").font(.headline)
                    Text("原点：\(number(region.frame.minX)), \(number(region.frame.minY)) pt")
                    Text("尺寸：\(number(region.frame.width)) × \(number(region.frame.height)) pt")
                    Text("边距：\(String(describing: region.margins))")
                    Text("标识符：\(String(describing: region.id))")
                }
                .font(.footnote)
            }
        }
    }

    private func number(_ value: CGFloat) -> String {
        Double(value).formatted(.number.precision(.fractionLength(1)))
    }
}
#endif

#if DEBUG
#Preview("系统布局") {
    SampleDataPreview { data in
        NavigationStack {
            SystemArrangementDemo(items: data.items, category: .all)
        }
    }
}
#endif
