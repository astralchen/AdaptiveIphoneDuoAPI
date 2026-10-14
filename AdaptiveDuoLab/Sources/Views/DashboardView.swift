import SwiftUI

struct DashboardView: View {
    let items: [WorkItem]
    let selectedCategory: WorkCategory
    @Binding var presentation: CollectionPresentation
    @Binding var pose: DemoPose
    @Binding var showsAudit: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { proxy in
            let decision = AdaptiveLayoutPolicy.decision(
                width: proxy.size.width,
                pose: pose,
                presentation: presentation,
                height: proxy.size.height,
                dynamicTypeSize: dynamicTypeSize
            )
            // 根据演示内容所需空间判断，与设备型号或屏幕方向无关。
            // 字体较大或窗口较矮时，将详情区域优先留给记录内容。
            let usesCompactControls = proxy.size.height < 520 || dynamicTypeSize >= .xxxLarge

            ZStack {
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.18),
                        Color.cyan.opacity(0.08),
                        Color(uiColor: .systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    if usesCompactControls {
                        Text(decision.usesGrid ? "\(decision.columnCount) 列网格" : "自适应列表")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("layout.decision")
                    } else {
                        DashboardHeader(
                            presentation: $presentation,
                            pose: $pose,
                            showsAudit: $showsAudit,
                            decision: decision
                        )
                    }

                    content(for: decision)
                }
                .padding(.horizontal, decision.contentPadding)
                .padding(.top, 12)
            }
            .navigationTitle(usesCompactControls ? "自适应工作区" : selectedCategory.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if usesCompactControls {
                    ToolbarItem(placement: .topBarTrailing) {
                        compactOptionsMenu
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showsAudit = true
                        } label: {
                            Label("布局检查", systemImage: "checkmark.seal")
                        }
                        .labelStyle(.iconOnly)
                        .accessibilityIdentifier("audit.open")
                    }
                }
            }
        }
    }

    private var compactOptionsMenu: some View {
        Menu {
            Section("布局") {
                ForEach(CollectionPresentation.allCases) { option in
                    Button {
                        withAnimation(.snappy) {
                            presentation = option
                        }
                    } label: {
                        Label(option.title, systemImage: option.symbol)
                    }
                    .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
                }
            }

            Menu {
                Picker("预览姿态", selection: $pose) {
                    ForEach(DemoPose.allCases) { option in
                        Label(option.title, systemImage: option.symbol)
                            .tag(option)
                    }
                }
            } label: {
                Label(pose.title, systemImage: pose.symbol)
            }
            .accessibilityLabel("预览姿态")
            .accessibilityValue(pose.title)
            .accessibilityIdentifier("pose.menu")
        } label: {
            Label("工作区选项", systemImage: "slider.horizontal.3")
        }
        .labelStyle(.iconOnly)
        .accessibilityValue(presentation.title)
        .accessibilityIdentifier("layout.menu")
    }

    @ViewBuilder
    private func content(for decision: LayoutDecision) -> some View {
        switch decision.composition {
        case .single:
            ItemCollection(items: items, decision: decision)
        case .book:
            BookFoldLayout(items: items)
        case .tabletop:
            TabletopLayout(items: items, decision: decision)
        }
    }
}

private struct DashboardHeader: View {
    @Binding var presentation: CollectionPresentation
    @Binding var pose: DemoPose
    @Binding var showsAudit: Bool
    let decision: LayoutDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    heading
                    Spacer(minLength: 12)
                    auditButton
                }
                .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 12) {
                    heading
                    auditButton
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    layoutButtons
                    Spacer(minLength: 12)
                    poseControl
                    decisionBadge
                }
                .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 10) {
                    layoutControls
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 12) {
                            poseControl
                            Spacer(minLength: 12)
                            decisionBadge
                        }
                        .fixedSize(horizontal: true, vertical: false)

                        VStack(alignment: .leading, spacing: 10) {
                            poseControl
                            decisionBadge
                        }
                    }
                }
            }
        }
        .padding(18)
        .adaptivePanel()
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("自适应工作区")
                .font(.largeTitle.bold())
            Text(layoutExplanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var layoutExplanation: String {
        if pose == .bookFold && decision.composition == .single {
            return "当可用空间或文字大小受限时，书本预览使用单一区域。"
        }
        if pose == .tabletop && decision.composition == .single {
            return "当窗口高度或文字大小受限时，桌面预览使用单一集合。"
        }
        return pose.explanation
    }

    private var auditButton: some View {
        Button {
            showsAudit = true
        } label: {
            Label("布局检查", systemImage: "checkmark.seal")
        }
        .buttonStyle(.borderedProminent)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityIdentifier("audit.open")
    }

    private var layoutControls: some View {
        ViewThatFits(in: .horizontal) {
            layoutButtons
                .fixedSize(horizontal: true, vertical: false)

            Menu {
                ForEach(CollectionPresentation.allCases) { option in
                    Button {
                        select(option)
                    } label: {
                        Label(option.title, systemImage: option.symbol)
                    }
                    .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
                }
            } label: {
                Label(presentation.title, systemImage: presentation.symbol)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("布局")
            .accessibilityValue(presentation.title)
            .accessibilityIdentifier("layout.menu")
        }
    }

    private var layoutButtons: some View {
        HStack(spacing: 8) {
            layoutButton(.automatic)
            layoutButton(.list)
            layoutButton(.grid)
        }
    }

    @ViewBuilder
    private func layoutButton(_ option: CollectionPresentation) -> some View {
        if option == presentation {
            Button {
                select(option)
            } label: {
                Label(option.title, systemImage: option.symbol)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
        } else {
            Button {
                select(option)
            } label: {
                Label(option.title, systemImage: option.symbol)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("layout.\(option.rawValue.lowercased())")
        }
    }

    private func select(_ option: CollectionPresentation) {
        withAnimation(.snappy) {
            presentation = option
        }
    }

    private var poseControl: some View {
        Menu {
            Picker("预览姿态", selection: $pose) {
                ForEach(DemoPose.allCases) { option in
                    Label(option.title, systemImage: option.symbol)
                        .tag(option)
                }
            }
        } label: {
            Label(pose.title, systemImage: pose.symbol)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("pose.menu")
    }

    private var decisionBadge: some View {
        Text(decision.usesGrid ? "\(decision.columnCount) 列网格" : "自适应列表")
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.indigo.opacity(0.12), in: Capsule())
            .accessibilityIdentifier("layout.decision")
    }
}

private struct ItemCollection: View {
    let items: [WorkItem]
    let decision: LayoutDecision

    var body: some View {
        ScrollView {
            if decision.usesGrid {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 14),
                        count: decision.columnCount
                    ),
                    spacing: 14
                ) {
                    cards
                }
            } else {
                LazyVStack(spacing: 12) {
                    cards
                }
            }
        }
        .contentMargins(.bottom, 24, for: .scrollContent)
        .accessibilityIdentifier("dashboard.collection")
    }

    @ViewBuilder
    private var cards: some View {
        ForEach(items) { item in
            WorkItemCard(item: item, compact: decision.usesGrid)
        }
    }
}

