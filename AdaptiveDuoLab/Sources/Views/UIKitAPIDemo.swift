import SwiftUI
import UIKit

struct UIKitAPIDemo: View {
    var body: some View {
        UIKitLayoutControllerHost()
            .navigationTitle("UIKit 布局")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("apiLab.uikit.screen")
    }
}

private struct UIKitLayoutControllerHost: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitLayoutController {
        UIKitLayoutController()
    }

    func updateUIViewController(_ uiViewController: UIKitLayoutController, context: Context) {}
}

/// 背景填满视图边界；所有交互内容均使用当前视图的 safe area 布局指南。
/// 无需引用全局屏幕，也无需复制其他视图的边距。
private final class UIKitLayoutController: UIViewController {
    var showsNavigationDemoButton = true
    private let geometryLabel = UIKitLayoutController.makeLabel(style: .footnote)
    private let insetLabel = UIKitLayoutController.makeLabel(style: .body)
    private let outerCard = UIView()
    private let innerCard = UIView()
    private let insetSlider = UISlider()
    private let concentricSwitch = UISwitch()
    private var innerConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // safe area 约束已提供所需边距，避免重复应用。
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 24, trailing: 16)
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        stack.addArrangedSubview(Self.makeLabel("独立的安全区域边缘", style: .title2))
        stack.addArrangedSubview(Self.makeLabel("为任意一侧添加额外的测试边距。Auto Layout 会独立跟随各侧边缘，背景仍填满视图。"))
        let edgeControl = UISegmentedControl(items: ["无", "左侧 +44", "右侧 +44"])
        edgeControl.selectedSegmentIndex = 0
        edgeControl.accessibilityLabel = "额外安全区域边距"
        edgeControl.accessibilityIdentifier = "apiLab.uikit.safeAreaControl"
        edgeControl.addTarget(self, action: #selector(changeSafeArea(_:)), for: .valueChanged)
        stack.addArrangedSubview(edgeControl)
        geometryLabel.textColor = .secondaryLabel
        geometryLabel.accessibilityIdentifier = "apiLab.uikit.geometry"
        stack.addArrangedSubview(geometryLabel)

        stack.addArrangedSubview(Self.makeLabel("UIKit 同心圆角", style: .title2))
        let switchLabel = Self.makeLabel("使用同心圆角")
        let switchRow = UIStackView(arrangedSubviews: [switchLabel, concentricSwitch])
        switchRow.spacing = 12
        switchRow.alignment = .center
        concentricSwitch.isOn = true
        concentricSwitch.accessibilityLabel = "使用同心圆角"
        concentricSwitch.accessibilityIdentifier = "apiLab.uikit.concentric"
        concentricSwitch.setContentHuggingPriority(.required, for: .horizontal)
        concentricSwitch.addTarget(self, action: #selector(changeCorners), for: .valueChanged)
        stack.addArrangedSubview(switchRow)

        insetSlider.minimumValue = 8
        insetSlider.maximumValue = 32
        insetSlider.value = 12
        insetSlider.accessibilityLabel = "UIKit 卡片内边距"
        insetSlider.accessibilityIdentifier = "apiLab.uikit.inset"
        insetSlider.addTarget(self, action: #selector(changeInset), for: .valueChanged)
        stack.addArrangedSubview(insetLabel)
        stack.addArrangedSubview(insetSlider)
        configureCard()
        stack.addArrangedSubview(outerCard)

        if #available(iOS 26.0, *) {
            stack.addArrangedSubview(Self.makeLabel("UICornerConfiguration 根据所在容器视图计算内侧圆角。拖动内边距滑块，或与固定圆角比较。", style: .footnote))
        } else {
            concentricSwitch.isEnabled = false
            concentricSwitch.isOn = false
            stack.addArrangedSubview(Self.makeLabel("同心圆角需要 iOS 26。此设备使用固定圆角；安全区域和分栏导航仍可使用。", style: .footnote))
        }

        if showsNavigationDemoButton {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.title = "打开 UIKit 标签页与分栏导航"
            let splitButton = UIButton(configuration: buttonConfiguration)
            splitButton.accessibilityIdentifier = "apiLab.uikit.openSplit"
            splitButton.addTarget(self, action: #selector(openSplitNavigation), for: .touchUpInside)
            stack.addArrangedSubview(splitButton)
            stack.addArrangedSubview(Self.makeLabel("切换标签页，选择主题并编辑草稿，然后更改窗口宽度。导航呈现方式由系统决定。", style: .footnote))
        }
        changeInset()
        changeCorners()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGeometryLabel()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateGeometryLabel()
    }

    private func configureCard() {
        outerCard.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.22)
        innerCard.backgroundColor = .secondarySystemGroupedBackground
        innerCard.translatesAutoresizingMaskIntoConstraints = false
        outerCard.addSubview(innerCard)
        innerConstraints = [
            innerCard.topAnchor.constraint(equalTo: outerCard.topAnchor, constant: 12),
            innerCard.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 12),
            outerCard.trailingAnchor.constraint(equalTo: innerCard.trailingAnchor, constant: 12),
            outerCard.bottomAnchor.constraint(equalTo: innerCard.bottomAnchor, constant: 12)
        ]
        NSLayoutConstraint.activate(innerConstraints)

        let text = Self.makeLabel("自适应卡片\n调整内边距，比较内外圆角曲线。")
        text.translatesAutoresizingMaskIntoConstraints = false
        innerCard.addSubview(text)
        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: innerCard.topAnchor, constant: 24),
            text.leadingAnchor.constraint(equalTo: innerCard.leadingAnchor, constant: 24),
            text.trailingAnchor.constraint(equalTo: innerCard.trailingAnchor, constant: -24),
            text.bottomAnchor.constraint(equalTo: innerCard.bottomAnchor, constant: -24)
        ])
    }

    @objc private func changeSafeArea(_ sender: UISegmentedControl) {
        additionalSafeAreaInsets = UIEdgeInsets(
            top: 0,
            left: sender.selectedSegmentIndex == 1 ? 44 : 0,
            bottom: 0,
            right: sender.selectedSegmentIndex == 2 ? 44 : 0
        )
    }

    @objc private func changeInset() {
        let inset = CGFloat(insetSlider.value.rounded())
        innerConstraints.forEach { $0.constant = inset }
        insetLabel.text = "卡片内边距：\(Int(inset)) pt"
        insetSlider.accessibilityValue = "\(Int(inset)) 点"
    }

    @objc private func changeCorners() {
        if #available(iOS 26.0, *) {
            outerCard.cornerConfiguration = .corners(radius: .fixed(40))
            innerCard.cornerConfiguration = .corners(
                radius: concentricSwitch.isOn ? .containerConcentric() : .fixed(24)
            )
        } else {
            outerCard.layer.cornerRadius = 40
            innerCard.layer.cornerRadius = 24
        }
    }

    private func updateGeometryLabel() {
        let insets = view.safeAreaInsets
        let text = String(
            format: "局部视图：%.0f × %.0f pt · 缩放比例 %.1f×\n安全区域：上 %.0f · 左 %.0f · 下 %.0f · 右 %.0f",
            view.bounds.width, view.bounds.height,
            view.traitCollection.displayScale,
            insets.top, insets.left, insets.bottom, insets.right
        )
        if geometryLabel.text != text { geometryLabel.text = text }
    }

    @objc private func openSplitNavigation() {
        let tabs = UIKitNavigationDemoController()
        tabs.modalPresentationStyle = .fullScreen
        present(tabs, animated: true)
    }

    fileprivate static func makeLabel(_ text: String = "", style: UIFont.TextStyle = .body) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }
}

