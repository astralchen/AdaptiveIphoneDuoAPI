import Observation
import SwiftUI
import UIKit

/// 独立呈现 UIKit 的标签栏控制器和导航控制器，
/// 避免将其嵌套在 API Lab 的 SwiftUI 导航栈中。
@MainActor
struct UIKitToolbarAPIDemo: View {
	@State private var state = UIKitToolbarDemoState()
	@State private var prefersTabs = false
	@State private var horizontalReview = false
	@State private var showingSession = false

	var body: some View {
		List {
			Section {
				Text(
					"检查、置顶、排序和添加操作使用原生 UIKit 工具栏按钮" +
					"及系统溢出菜单。记录和操作" +
					"标签页共享相同的本地状态。"
				)

				Toggle(
					"垂直空间受限时优先保留标签栏",
					isOn: $prefersTabs
				)

				Toggle(
					"将检查操作保留在水平工具栏中",
					isOn: $horizontalReview
				)

				Button(
					"打开 UIKit 工具栏会话",
					systemImage: "play.rectangle"
				) {
					showingSession = true
				}
				.accessibilityIdentifier(
					"apiLab.uiKitToolbar.open"
				)
			} header: {
				Text("UIKit 工具栏会话")
			} footer: {
				Text(availabilityDescription)
			}

			Section {
				LabeledContent(
					"检查次数",
					value: state.reviewCount.formatted()
				)
				.accessibilityIdentifier(
					"apiLab.uiKitToolbar.launcherReviewCount"
				)

				LabeledContent(
					"记录",
					value: state.recordCount.formatted()
				)

				Text(state.lastAction)
					.foregroundStyle(.secondary)
			} header: {
				Text("会话状态")
			}
		}
		.navigationTitle("UIKit 工具栏 API")
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityIdentifier(
			"apiLab.uiKitToolbar.screen"
		)
		.fullScreenCover(isPresented: $showingSession) {
			UIKitToolbarControllerHost(
				state: state,
				prefersTabs: prefersTabs,
				horizontalReview: horizontalReview,
				close: {
					showingSession = false
				}
			)
			.ignoresSafeArea()
		}
	}

	private var availabilityDescription: String {
		#if DUO_SDK
		if #available(iOS 27.1, *) {
			return """
			已启用原生优先级、轴向和压缩偏好。\
			垂直工具栏是否可用由系统决定。
			"""
		}
		#endif

		return """
		此构建版本支持系统溢出菜单和操作。\
		优先级、轴向和垂直压缩设置需要 \
		iOS 27.1 SDK、DUO_SDK=1，以及 iOS 27.1 或更高版本。
		"""
	}
}


@MainActor
@Observable
private final class UIKitToolbarDemoState {
    var recordCount = 30
    var reviewCount = 0
    var pinned = false
    var newestFirst = false
    var lastAction = "会话已就绪"
}

@MainActor
private struct UIKitToolbarControllerHost: UIViewControllerRepresentable {
    let state: UIKitToolbarDemoState
    let prefersTabs: Bool
    let horizontalReview: Bool
    let close: () -> Void

    func makeUIViewController(context: Context) -> UITabBarController {
        let records = UIKitToolbarRecordsController(
            state: state, showsActions: false, prefersTabs: prefersTabs,
            horizontalReview: horizontalReview, close: close
        )
        let actions = UIKitToolbarRecordsController(
            state: state, showsActions: true, prefersTabs: prefersTabs,
            horizontalReview: horizontalReview, close: close
        )
        let recordNavigation = UINavigationController(rootViewController: records)
        recordNavigation.tabBarItem = UITabBarItem(title: "记录", image: UIImage(systemName: "doc.on.doc"), tag: 0)
        let actionNavigation = UINavigationController(rootViewController: actions)
        actionNavigation.tabBarItem = UITabBarItem(title: "操作", image: UIImage(systemName: "checklist"), tag: 1)
        let tabs = UITabBarController()
        tabs.setViewControllers([recordNavigation, actionNavigation], animated: false)
        return tabs
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // 本次呈现期间配置保持不变。窗口尺寸变化时，UIKit 会保留控制器、
        // 表格滚动位置和标签页状态。
    }
}

@MainActor
private final class UIKitToolbarRecordsController: UITableViewController {
    private let state: UIKitToolbarDemoState
    private let showsActions: Bool
    private let prefersTabs: Bool
    private let horizontalReview: Bool
    private let close: () -> Void
    private var edgeDescription = "此构建版本不支持原生垂直工具栏边缘信息"
    private var pinItem: UIBarButtonItem?

    init(state: UIKitToolbarDemoState, showsActions: Bool, prefersTabs: Bool,
         horizontalReview: Bool, close: @escaping () -> Void) {
        self.state = state
        self.showsActions = showsActions
        self.prefersTabs = prefersTabs
        self.horizontalReview = horizontalReview
        self.close = close
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("请使用代码初始化器") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = showsActions ? "UIKit 操作" : "UIKit 记录"
        tableView.accessibilityIdentifier = "apiLab.uiKitToolbar.table"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        let closeItem = barButton("关闭", symbol: "xmark", action: #selector(closeSession))
        closeItem.accessibilityIdentifier = "apiLab.uiKitToolbar.close"
        navigationItem.leadingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [closeItem], representativeItem: nil)
        ]