private struct BookFoldLayout: View {
    let items: [WorkItem]

    var body: some View {
        HStack(spacing: 0) {
            DuoRegion(
                title: "起始侧区域",
                items: items.enumerated().compactMap {
                    $0.offset.isMultiple(of: 2) ? $0.element : nil
                }
            )

            LinearGradient(
                colors: [.black.opacity(0.42), .indigo.opacity(0.32), .black.opacity(0.42)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 26)
            .overlay {
                Text("折叠处")
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
            }

            DuoRegion(
                title: "末尾侧区域",
                items: items.enumerated().compactMap {
                    $0.offset.isMultiple(of: 2) ? nil : $0.element
                }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityIdentifier("pose.bookLayout")
    }
}

private struct DuoRegion: View {
    let title: String
    let items: [WorkItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items) { item in
                        WorkItemCard(item: item, compact: true)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial)
    }
}

private struct TabletopLayout: View {
    let items: [WorkItem]
    let decision: LayoutDecision

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "rectangle.split.1x2")
                    .font(.system(size: 42))
                    .foregroundStyle(.indigo)
                Text("内容区域")
                    .font(.title2.bold())
                Text("醒目内容保持在模拟铰链上方。")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)

            Rectangle()
                .fill(.black.opacity(0.55))
                .frame(height: 20)
                .overlay {
                    Text("模拟铰链")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.82))
                }

            ItemCollection(items: items, decision: decision)
                .frame(maxHeight: .infinity)
                .padding(.top, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityIdentifier("pose.tabletopLayout")
    }
}

#if DEBUG
/// 保留可编辑状态，并补齐页面在 RootView 中获得的 Sheet 呈现行为。
private struct DashboardPreview: View {
    let items: [WorkItem]
    @State private var presentation: CollectionPresentation
    @State private var pose: DemoPose
    @State private var showsAudit = false

    init(items: [WorkItem], presentation: CollectionPresentation = .automatic, pose: DemoPose = .automatic) {
        self.items = items
        _presentation = State(initialValue: presentation)
        _pose = State(initialValue: pose)
    }

    var body: some View {
        NavigationStack {
            DashboardView(
                items: items,
                selectedCategory: .all,
                presentation: $presentation,
                pose: $pose,
                showsAudit: $showsAudit
            )
        }
        .sheet(isPresented: $showsAudit) {
            LayoutAuditView(itemCount: items.count, pose: pose, presentation: presentation)
        }
    }
}

#Preview("工作区 · 窄屏列表", traits: .fixedLayout(width: 390, height: 844)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items, presentation: .list)
    }
}

#Preview("工作区 · 宽屏网格", traits: .fixedLayout(width: 1000, height: 800)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items, presentation: .grid)
    }
}

#Preview("工作区 · 书本折叠", traits: .fixedLayout(width: 1000, height: 800)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items, pose: .bookFold)
    }
}

#Preview("工作区 · 桌面模式", traits: .fixedLayout(width: 1000, height: 800)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items, pose: .tabletop)
    }
}

#Preview("工作区 · 辅助功能大字体", traits: .fixedLayout(width: 390, height: 844)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("工作区 · 深色网格", traits: .fixedLayout(width: 1000, height: 800)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items, presentation: .grid)
    }
    .preferredColorScheme(.dark)
}

#Preview("工作区 · RTL 列表", traits: .fixedLayout(width: 390, height: 844)) {
    SampleDataPreview { data in
        DashboardPreview(items: data.items, presentation: .list)
    }
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