private final class UIKitNavigationDemoController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UIKitLayoutController()
        layout.showsNavigationDemoButton = false
        layout.title = "布局"
        layout.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(closeDemo)
        )
        let layoutNavigation = UINavigationController(rootViewController: layout)
        let split = UIKitSplitDemoController(style: .doubleColumn)
        split.onClose = { [weak self] in self?.dismiss(animated: true) }

        if #available(iOS 18.0, *) {
            tabs = [
                UITab(title: "布局", image: UIImage(systemName: "rectangle.inset.filled"), identifier: "layout") { _ in
                    layoutNavigation
                },
                UITab(title: "主题", image: UIImage(systemName: "rectangle.split.2x1"), identifier: "topics") { _ in
                    split
                }
            ]
            mode = .tabSidebar
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                // 侧边栏偏好设置属于 iOS 27 API，仅在启用 Duo 实验室
                // 其余示例共用的可选 27.1 SDK 配置时编译。
                sidebar.preferredPlacement = .sidebar
            }
            #endif
        } else {
            layoutNavigation.tabBarItem = UITabBarItem(title: "布局", image: UIImage(systemName: "rectangle.inset.filled"), tag: 0)
            split.tabBarItem = UITabBarItem(title: "主题", image: UIImage(systemName: "rectangle.split.2x1"), tag: 1)
            viewControllers = [layoutNavigation, split]
        }
        view.accessibilityIdentifier = "apiLab.uikit.tabs"
    }

    @objc private func closeDemo() {
        dismiss(animated: true)
    }
}

