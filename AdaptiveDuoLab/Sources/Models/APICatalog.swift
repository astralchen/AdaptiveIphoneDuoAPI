import Foundation

/// 将每个示例映射到实际源码及其可用性要求；特定硬件仍为可选条件。
struct APICatalogEntry: Identifiable {
    let id: String
    let name: String
    let version: String
    let purpose: String
    let status: String
    let ordinaryPhone: String
    let source: String
    let documentation: String


    var demoRoute: APIDemoRoute? {
        switch id {
        case "arrangement", "regions", "hinge": .system
        case "overflow", "priority", "axis", "minimization", "compression", "edge", "vertical": .toolbar
        case "tabs", "tabPlacement": .tabs
        case "anylayout", "corners": .layout
        case "uikitCorners", "uikitSafeArea", "uikitNavigation", "uikitTabs": .uikit
        case "uikitBars": .uikitToolbar
        case "sheets": .presentations
        case "camera": .camera
        default: nil
        }
    }

    var documentationURL: URL? {
        URL(string: documentation.hasPrefix("https://")
            ? documentation
            : "https://developer.apple.com/documentation/swiftui/" + documentation)
    }

    static let entries: [Self] = [
        .init(id: "navigation", name: "NavigationSplitView", version: "iOS 16+",
              purpose: "根据可用空间调整侧边栏和详情导航。",
              status: "已在工作区实现",
              ordinaryPhone: "在紧凑空间中折叠导航；所选分类的状态保留在容器上层。",
              source: "RootView.workspace", documentation: "navigationsplitview"),
        .init(id: "fit", name: "ViewThatFits", version: "iOS 16+",
              purpose: "选择提供的备选视图中第一个适合可用空间的视图。",
              status: "已在工作区顶部实现",
              ordinaryPhone: "相同的水平、堆叠和菜单备选布局适用于窄屏 iPhone 和大字号。",
              source: "DashboardHeader", documentation: "viewthatfits"),
        .init(id: "geometry", name: "GeometryReader", version: "iOS 13+",
              purpose: "提供局部空间信息，用于判断内容是否适合当前布局。",
              status: "已在工作区和原生 API 示例中实现",
              ordinaryPhone: "测量实际内容区域；应用仍需提供自身的网格和顶部布局规则。",
              source: "DashboardView / SystemArrangementDemo", documentation: "geometryreader"),
        .init(id: "tabs", name: "Tab 与 TabView", version: "Tab：iOS 18+；TabView：iOS 13+",
              purpose: "声明稳定的导航目标，由系统呈现原生标签页。",
              status: "已实现；iOS 17 使用 tabItem 和 tag",
              ordinaryPhone: "系统选择受支持的标签栏位置。预览姿态不会强制使用垂直标签栏。",
              source: "RootView.tabs", documentation: "tabview"),
        .init(id: "glass", name: "glassEffect", version: "iOS 26+",
              purpose: "为示例面板应用系统玻璃外观。",
              status: "已实现，并提供 Material 回退样式",
              ordinaryPhone: "外观在 iOS 26+ 上自适应；此效果不会修正内容尺寸或折叠布局。",
              source: "WorkItemCard.adaptivePanel", documentation: "view/glasseffect(_:in:)"),
        .init(id: "overflow", name: "ToolbarOverflowMenu", version: "iOS 27+",
              purpose: "将次要工具栏操作分组放入系统溢出菜单。",
              status: "已在交互式工具栏示例中实现",
              ordinaryPhone: "适用于受支持的系统工具栏空间有限的场景，无需铰链硬件。",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "toolbaroverflowmenu"),
        .init(id: "priority", name: "visibilityPriority", version: "iOS 27+",
              purpose: "设置空间变化时工具栏内容的显示优先级。",
              status: "已在交互式工具栏示例中实现",
              ordinaryPhone: "优先显示关键操作，并确保所有受支持布局中的溢出菜单操作均可访问。",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "toolbarcontent/visibilitypriority(_:)"),
        .init(id: "arrangement", name: "ArrangementView", version: "iOS 27.1 beta+",
              purpose: "根据尺寸、Trait 和硬件环境排列主要与次要内容。",
              status: "已提供原生示例源代码；需要 DUO_SDK 和 iOS 27.1",
              ordinaryPhone: "使用可用空间，不会人为模拟折叠处。所有记录保留在主区域；摘要也可通过工具栏访问。",
              source: "SystemArrangementDemo / NativeArrangementContent", documentation: "arrangementview"),
        .init(id: "regions", name: "ReservedRegion 与 reservedRegions", version: "iOS 27.1 beta+",
              purpose: "报告局部分隔区域和遮挡区域的边框、边距及生效状态。",
              status: "实时检查器与自定义控件避让示例",
              ordinaryPhone: "没有折叠处的设备也可能报告遮挡区域。空结果和未生效结果均有效；避让示例明确使用生效区域的边框定位按钮。",
              source: "SystemArrangementDemo / ReservedRegionPlacement", documentation: "geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:)"),
        .init(id: "axis", name: "ToolbarContent.axisBehavior", version: "iOS 27.1 beta+",
              purpose: "控制自定义工具栏内容能否参与各轴向的工具栏布局。",
              status: "已实现，可选择自定义控件轴向",
              ordinaryPhone: "优先使用系统默认值；若某操作不支持某个轴向，应提供其他访问入口。",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "toolbarcontent/axisbehavior(_:)"),
        .init(id: "minimization", name: "toolbarMinimizationBehavior", version: "iOS 27+",
              purpose: "控制工具栏能否随内容变化而最小化。",
              status: "已实现，可选择工具栏偏好设置",
              ordinaryPhone: "工具栏最小化时仍需确保操作易于发现；此行为与改变轴向不同。",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "view/toolbarminimizationbehavior(_:for:)"),
        .init(id: "compression", name: "toolbarVerticalCompressionBehavior", version: "iOS 27.1 beta+",
              purpose: "控制受支持的垂直工具栏压缩行为。",
              status: "已实现，可选择工具栏偏好设置",
              ordinaryPhone: "自定义控件仍需提供清晰可读的紧凑样式和完整标签。",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "view/toolbarverticalcompressionbehavior(_:)"),
        .init(id: "edge", name: "toolbarVerticalEdge", version: "iOS 27.1 beta+",
              purpose: "报告垂直工具栏的首选边缘，即使工具栏已隐藏。",
              status: "已用于自定义控件适配与诊断",
              ordinaryPhone: "nil 表示当前环境不使用垂直工具栏；不能据此判断工具栏是否可见。",
              source: "NativeToolbarRecords / NativeReviewControl", documentation: "environmentvalues/toolbarverticaledge"),
        .init(id: "vertical", name: "toolbarVerticalBehavior", version: "iOS 27.1 beta+",
              purpose: "设置垂直工具栏的呈现偏好。",
              status: "已实现，可选择工具栏偏好设置",
              ordinaryPhone: "偏好设置不会增加硬件能力，也不会强制所有场景使用相同的工具栏位置。",
              source: "ToolbarAPIDemo / NativeToolbarRecords", documentation: "view/toolbarverticalbehavior(_:)"),
        .init(id: "hinge", name: "onHingeChange 与 DeviceHingeContext", version: "iOS 27.1 beta+",
              purpose: "接收可选的物理铰链信息，用于诊断或视觉效果。",
              status: "已提供原生示例源代码；只读显示事件",
              ordinaryPhone: "上下文可能不包含铰链。核心布局应随容器调整，而非依赖铰链角度阈值。",
              source: "NativeArrangementContent", documentation: "view/onhingechange(isenabled:_:)"),
        .init(id: "camera", name: "CameraCaptureAccessory", version: "iOS 27.1 beta+",
              purpose: "支持在符合条件的另一块显示屏上呈现相机采集附属内容。",
              status: "已在用户主动启动的相机预览中实现",
              ordinaryPhone: "系统未报告附属显示能力时，后置相机预览仍可使用。仅在启动后请求相机权限。",
              source: "CameraAPIDemo / NativeCameraDemo", documentation: "cameracaptureaccessory"),
        .init(id: "anylayout", name: "AnyLayout", version: "iOS 16+",
              purpose: "重新排列同一个视图层级，同时保留编辑器状态。",
              status: "可交互的水平／垂直任务编辑器",
              ordinaryPhone: "窄窗口和辅助功能字号下使用垂直布局。",
              source: "LayoutAPIDemo", documentation: "anylayout"),
        .init(id: "corners", name: "ConcentricRectangle", version: "iOS 26+",
              purpose: "根据容器形状和内边距计算内侧圆角曲线。",
              status: "可交互的同心／固定圆角对比及内边距滑块",
              ordinaryPhone: "较早系统保留编辑器，并显示圆角功能的可用条件。",
              source: "LayoutAPIDemo / ConcentricCornerDemo", documentation: "concentricrectangle"),
        .init(id: "tabPlacement", name: "defaultTabBarPlacement", version: "iOS 27+；自适应位置需要 iOS 18+",
              purpose: "在受支持的环境中设置标签栏／侧边栏的默认呈现偏好。",
              status: "共享笔记状态的原生标签页会话",
              ordinaryPhone: "系统保留受支持的呈现位置；iPad 使用 defaultAdaptableTabBarPlacement。",
              source: "TabAPIDemo / TabDemoSession", documentation: "view/defaulttabbarplacement(_:)"),
        .init(id: "uikitCorners", name: "UICornerConfiguration", version: "iOS 26+",
              purpose: "使嵌套 UIKit 视图的圆角与容器协调一致。",
              status: "可交互的 UIKit 内边距与圆角对比",
              ordinaryPhone: "较早系统使用固定的图层圆角半径。",
              source: "UIKitAPIDemo / UIKitLayoutController", documentation: "https://developer.apple.com/documentation/uikit/uicornerconfiguration"),
        .init(id: "uikitSafeArea", name: "safeAreaLayoutGuide 与局部 Trait", version: "iOS 11+；本项目最低支持 iOS 17",
              purpose: "将控件保持在各自独立的安全区域边缘内，并读取局部显示比例。",
              status: "嵌入式 UIKit Auto Layout 与不对称边距实验",
              ordinaryPhone: "旋转和调整窗口大小时，左右边距保持相互独立。",
              source: "UIKitAPIDemo / UIKitLayoutController", documentation: "https://developer.apple.com/documentation/uikit/uiview/safearealayoutguide"),
        .init(id: "uikitNavigation", name: "UISplitViewController", version: "iOS 3.2+；分栏样式需要 iOS 14+",
              purpose: "折叠和展开原生导航栏列。",
              status: "嵌入式 UIKit 列表／详情及可编辑草稿",
              ordinaryPhone: "原生紧凑导航会保留所选草稿。",
              source: "UIKitAPIDemo", documentation: "https://developer.apple.com/documentation/uikit/uisplitviewcontroller"),
        .init(id: "uikitTabs", name: "UITabBarController 侧边栏", version: "侧边栏模式需要 iOS 18+；位置设置需要 iOS 27+",
              purpose: "按照侧边栏偏好呈现原生 UIKit 导航目标。",
              status: "全屏 UIKit 标签页对比",
              ordinaryPhone: "不支持侧边栏的环境仍使用普通标签栏。",
              source: "UIKitAPIDemo", documentation: "https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/preferredplacement"),
        .init(id: "uikitBars", name: "UIKit 工具栏适配", version: "溢出菜单需要 iOS 16+；优先级需要 iOS 27+；垂直控件需要 iOS 27.1+",
              purpose: "适配由 UIKit 导航管理的操作、优先级、溢出菜单和自定义控件。",
              status: "可交互的 UIKit 工具栏会话",
              ordinaryPhone: "较早系统仍可使用基础系统操作。",
              source: "UIKitToolbarAPIDemo", documentation: "https://developer.apple.com/documentation/uikit/uibarbuttonitem/visibilitypriority"),
        .init(id: "sheets", name: "sheet 与 presentationDetents", version: "Detent 需要 iOS 16+",
              purpose: "呈现可调整大小的编辑器，并由父视图保留草稿。",
              status: "可操作的 Sheet、Popover、Alert 和操作菜单",
              ordinaryPhone: "原生呈现方式会在所有受支持的手机上适应可用空间。",
              source: "PresentationAPIDemo", documentation: "view/presentationdetents(_:)")
    ]
}


enum APIDemoRoute: String, CaseIterable, Identifiable {
    case system, toolbar, tabs, layout, uikit, uikitToolbar, presentations, camera
    var id: Self { self }

    var title: String {
        switch self {
        case .system: "系统布局与区域"
        case .toolbar: "SwiftUI 工具栏操作"
        case .tabs: "标签页与侧边栏"
        case .layout: "重新布局与同心圆角"
        case .uikit: "UIKit 布局与导航"
        case .uikitToolbar: "UIKit 工具栏操作"
        case .presentations: "Sheet 与呈现方式"
        case .camera: "相机附属显示"
        }
    }

    var symbol: String {
        switch self {
        case .system: "rectangle.split.2x1"
        case .toolbar: "ellipsis.rectangle"
        case .tabs: "sidebar.left"
        case .layout: "rectangle.2.swap"
        case .uikit: "square.stack.3d.up"
        case .uikitToolbar: "slider.horizontal.3"
        case .presentations: "rectangle.bottomthird.inset.filled"
        case .camera: "camera"
        }
    }

    var accessibilityIdentifier: String {
        self == .system ? "apiLab.systemDemo" : "apiLab.demo.\(rawValue)"
    }
}
