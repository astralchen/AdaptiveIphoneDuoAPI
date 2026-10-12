# AdaptiveIphoneDuoAPI

**使用 SwiftUI 和 UIKit 为 iPhone Duo 构建自适应布局**

本项目是我在 [PhonePe](https://www.linkedin.com/company/phonepe-internet/) 主办的 [Swift Bengaluru](https://www.linkedin.com/company/swiftbengaluru/) 技术聚会上分享的演示项目。

[Somendra Yadav](https://www.linkedin.com/in/somendrayadav/)，高级软件工程师。

> 根据窗口的可用空间构建界面。让内容、局部几何信息和安全区域指导布局，同时保持用户任务的连续性。

## 项目介绍

**AdaptiveDuoLab** 探索如何让现有 iOS 应用适应不断变化的窗口尺寸、方向和显示配置。它将自适应工作区与 **API 实验室中的 8 个交互示例和 25 项 API 条目**结合在一起。

示例涵盖 SwiftUI 和 UIKit，包括导航、内容重新布局、系统排列、保留区域、工具栏、同心圆角、呈现方式和相机附属显示。

## 主应用

| 页面 | 演示内容 |
| --- | --- |
| **工作区** | 共享 SwiftData 记录、分类筛选、自动／列表／网格呈现、自适应控件，以及模拟的书本折叠和桌面模式预览。 |
| **检查** | 显示所选分类、呈现方式、姿态和记录数，并提供基于配置的布局指导。也可通过 Sheet 呈现。 |
| **设置** | 管理共享的演示偏好，并提供 API 实验室入口。 |

选择状态由根视图管理，使导航和配置在布局变化时保持一致。SwiftData 提供共享的记录存储。

## 演示视频

通过 AdaptiveDuoLab 的完整演示，了解内容重新布局、自适应导航、工具栏行为和交互式 API 示例。

[▶ 观看完整演示](https://youtu.be/rzcijZY8b2M)

<table>
  <tr>
    <th>演示 1</th>
    <th>演示 2</th>
    <th>演示 3</th>
  </tr>
  <tr>
    <td align="center">
      <video width="240" height="360" controls
        src="https://github.com/user-attachments/assets/fc145bde-6764-4e14-81a5-5a6cca4f14c6">
      </video>
    </td>
    <td align="center">
      <video width="240" height="360" controls
        src="https://github.com/user-attachments/assets/956d38ea-0ac2-42ec-965c-594a3a86ff6b">
      </video>
    </td>
    <td align="center">
      <video width="240" height="360" controls
        src="https://github.com/user-attachments/assets/8eb8bc2b-6979-4902-8a6d-51da48f7baf5">
      </video>
    </td>
  </tr>
</table>

## 分享中的演示内容

### 灵活布局与内容重新排列

- 使用 [GeometryReader](https://developer.apple.com/documentation/swiftui/geometryreader) 测量局部容器。
- 使用 [AnyLayout](https://developer.apple.com/documentation/swiftui/anylayout) 在水平和垂直内容布局之间切换，同时保留编辑器及其状态。
- 使用 [ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits) 提供横向、堆叠和紧凑控件等备选布局。
- 适配 Dynamic Type，允许文本沿垂直方向扩展，并在辅助功能字号下使用单列内容布局。
- 重新布局示例的动画遵循 Reduce Motion 设置。

**试一试：** 编辑任务标题和完成数量，然后调整窗口大小或启用**优先使用垂直布局**。这些值会保持不变。

### 原生导航、标签页与侧边栏

- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview) 在导航呈现方式变化时，仍保留工作区的访问入口。
- [TabView](https://developer.apple.com/documentation/swiftui/tabview)、`.sidebarAdaptable` 和标签栏位置偏好，使导航目标在不同可用空间中保持一致。
- UIKit 示例使用 `UITabBarController`、`UITab` 和 `UISplitViewController`。
- 在演示会话中切换页面或调整窗口大小时，标签页笔记和 UIKit 各主题的草稿仍会保留。

### 安全区域与局部几何信息

- 将可交互内容保持在安全区域内，同时允许装饰性背景延伸到系统栏后方。
- 分别测试左右边距，避免假设两侧对称。
- 使用 UIKit 的 `safeAreaLayoutGuide`、`view.bounds`、`safeAreaInsets` 和 `traitCollection.displayScale`。

**试一试：** 更改 UIKit 示例中的左右测试边距，并查看局部几何信息。

### 分割与叠层排列

[ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview) 演示两种内容关系：

- **Split：** 筛选后的每条记录都保留在主视图中，次级视图显示分类摘要。示例支持两个轴向，将次级区域的比例偏好设为 `0.35`，并显示 `splitArrangementAxis`。
- **Overlay：** 检查控件使用 `overlayArrangementEdge`，并通过 `overlayArrangementZIndex` 调整呈现方式。“仅显示已完成”开关会筛选实际记录。

独立的摘要／检查入口确保这些功能始终可访问。

### 保留区域与铰链诊断

- 通过 [ReservedRegion](https://developer.apple.com/documentation/swiftui/reservedregion) 查询，检查分隔区域和遮挡区域的几何信息。
- 区分生效、未生效和空结果。
- 测量自定义检查按钮，并将其放置在生效的保留区域边框之外。
- 自定义按钮没有足够空间时，仍可使用原生工具栏中的检查操作。
- 通过 `onHingeChange` 观察可选的 [DeviceHinge](https://developer.apple.com/documentation/swiftui/devicehinge) 信息。

保留区域查询负责报告几何信息；应用负责自定义控件的避让。铰链信息仅用于诊断。

### SwiftUI 和 UIKit 工具栏

工具栏会话提供可实际执行的**检查、置顶、添加、排序／反转顺序和摘要**操作。

- 使用具有明确语义的位置，包括醒目的末尾侧固定操作。
- 使用 `visibilityPriority` 和 [ToolbarOverflowMenu](https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu)。
- 通过 `axisBehavior` 选择自定义检查控件的轴向行为。
- 通过 `toolbarVerticalCompressionBehavior` 比较标签栏与操作项的优先级。
- 通过 `toolbarVerticalBehavior` 设置会话中的工具栏偏好。
- 滚动时使用 `toolbarMinimizationBehavior`。
- 通过 [toolbarVerticalEdge](https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge) 调整自定义控件的呈现方式。

UIKit 会话演示导航项分组、`pinnedTrailingGroup`、由导航控制器管理的工具栏、溢出菜单操作，以及对应的原生优先级、轴向和压缩属性。

**试一试：** 在打开会话前选择策略，执行操作并查看更新后的计数。内容页和操作页提供额外入口，确保关键操作均可访问。

### 同心圆角

将固定圆角与 SwiftUI 中的 [ConcentricRectangle](https://developer.apple.com/documentation/swiftui/concentricrectangle)、UIKit 中的 [UICornerConfiguration](https://developer.apple.com/documentation/uikit/uicornerconfiguration-swift.struct) 进行比较。

**试一试：** 切换同心圆角并调整内边距，观察内侧曲线如何随容器变化。

### Sheet 与呈现方式

可编辑的 Sheet 支持 medium 和 large Detent，并与呈现它的视图共享草稿。此示例还包含 Popover、Alert 和操作菜单，操作后的状态变化清晰可见。

**试一试：** 编辑草稿、调整窗口大小、关闭并重新打开 Sheet。父视图会保留草稿。

### 相机附属显示

由用户主动启动的 AVFoundation 后置相机预览，用于演示 [CameraCaptureAccessory](https://developer.apple.com/documentation/swiftui/cameracaptureaccessory)、`sceneAccessory` 和可用性变化。

**试一试：** 启动相机，更改共享的演讲提示，并在系统报告可用时启用附属显示功能。没有附属显示能力时，预览仍可使用。离开页面或将应用切至后台会停止采集。

### App Resizability 工作流程

分享还介绍了 Apple 的 **Xcode App Resizability skill**：检查现有项目、审阅建议的源代码修改，并验证窗口大小调整、状态连续性、安全区域和旧系统回退行为。

仓库包含 [App Resizability 工作流程指南](AdaptiveDuoLab/Docs/Apple_App_Resizability_Workflow.md)。

## 浏览代码

打开**设置 → 打开 API 实验室**。

| 交互示例 | 实现文件 |
| --- | --- |
| 系统布局与区域 | [SystemArrangementDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/SystemArrangementDemo.swift) |
| SwiftUI 工具栏操作 | [ToolbarAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/ToolbarAPIDemo.swift) |
| 标签页与侧边栏 | [TabAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/TabAPIDemo.swift) |
| 重新布局与同心圆角 | [LayoutAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/LayoutAPIDemo.swift) |
| UIKit 布局与导航 | [UIKitAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/UIKitAPIDemo.swift) |
| UIKit 工具栏操作 | [UIKitToolbarAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/UIKitToolbarAPIDemo.swift) |
| Sheet 与呈现方式 | [PresentationAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/PresentationAPIDemo.swift) |
| 相机附属显示 | [CameraAPIDemo.swift](https://github.com/SomuYadav/AdaptiveIphoneDuoAPI/blob/main/AdaptiveDuoLab/Sources/Views/CameraAPIDemo.swift) |

请参阅 [API 采用指南](AdaptiveDuoLab/Docs/API_Adoption_Guide.md)，了解完整的 API、可用条件和回退行为对应关系。

## 运行项目

1. 从 [Apple Developer Downloads](https://developer.apple.com/download/) 安装 [Xcode](https://developer.apple.com/xcode/)。
2. 打开 `AdaptiveDuoLab/AdaptiveDuoLab.xcworkspace`，选择 **AdaptiveDuoLab** scheme。
3. 当前项目默认启用 `DUO_SDK`，完整原生 Duo 示例需要 **Xcode 27.1 和 iOS 27.1 SDK**，并选择兼容的运行环境。
4. 如需使用 **iOS 26 SDK 或更高版本**构建基础版本，请从对应配置的 **Active Compilation Conditions** 中移除 `DUO_SDK`，并保留其他已有值。
5. 运行应用，打开**设置 → 打开 API 实验室**。

## 演示范围

- 工作区的书本折叠和桌面模式属于模拟预览。原生排列和区域处理位于 API 实验室中。
- 布局阈值和分割比例是示例内容的偏好设置。
- 根视图中的选择状态和本地草稿遵循各自视图／会话的生命周期。示例未实现应用重新启动后的状态恢复。
- 布局检查使用本地配置规则。App Resizability 是分享中介绍的开发工作流程。
- 相机示例仅提供预览，不保存照片、音频或视频。
- 2026 年 10 月 12 日，中文界面版本已使用 Xcode 27.1 在 iPhone Duo（iOS 27.1）模拟器上通过编译、18 项单元测试和 7 项 UI 测试。这些结果不代表所有原生 API 或真机相机能力均已验证。

## Apple 资源

- [Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/)
- [Raise the bar with iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111462/)
- [Strike a pose with adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466/)