/// 直接作为标签页内容承载，不压入导航栈。
private final class UIKitSplitDemoController: UISplitViewController {
    var onClose: (() -> Void)?
    private let list = UIKitTopicListController(style: .insetGrouped)
    private let detail = UIKitTopicDetailController()

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .oneBesideSecondary
        setViewController(UINavigationController(rootViewController: list), for: .primary)
        setViewController(UINavigationController(rootViewController: detail), for: .secondary)
        list.onSelect = { [weak self] title in
            guard let self else { return }
            self.detail.setTopic(title)
            self.show(.secondary)
        }
        for child in [list as UIViewController, detail] {
            child.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done, target: self, action: #selector(closeDemo)
            )
        }
    }

    @objc private func closeDemo() {
        if let onClose { onClose() } else { dismiss(animated: true) }
    }
}

private final class UIKitTopicListController: UITableViewController {
    var onSelect: ((String) -> Void)?
    private let topics = ["导航", "安全区域", "同心圆角"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "主题"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "topic")
        tableView.accessibilityIdentifier = "apiLab.uikit.topics"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topic", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = topics[indexPath.row]
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(topics[indexPath.row])
    }
}

private final class UIKitTopicDetailController: UIViewController, UITextViewDelegate {
    private var topic = "导航"
    private var drafts: [String: String] = [:]
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = topic
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.delegate = self
        textView.text = drafts[topic] ?? "\(topic)的笔记草稿。编辑此文本，然后调整窗口大小。"
        textView.accessibilityLabel = "主题笔记"
        textView.accessibilityIdentifier = "apiLab.uikit.draft"
        textView.contentInsetAdjustmentBehavior = .never
        view.addSubview(textView)
        // 左右边缘分别约束到当前容器，彼此独立。
        // 键盘布局指南确保在紧凑窗口中输入时，编辑器仍然可用。
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12)
        ])
    }

    func setTopic(_ newTopic: String) {
        if isViewLoaded { drafts[topic] = textView.text }
        topic = newTopic
        title = newTopic
        if isViewLoaded {
            textView.text = drafts[newTopic] ?? "\(newTopic)的笔记草稿。编辑此文本，然后调整窗口大小。"
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        drafts[topic] = textView.text
    }
}

#if DEBUG
#Preview("UIKit 布局") {
    NavigationStack {
        UIKitAPIDemo()
    }
}
#endif