        let review = barButton("检查", symbol: "checkmark.seal", action: #selector(reviewRecords))
        review.accessibilityIdentifier = "apiLab.uiKitToolbar.review"
        let pin = barButton("置顶集合", symbol: "pin", action: #selector(togglePin))
        pinItem = pin
        let sort = barButton("反转顺序", symbol: "arrow.up.arrow.down", action: #selector(reverseOrder))
        navigationItem.trailingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [review], representativeItem: nil),
            UIBarButtonItemGroup(barButtonItems: [sort], representativeItem: nil)
        ]
        // 置顶按钮仅属于此分组，不得同时加入尾部分组或 rightBarButtonItems。
        // 分组只有一个按钮时，无需设置 representativeItem。
        navigationItem.pinnedTrailingGroup = UIBarButtonItemGroup(
            barButtonItems: [pin], representativeItem: nil
        )

        // 此工具栏由导航控制器管理，因此呈现方式变化时，
        // 它会参与系统布局及 safe area 更新。
        let add = barButton("添加示例记录", symbol: "plus", action: #selector(addRecord))
        add.accessibilityIdentifier = "apiLab.uiKitToolbar.add"
        let summary = barButton("会话摘要", symbol: "chart.bar", action: #selector(showSummary))
        summary.accessibilityIdentifier = "apiLab.uiKitToolbar.summary"
        toolbarItems = [
            add,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            summary
        ]

        // UIKit 的此属性接收延迟加载的菜单元素，而非工具栏按钮项。
        let overflowActions: [UIMenuElement] = [
            UIAction(title: "添加示例记录", image: UIImage(systemName: "plus")) { [weak self] _ in
                self?.addRecord()
            },
            UIAction(title: "会话摘要", image: UIImage(systemName: "chart.bar")) { [weak self] _ in
                self?.showSummary()
            }
        ]
        navigationItem.additionalOverflowItems = UIDeferredMenuElement.uncached { completion in
            completion(overflowActions)
        }

        #if DUO_SDK
        if #available(iOS 27.1, *) {
            review.visibilityPriority = .high
            pin.visibilityPriority = .standard
            sort.visibilityPriority = .low
            review.axisBehavior = horizontalReview ? .horizontalOnly : .verticalPreferred
            navigationItem.verticalBarCompressionBehavior = prefersTabs ? .prefersTabBar : .prefersBarItems
        }
        #endif
        refreshState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
        refreshState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        #if DUO_SDK
        if #available(iOS 27.1, *) {
            let newDescription: String
            switch traitCollection.verticalBarEdge {
            case .leading: newDescription = "优先起始侧边缘"
            case .trailing: newDescription = "优先末尾侧边缘"
            case .unspecified: newDescription = "当前环境中没有首选垂直边缘"
            @unknown default: newDescription = "无法识别的垂直边缘"
            }
            if newDescription != edgeDescription {
                edgeDescription = newDescription
                tableView.reloadData()
            }
        }
        #endif
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 4 : (showsActions ? 4 : state.recordCount)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "实时会话" : (showsActions ? "可在此访问全部操作" : "记录")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.accessibilityIdentifier = nil
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                content.text = "检查次数：\(state.reviewCount) · 记录数：\(state.recordCount)"
                cell.accessibilityIdentifier = "apiLab.uiKitToolbar.counts"
            case 1:
                content.text = state.lastAction
                cell.accessibilityIdentifier = "apiLab.uiKitToolbar.lastAction"
            case 2:
                content.text = edgeDescription
                content.secondaryText = "首选边缘信息不能用于判断工具栏是否可见。"
            default:
                content.text = "检查记录"
                content.image = UIImage(systemName: "checkmark.seal")
                cell.selectionStyle = .default
                cell.accessibilityIdentifier = "apiLab.uiKitToolbar.reviewFallback"
            }
        } else if showsActions {
            content.text = ["检查记录", "切换集合置顶状态", "反转记录顺序", "添加示例记录"][indexPath.row]
            cell.selectionStyle = .default
        } else {
            let number = state.newestFirst ? state.recordCount - indexPath.row : indexPath.row + 1
            content.text = "示例记录 \(number)"
            content.image = UIImage(systemName: "doc.text")
        }
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0, indexPath.row == 3 {
            reviewRecords()
        } else if indexPath.section == 1, showsActions {
            switch indexPath.row {
            case 0: reviewRecords()
            case 1: togglePin()
            case 2: reverseOrder()
            default: addRecord()
            }
        }
    }

    private func barButton(_ title: String, symbol: String, action: Selector) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: UIImage(systemName: symbol), style: .plain, target: self, action: action)
        item.title = title
        item.accessibilityLabel = title
        return item
    }

    @objc private func closeSession() { close() }

    @objc private func reviewRecords() {
        state.reviewCount += 1
        state.lastAction = "已检查记录 · \(state.reviewCount) 次"
        refreshState()
    }

    @objc private func togglePin() {
        state.pinned.toggle()
        state.lastAction = state.pinned ? "集合已置顶" : "集合已取消置顶"
        refreshState()
    }

    @objc private func reverseOrder() {
        state.newestFirst.toggle()
        state.lastAction = state.newestFirst ? "最新记录优先" : "最早记录优先"
        refreshState()
    }

    @objc private func addRecord() {
        state.recordCount += 1
        state.lastAction = "已添加示例记录 \(state.recordCount)"
        refreshState()
    }

    @objc private func showSummary() {
        let alert = UIAlertController(title: "会话摘要", message: "\(state.recordCount) 条记录 · 已检查 \(state.reviewCount) 次\n\(edgeDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "完成", style: .default))
        present(alert, animated: true)
    }

    private func refreshState() {
        pinItem?.title = state.pinned ? "取消置顶集合" : "置顶集合"
        pinItem?.accessibilityLabel = pinItem?.title
        pinItem?.image = UIImage(systemName: state.pinned ? "pin.fill" : "pin")
        tableView.reloadData()
    }
}
