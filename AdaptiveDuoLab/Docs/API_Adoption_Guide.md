# AdaptiveDuoLab：Apple API 采用指南

中文文档更新于 2026 年 10 月 12 日；原始资料核验日期为 2026 年 9 月 26 日，其中 iOS 27.1 参考资料处于 beta 阶段。请以实际构建所用 SDK 的头文件和可用性声明为准。

## 本版本的变化

现有应用的**设置 → 打开 API 实验室**包含 **8 个交互示例和 25 项 API 条目**，补充此前源码中缺少的自适应 API。重新布局、圆角、工具栏策略、标签页／侧边栏、UIKit、呈现方式、相机附属显示和原生排列均位于同一项目中。清单标明源码位置及可用条件，有对应示例时提供**体验此 API**入口。API 实验室保留独立导航栈，系统布局示例使用现有筛选后的 SwiftData 记录，不创建其他存储，也不替换应用的三个标签页。

原生排列演示位于工作区的 `NavigationSplitView` 之外。Split 示例将全部筛选记录保留在主区域，次级区域显示真实分类摘要，允许两个轴向，并设置 0.35 的次级区域比例偏好。摘要也有独立入口。Overlay 示例修改实际的已完成记录筛选，并通过 `overlayArrangementZIndex` 适配控件。两者均不通过读取 `DemoPose` 强制硬件行为。

保留区域检查器仍可使用，自定义控件示例使用生效的分隔／遮挡区域边框，定位已测量的检查按钮。按钮无法放下时，可通过原生工具栏操作打开相同的摘要和记录。未生效或空结果均有效。查询本身不会实现避让：`ReservedRegionPlacement` 提供应用的放置策略。铰链事件仍为只读诊断，不驱动布局。

**当前中文版本已通过 Mac 编译和 Simulator 测试。** 2026 年 10 月 12 日，Xcode 27.1／iPhone Duo（iOS 27.1）上的 18 项单元测试和 7 项 UI 测试全部通过。结果不覆盖所有原生行为和真机能力。17 页演示文稿将较早项目截图与 API 说明配对，这些图片不能验证新增示例。详细来源保留在备注和指南中，不另设参考资料或附录页。工作区仍使用已有 Dashboard 策略和模拟姿态预览；API 实验室并不表示整个应用已全面迁移。

## API、作用、项目位置与回退

| API | 引入版本 | 作用 | 准确项目位置／状态 | 其他受支持 iPhone／回退 |
| --- | --- | --- | --- | --- |
| `GeometryReader` | iOS 13 | 测量局部内容空间 | `DashboardView.body`；`NativeArrangementContent`；`NativeRegionInspector` | 应用提供适配规则；几何信息不代表某种特定设备。 |
| `NavigationSplitView` | iOS 16 | 自适应侧边栏／详情导航 | `RootView.workspace`；已实现 | 紧凑空间中使用原生折叠。侧边栏呈现由系统管理；未使用的应用策略标志已移除。 |
| `ViewThatFits` | iOS 16 | 选择开发者提供的第一个适合空间的备选视图 | `DashboardHeader`；`WorkItemCard` 元数据；已实现 | 水平／堆叠／菜单备选布局适用于普通 iPhone。它不会自动生成缺失的备选布局。 |
| `Tab`、`TabView` | Tab：iOS 18；TabView：iOS 13 | 原生导航目标容器和系统标签栏呈现 | `RootView.tabs`；已实现 | iOS 17 使用 `.tabItem` 和稳定 tag。垂直工具栏行为取决于链接的 SDK 和当前系统环境。 |
| `glassEffect` | iOS 26 | 系统玻璃外观 | `WorkItemCard.adaptivePanel`；已实现 | 较早系统使用 regular Material。编译此符号仍需 SDK 26+。 |
| `AnyLayout`、`HStackLayout`、`VStackLayout` | iOS 16 | 重新排列相关视图并保留身份 | `LayoutAPIDemo.body`；可编辑任务和完成摘要 | 使用局部宽度及辅助功能字号，并提供垂直偏好。 |
| `ConcentricRectangle` | iOS 26 | 内侧圆角随容器形状调整 | `LayoutAPIDemo.swift` 中的 `ConcentricCornerDemo`；开关和内边距滑块 | iOS 26 无需特殊硬件；旧系统显示可用条件，重新布局功能仍可使用。 |
| `UICornerConfiguration`、`.containerConcentric()` | iOS 26 | 对应的原生 UIKit 圆角几何 | `UIKitLayoutController.changeCorners` | 旧系统使用固定圆角；内边距控件仍可操作。 |
| `safeAreaLayoutGuide`、`safeAreaInsets`、`view.bounds` | 现有 UIKit API | 独立的局部边缘布局和读数 | `UIKitLayoutController`；可控的左右测试边距 | 不查询全局屏幕，也不假设相对边缘一致。 |
| `UISplitViewController` | 现有 UIKit 容器 | 原生列折叠和展开 | `UIKitSplitDemoController`；全屏 UIKit 会话中的主题页面 | 会话内调整窗口时保留本地主题草稿。 |
| `UITabBarController`、`UITab`、`.tabSidebar`、`sidebar.preferredPlacement` | UITab／侧边栏模式：iOS 18；偏好：iOS 27 | 原生 UIKit 导航目标和侧边栏偏好 | `UIKitAPIDemo.swift` 中的 `UIKitNavigationDemoController` | iOS 17 使用普通标签页控制器；本示例中的新位置设置受原生构建和 iOS 27.1 检查保护。 |
| `.sidebarAdaptable`、`defaultAdaptableTabBarPlacement`、`defaultTabBarPlacement` | 样式／自适应偏好：iOS 18；较新偏好：iOS 27 | 优先使用原生标签栏或侧边栏 | `TabAPIDemo.swift` 中的 `TabDemoSession.modernPresentation` | iOS 17 使用 tabItem；受支持的 iOS 18 环境使用自适应位置；系统选择实际呈现方式。 |
| `ToolbarOverflowMenu` | iOS 27 | 在系统溢出菜单中显式提供次要操作 | `ToolbarAPIDemo.swift` 中的 `NativeToolbarRecords`；添加、摘要和检查操作 | 基础会话使用普通菜单；原生呈现随可用空间变化。 |
| `visibilityPriority` | iOS 27 | 设置工具栏项进入溢出菜单的相对优先级 | `NativeToolbarRecords`；检查优先级开关及低优先级操作 | 高优先级不保证可见。其他位置仍保留操作入口。 |
| `ArrangementView`、`.split.axes`、`splitArrangementLayoutRatio`、`splitArrangementAxis` | iOS 27.1 beta | 组合相关记录／摘要并显示轴向信息 | `NativeArrangementContent`、`SplitArrangementReadout` | 允许两个轴向；0.35 是比例偏好，不是固定像素。基础构建显示连续列表。 |
| `.overlay.axes`、`overlayArrangementEdge`、`overlayArrangementZIndex` | iOS 27.1 beta | 将前景控件叠层或分离呈现 | `NativeOverlayArrangementDemo`、`OverlayReviewControls` | 仅显示已完成会改变实际筛选数量；检查记录仍有独立入口。 |
| `ReservedRegion`、`GeometryProxy.reservedRegions` | iOS 27.1 beta | 局部分隔／遮挡几何与自定义控件避让 | `NativeRegionInspector`、`NativeRegionAvoidanceDemo`；`ReservedRegionPlacement` | 不人为添加铰链间隙。只有生效边框影响位置；无合适候选位置时保留原生检查入口。 |
| `ToolbarContent.axisBehavior` | iOS 27.1 beta | 自定义检查控件参与的轴向 | `NativeToolbarRecords`；自动／仅限水平／优先垂直 | 控件不支持某轴向时，列表操作和操作标签页仍提供入口。 |
| `toolbarMinimizationBehavior` | iOS 27 | 导航栏最小化 | `NativeToolbarRecords`；自动、从不及滚动方向选项 | 滚动记录列表以比较偏好。基础预览不会模拟该行为。 |
| `toolbarVerticalCompressionBehavior` | iOS 27.1 beta | 垂直压缩时优先保留标签栏或操作项 | `NativeToolbarRecords`；下次会话选择器 | 优先保留工具栏操作会先压缩标签栏；仅在系统提供共享垂直栏时有意义。 |
| `EnvironmentValues.toolbarVerticalEdge` | iOS 27.1 beta | 支持垂直工具栏环境中的首选边缘 | `NativeToolbarRecords`、`NativeReviewControl` | 隐藏时也可能有值；`nil` 表示当前环境不使用垂直工具栏。不绘制自定义侧边工具栏。 |
| `toolbarVerticalBehavior` | iOS 27.1 beta | 系统默认或水平工具栏 | `NativeToolbarSession`；呈现前选择 | 会话期间保持稳定；偏好不会增加硬件能力。 |
| `topBarPinnedTrailing` | iOS 27 | 在末尾侧固定醒目的置顶／取消置顶操作 | `NativeToolbarRecords`；更改本地置顶状态 | 位置由系统管理；优先级与固定位置是不同概念。 |
| UIKit `toolbarItems`、`setToolbarHidden`、`leadingItemGroups`、`trailingItemGroups`、`pinnedTrailingGroup` | 受管理工具栏为现有 API；导航分组：iOS 16 | 受管理的添加／摘要工具栏，以及具有语义的关闭、检查／排序和固定置顶分组 | `UIKitToolbarRecordsController`；每项只属于一个分组 | iOS 17 基础版本支持。工具栏由导航控制器管理，不使用自定义 `UIToolbar`。 |
| UIKit `visibilityPriority`、`axisBehavior`、`verticalBarCompressionBehavior`、`verticalBarEdge`、`additionalOverflowItems` | 溢出属性：iOS 16；优先级：iOS 27；垂直 API：iOS 27.1 | UIKit 对应功能，包含记录／操作标签页 | `UIKitToolbarAPIDemo.swift` 中的 `UIKitToolbarRecordsController` | 基础路径支持普通系统操作和溢出菜单；原生属性受 `DUO_SDK` 与 iOS 27.1 检查保护。 |
| `onHingeChange`、`DeviceHingeContext` | iOS 27.1 beta | 铰链事件和可选物理铰链详情 | `NativeArrangementContent`；只读诊断源码 | `context.hinge` 为可选值。事件到达前显示等待状态；nil 不视为布局失败。 |
| `.sheet`、`presentationDetents`、`.popover`、`.alert`、`Menu` | 现有 SwiftUI API | 共享本地状态的系统呈现 | `PresentationAPIDemo`；编辑草稿、标记已检查或置顶 | 系统适配各呈现方式。Popover 可适应紧凑空间，不强制变为自定义面板。 |
| `CameraCaptureAccessory`、`sceneAccessory`、`onAvailabilityChange` | 相机附属显示：iOS 27.1 beta | 在符合条件的相机显示屏上提供可选交互提示 | `CameraAPIDemo.swift` 中的 `NativeCameraDemo`；真实 AVFoundation 后置预览 | 用户主动启动采集。普通手机保留预览／提示；附属显示不可用属于正常状态。不模拟采集输出。 |

清单文本和 `APIDemoRoute` 位于 `Sources/Models/APICatalog.swift`；导航路由位于 `Sources/Views/APILabView.swift`。示例文件位于 `Sources/Views/`，纯几何辅助逻辑位于 `Sources/Layout/ReservedRegionPlacement.swift`。

## 可运行示例对应关系

从**设置 → 打开 API 实验室 → 交互示例**开始。除系统布局外，其他示例使用独立的本地演示状态，不修改持久化 WorkItem 存储。

| 准确入口 | 源文件 | 触发操作与可见状态变化 | 其他手机／旧系统行为 |
| --- | --- | --- | --- |
| 系统布局与区域 | `SystemArrangementDemo.swift` | 原生 Split 显示实际记录和摘要；详情菜单打开叠层排列、查看保留区域和移动自定义控件。仅显示已完成筛选叠层内容；检查打开实际记录。 | 基础版本显示连续列表；原生空区域有效。不模拟折叠间隙。铰链读数仅供诊断。 |
| SwiftUI 工具栏操作 | `ToolbarAPIDemo.swift` | 选择策略后打开原生工具栏会话。检查增加计数，置顶切换状态，反转顺序重排，溢出菜单中的添加改变记录数，摘要显示实时值。 | 基础版本提供普通工具栏／菜单预览。原生边缘可能为 `nil`；记录和操作页面保留控件入口。 |
| 标签页与侧边栏 | `TabAPIDemo.swift` | 在支持时优先使用侧边栏 → 打开标签页示例。编辑笔记、切换摘要并调整大小。 | iOS 17 使用 tabItem；iOS 18 使用自适应样式；原生构建提供 iOS 27 偏好。位置仍由系统选择。 |
| 重新布局与同心圆角 | `LayoutAPIDemo.swift` | 编辑标题／完成数量，切换优先使用垂直布局。在 8–32 pt 间调整圆角内边距，比较同心圆角开关。 | 重新布局使用实际宽度和辅助功能字号；圆角需要 iOS 26，旧系统显示可用条件。 |
| UIKit 布局与导航 | `UIKitAPIDemo.swift` | 更改左右测试边距、圆角和内边距滑块。打开 UIKit 标签页与分栏导航，选择主题并编辑各主题草稿。 | 读取局部 bounds／边距／显示比例；iOS 26 前使用固定圆角；原生标签页／分栏在受支持环境中折叠。 |
| UIKit 工具栏操作 | `UIKitToolbarAPIDemo.swift` | 选择标签栏压缩／检查轴向偏好，再打开 UIKit 工具栏会话。检查、固定的置顶、排序和添加更改共享状态。添加／摘要也出现在导航管理的底部工具栏；关闭使用 leading 分组。 | 基础 UIKit 分组、操作和溢出菜单保留；新优先级／轴向／压缩属性需要原生路径。 |
| Sheet 与呈现方式 | `PresentationAPIDemo.swift` | 在 Sheet 中编辑、显示 Popover、显示提醒并使用操作菜单。父视图中的草稿和上次操作值随之更新。 | 原生呈现正常适配，不强制自定义姿态或 Popover 几何。 |
| 相机附属显示 | `CameraAPIDemo.swift` | 启动相机请求权限；下一条提示更新共享文本。仅在采集已运行且系统报告可用后启用附属显示开关。 | 没有附属显示能力时仍保留实时后置预览。拒绝权限或无相机时显示状态；离开页面／切至后台停止采集。不保存照片、音频或录制内容。 |

保留区域示例在显示按钮前先测量其尺寸，同时避开所有生效的局部边框，忽略未生效／不相交区域；无合适位置时使用原生检查操作。`ReservedRegion.frame` 已包含交互边距，不要重复扩展。0.35 分割比例和 640 pt 重新布局阈值是示例偏好，并非硬件常量。

会话生命周期明确：SwiftUI／UIKit 工具栏操作状态保留在启动页面中，重新打开会话仍存在。标签页笔记属于一次呈现的标签页会话，重新呈现时重置。呈现示例的草稿保留在其父视图中。所有示例均不承诺应用终止后仍持久保存这些状态。

## 系统自动适配与应用职责

| 系统负责 | 应用提供 | Agent skill 可辅助的工作 |
| --- | --- | --- |
| 适配原生导航和受支持的系统栏 | 有意义的导航目标、稳定选择和完整标签 | 查找自定义栏，提出原生容器替换方案 |
| 在 `ViewThatFits` 备选布局中选择 | 实际备选布局及可读的最小布局 | 定位固定尺寸、裁剪和缺失回退 |
| 排列 `ArrangementView` 的两个子视图 | 正确的主／次级关系及次级功能入口 | 重构适当的内容组合、保留状态、增加可用性保护 |
| 报告保留区域几何和铰链事件 | 正确处理坐标、生效状态筛选和能力回退 | 识别自定义内容确实需要几何处理的位置 |
| 缩放 Dynamic Type 文本 | 可滚动性、合理列数和可读控件 | 审查各视图并补充针对性回归覆盖 |

SwiftUI 没有能修复全项目所有自定义布局的开关。Apple **App Resizability** 是 Xcode 27.1 开发 skill，可辅助 Agent 修改源码，不在应用内运行。已核验名称、导出命令、提示词和审阅要求见 [Apple App Resizability 工作流程](Apple_App_Resizability_Workflow.md)。文章中的 SwiftUI Agent Skill 是独立的第三方项目。

## 构建期与运行期可用性检查

最低部署版本保持 iOS 17。基础构建需要 Xcode 26／iOS 26 SDK 或更高版本，因为应用已使用 `glassEffect`。原生源码需要 Xcode 27.1／iOS 27.1 SDK。当前项目默认启用 `DUO_SDK`；使用较早 SDK 构建前应移除此编译条件。

```swift
#if DUO_SDK
if #available(iOS 27.1, *) {
    NativeArrangementContent(items: items, category: category)
} else {
    fallback("请使用 iOS 27.1 或更高版本。")
}
#else
fallback("请使用 27.1 SDK 构建原生示例。")
#endif
```

`#if DUO_SDK` 防止旧 SDK 编译器看到未知的 27.1 声明。原生视图声明上的 `@available` 与调用处的 `#available` 分别保护较早的运行系统版本。仅有可用性检查不能解决 SDK 符号问题。硬件能力仍需检查，或按可选能力处理。

以下保留原演示包在 Mac 解压目录中的脚本用法；当前仓库未包含 `Automation/`，请直接使用 Xcode 运行和测试：

```bash
# 原生 API 示例：启用 DUO_SDK 并打开设置
DEVICE_ID="your-simulator-udid" ./Automation/run-api-demos.sh
```

原快捷命令复用 SDK 验证。基础和显式原生命令如下：

```bash
# 现有基础构建与测试路径
./Automation/run-demo.sh -demo-tab Settings
./Automation/run-tests.sh

# 原生示例：使用已安装的 Simulator UDID 和选定的 Xcode 27.1 SDK
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-demo.sh -demo-tab Settings
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-tests.sh
```

通过 `DEVELOPER_DIR` 选择具体 Xcode 安装。原脚本会检查所选 Simulator SDK，并在启用原生构建时向继承的 Active Compilation Conditions 追加 `DUO_SDK`。当前项目已默认包含该标志；直接使用 Xcode 时，按目标 SDK 保留或移除它，并保持其他已有值。随附的生成项目及 Tuist 的 `Sources/**` 均包含新增文件。

## 现有页面中的具体变化

- **工作区顶部：** 局部几何信息在窗口较矮或字号较大时选择紧凑原生工具栏控件；`ViewThatFits` 提供堆叠和菜单备选布局。
- **记录：** 标题和摘要完整可读，元数据可堆叠，符号容器随字号缩放。集合保持可滚动。
- **布局策略：** 辅助功能字号使用单列和单一连续区域；桌面模式局部高度低于 520 pt 时回退到普通集合。保留所选内容模式和模拟姿态。
- **书本预览：** 需要足够空间容纳两个可读卡片区域，否则全部筛选记录留在连续集合中。预览仍使用模拟分隔区域。
- **检查：** 保持为基于配置的本地规则示例，不是 AI 代码审查器或运行时 Apple skill。
- **设置：** 打开 API 实验室时保留共享分类、模式、姿态和标签页选择。
- **API 实验室：** 提供基础和原生演示，具备实际交互、可用性检查及明确源码位置。

布局阈值属于示例内容规则，并非 Apple 硬件断点。普通侧边栏仍由系统管理。相机附属显示集成包含真实、由用户主动启动的预览流程。应用重新启动后的状态恢复不属于示例范围；示例状态只在所属会话生命周期内保留，不承诺关闭或重新启动后永久存在。

## 在 Mac 上执行的验证矩阵

| 构建／运行环境 | 必需检查 |
| --- | --- |
| 基础版本，iOS 17 | 原生标签页回退、API 清单、普通列表可用性页面、共享数据、完整卡片内容 |
| 基础版本，iOS 26+ | `Tab`、玻璃外观、窄／矮窗口控件、辅助功能字号 |
| 启用原生 SDK 标志，较早运行环境 | 运行时回退，不尝试实例化新 API |
| 启用原生 SDK 标志，普通 iPhone 27.1 | 全部记录可访问，不人为添加铰链间隙，处理空／未生效区域和缺失铰链 |
| 启用原生 SDK 标志，Duo 运行环境／设备 | 调整大小及姿态变化时的系统排列、摘要入口、分隔／遮挡诊断变化 |
| 两种构建 | RTL、VoiceOver 顺序、辅助功能 Dynamic Type、键盘／Sheet 呈现、调整大小及切换标签页前后的状态 |

当前源码有 **18 项单元测试**：10 项布局策略测试、7 项 `ReservedRegionPlacementTests` 和 1 项旧示例数据中文转换兼容测试。另有 **7 项 UI 测试**，覆盖旋转时保留可编辑重新布局状态、关闭／重开工具栏后的状态、相机初始关闭，以及共享状态和 API 实验室流程。2026 年 10 月 12 日，以上测试在 Xcode 27.1／iPhone Duo（iOS 27.1）Simulator 上全部通过。它们不覆盖原生物理行为或每个新入口；矩阵中的旧系统、基础构建、完整无障碍场景及真机能力仍需补充验证。

## Apple 参考资料

- [为 iPhone Duo 适配应用](https://developer.apple.com/videos/play/tech-talks/111461/)
- [使用 iPhone Duo 提升工具栏体验](https://developer.apple.com/videos/play/tech-talks/111462/)
- [iPhone Duo 姿态与自适应布局](https://developer.apple.com/videos/play/tech-talks/111463/)
- [在 iPhone Duo 上使用多显示屏与 Scene](https://developer.apple.com/videos/play/tech-talks/111464/)
- [SwiftUI 新功能 — WWDC26](https://developer.apple.com/videos/play/wwdc2026/269/)
- [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview)
- [GeometryProxy.reservedRegions](https://developer.apple.com/documentation/swiftui/geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:))
- [onHingeChange](https://developer.apple.com/documentation/swiftui/view/onhingechange(isenabled:_:))

## 新 API 完整参考清单

以下清单在实现对应关系之外补充 Apple 参考资料。关于应用实际执行哪些 API，应以上方源码对应关系为准。文档编辑、远程图片加载和外接显示屏播放等产品功能属于背景材料，并非本记录／相机学习流程的必需部分。即使可部署到较早系统，所有声明仍需要对应 SDK。

## 按版本整理：iOS／iPadOS 27.0

以下 API 也适用于运行所需系统的受支持普通 iPhone。实际可用能力和呈现方式取决于硬件。

| 当前准确 API | 用途与集成位置 | 重要限制 | 官方文档 |
|---|---|---|---|
| `ToolbarContent.visibilityPriority(_:)` | 提高常用操作在工具栏溢出时保持可见的机会。先应用于工具栏组，按需再应用到单项。 | 优先级不同于固定位置。 | https://developer.apple.com/documentation/swiftui/toolbarcontent/visibilitypriority(_:) |
| `ToolbarOverflowMenu` | 将低频操作放入系统溢出菜单，避免构建第二个省略号菜单。 | 保留具有独立语义符号的业务菜单。 | https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu |
| `ToolbarItemPlacement.topBarPinnedTrailing` | 将醒目操作放在末尾侧固定位置。 | 有选择地用于重要操作。 | https://developer.apple.com/documentation/swiftui/toolbaritemplacement/topbarpinnedtrailing |
| `TabRole.prominent` | 将购物车等特殊目标与同级浏览标签页区分。 | 不会把按钮操作变成导航目标；并非每个应用都需要。 | https://developer.apple.com/documentation/swiftui/tabrole/prominent |
| `View.toolbarMinimizationBehavior(_:for:)` | 允许导航栏响应滚动最小化，例如 `.onScrollDown`。 | 当前文档支持的位置为 `.navigationBar`；集成的顶部标签栏也会最小化。 | https://developer.apple.com/documentation/swiftui/view/toolbarminimizationbehavior(_:for:) |
| `View.toolbarMinimizationRestoration(_:for:)` | 设置最小化工具栏的恢复时机；`.atScrollEdge` 延迟到内容边缘才恢复。 | 自定义恢复目前仅适用于 `.navigationBar` 配合 `.onScrollDown`。 | https://developer.apple.com/documentation/swiftui/view/toolbarminimizationrestoration(_:for:) |
| `View.toolbarMinimizationSafeAreaAdjustment(_:for:)` | 决定内容是否重新布局以占用导航栏最小化释放的空间。 | `.disabled` 可适用于铺满区域的内容，不应无差别应用于表单和控件。 | https://developer.apple.com/documentation/swiftui/view/toolbarminimizationsafeareaadjustment(_:for:) |
| `View.presentationPlacement(_:)` | 将 Sheet 的首选位置设为 `.leading` 或 `.trailing`，保留有用的底层内容。 | 仅 Sheet 遵循该 modifier。默认值为 `.automatic`。 | https://developer.apple.com/documentation/swiftui/view/presentationplacement(_:) |
| `View.sceneAccessory(content:)` | 将附加 Scene 内容关联到可见视图。 | 附属内容的可用性由系统动态控制。 | https://developer.apple.com/documentation/swiftui/view/sceneaccessory(content:) |
| `ExternalNonInteractiveAccessory` | 在连接的外接显示屏或 AirPlay 显示屏上呈现非交互辅助内容。 | 此能力不同于在 Duo 外屏显示任意应用 UI。 | https://developer.apple.com/documentation/swiftui/externalnoninteractiveaccessory |
| `SceneAccessoryContent.onAvailabilityChange(perform:)` | 响应附属内容可用／不可用变化，启用对应 UI。 | 使用可用性信息，不只检查硬件名称。 | https://developer.apple.com/documentation/swiftui/sceneaccessorycontent/onavailabilitychange(perform:) |

## 按版本整理：iOS／iPadOS 27.1 beta

| 当前准确 API | 解决的问题 | 非 Duo 环境行为／实现说明 | 官方文档 |
|---|---|---|---|
| `ArrangementView(primary:secondary:)` | 将两个相关视图保留在同一布局中，响应尺寸、Size Class 和硬件区域。 | 普通 iPhone／iPad 也可使用。根据内容关系选择，而非设备名称。 | https://developer.apple.com/documentation/swiftui/arrangementview |
| `arrangementViewStyle(.split)` | 根据环境使用水平或垂直轴向并排显示相关内容。 | 适合主／详情内容，不提供导航栈或分栏导航语义。 | https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle |
| `.split.axes(_:)` | 限制允许的分割轴向。 | 限制可能导致次级内容不显示；为必需内容保留其他入口。 | https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle/axes(_:) |
| `arrangementViewStyle(.overlay)` | 将主内容叠放在次级内容上方，并可在存在分隔区域时将它们分离。 | 适合媒体／内容表面之上的前景控件。Primary 是前景视图。 | https://developer.apple.com/documentation/swiftui/overlayarrangementviewstyle |
| `.overlay.axes(_:)` | 限制 Overlay 样式分离内容时可使用的轴向。 | Overlay 不等同于静态 `ZStack`，它可以改变排列。 | https://developer.apple.com/documentation/swiftui/overlayarrangementviewstyle/axes(_:) |
| `splitArrangementLayoutSize(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:)` | 为 Split 子视图提供最小／理想／最大尺寸。 | 宽度约束用于水平排列，高度约束用于垂直排列；较高 `layoutPriority` 优先确定尺寸。 | https://developer.apple.com/documentation/swiftui/view/splitarrangementlayoutsize(minwidth:idealwidth:maxwidth:minheight:idealheight:maxheight:) |
| `splitArrangementLayoutRatio(_:)` | 表达子视图比例尺寸，例如辅助内容占 30%。 | 优先级和剩余可用空间影响分配，不保证固定像素值。 | https://developer.apple.com/documentation/swiftui/view/splitarrangementlayoutratio(_:) |
| `splitArrangementLayoutRatio(minHorizontal:idealHorizontal:maxHorizontal:minVertical:idealVertical:maxVertical:)` | 为各分割轴向设置不同的比例约束。 | 适用于水平和垂直内容需求不同的情况。 | https://developer.apple.com/documentation/swiftui/view/splitarrangementlayoutratio(minhorizontal:idealhorizontal:maxhorizontal:minvertical:idealvertical:maxvertical:) |
| `splitArrangementFixedLayoutSize(horizontal:vertical:)` | 沿所选轴向保留 Split 子视图的理想尺寸。 | 参数是 Bool，**不是以 pt 为单位的尺寸**。 | https://developer.apple.com/documentation/swiftui/view/splitarrangementfixedlayoutsize(horizontal:vertical:) |
| `overlayArrangementEdge(_:)` | 内容分离时，将 Overlay 子视图锚定到首选水平边缘。 | 接收 `HorizontalEdge?`，不是任意 x／y 位置。 | https://developer.apple.com/documentation/swiftui/view/overlayarrangementedge(_:) |
| `EnvironmentValues.overlayArrangementZIndex` | 让子视图 UI 根据当前叠层或分离状态调整。 | 当前类型为 `Int`；使用呈现状态调整紧凑／展开控件。 | https://developer.apple.com/documentation/swiftui/environmentvalues/overlayarrangementzindex |
| `GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)` | 读取局部 `.division` 和 `.occlusion` 区域。 | 空、零值或未生效几何均有效。查询局部内容坐标空间。 | https://developer.apple.com/documentation/swiftui/geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:) |
| `ReservedRegion` | 提供 `frame: CGRect`、`margins: EdgeInsets`、`isActive: Bool`、`id: ReservedRegion.ID` 和区域类型。 | 区域 ID 不是设备型号 ID。 | https://developer.apple.com/documentation/swiftui/reservedregion |
| `ReservedRegion.QueryOptions.includeInactive` | 即使区域未实际分隔／遮挡内容，也将其暴露出来。 | 可用于诊断或一致的网格策略；实际避让应在适用时只考虑生效区域。 | https://developer.apple.com/documentation/swiftui/reservedregion/queryoptions/includeinactive |
| `ToolbarContent.axisBehavior(_:)` | 将工具栏项设为 `.horizontalOnly`，或允许自定义项 `.verticalPreferred`。 | 标签／标题及符号有助于系统推断合适的呈现方式。 | https://developer.apple.com/documentation/swiftui/toolbarcontent/axisbehavior(_:) |
| `EnvironmentValues.toolbarVerticalEdge` | 在受支持环境中读取垂直工具栏的首选水平边缘。 | 类型为 `HorizontalEdge?`；即使没有可见垂直工具栏，偏好也可能存在。`nil` 表示当前环境不使用垂直工具栏。 | https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge |
| `View.toolbarVerticalBehavior(_:)` | 垂直工具栏明显损害某页面体验时，通过 `.disabled` 退出。 | 属于局部设计选择，不是全应用补救措施。 | https://developer.apple.com/documentation/swiftui/view/toolbarverticalbehavior(_:) |
| `View.toolbarVerticalCompressionBehavior(_:)` | 标签栏和工具栏操作竞争垂直空间时设置优先项。 | 包括 `.automatic`、`.prefersTabBar`、`.prefersToolbarItems`；仅在存在垂直呈现时有意义。 | https://developer.apple.com/documentation/swiftui/view/toolbarverticalcompressionbehavior(_:) |
| `View.onHingeChange(isEnabled:_:)` | 接收前一次／当前 `DeviceHingeContext`，用于铰链驱动效果或诊断。 | `context.hinge` 可选，上下文本身不可选。不建议用铰链角度驱动布局。 | https://developer.apple.com/documentation/swiftui/view/onhingechange(isenabled:_:) |
| `DeviceHinge` | 提供 `angle: Angle` 和高层级 `status`。 | 状态包括 `.closed`、`.partiallyOpen`、`.fullyOpen`；没有铰链属于正常情况。 | https://developer.apple.com/documentation/swiftui/devicehinge |
| `CameraCaptureAccessory` | 将外屏上的交互式相机相关内容与内屏相机 UI 配对。 | 需要合适的前台相机体验及正在运行的相机采集；可用性由系统控制。不要仅为展示 API 而添加无关相机会话。 | https://developer.apple.com/documentation/swiftui/cameracaptureaccessory |

## WWDC26 的其他 SwiftUI 新增内容：扩展指南

原稿中的下列条目已与当时的参考文档核对，并非仅依据视频转录。本次翻译保留其 API 名称与版本信息。

| 类别 | 准确名称与可用性 | 作用 | 为何不自动加入此 POC？ |
|---|---|---|---|
| 文档应用 | `Document`、`DocumentWriter`、`DocumentCreationSource` — iOS 27.0 | 文档读写基础设施；在 Main Actor 采集快照后进行后台协调写入，并支持自定义创建流程。 | 示例存储 SwiftData 记录。文档架构属于独立产品功能。 |
| 重排序和多项拖动 | `DynamicViewContent.reorderable()`、`View.reorderContainer(for:isEnabled:move:)`、`ReorderDifference`、`View.dragContainer(for:in:_:)` — iOS 27.0 | 在列表、Stack、网格及自定义布局中重排序，接收差异并提交到应用数据；配置一次拖动中的多个 Transferable 项。 | 需要持久排序模型和移动规则。当前记录按更新时间排序；不改变数据语义就加入拖动会产生误导。 |
| 自定义容器中的侧滑操作 | `View.swipeActionsContainer()` — iOS 27.0；扩展现有 `swipeActions` 用法 | 在自定义 `ScrollView`／`LazyVStack` 中协调同时仅展开一行，滚动或点击外部时关闭操作。 | 仅在存在有意义的行操作时加入。`List` 已协调此行为，该 modifier 在其中不执行额外操作。 |
| 远程图片加载 | `AsyncImage.init(request:scale:)`、`View.asyncImageURLSession(_:)` — iOS 27.0 | 默认缓存遵循传输／缓存头；调用方可提供 URLRequest 或已配置的 URLSession。 | POC 当前没有远程图片加载问题。这属于网络／性能功能，不是 Duo 适配。 |
| State 与 Builder 迁移 | `@State` macro／`State()` 和 `@ContentBuilder` — Xcode 27 新行为，文档说明可向后部署至 iOS 13；Observable 类用法从 iOS 17 开始 | 延迟初始状态避免分配后被丢弃的引用对象；统一 Builder 降低类型检查中的重载歧义处理。 | 工具链迁移时与整个应用有关，但不会重新排列页面。应审查源码兼容性并构建，避免批量替换所有 Builder 或 State 声明。 |

参考链接：

- https://developer.apple.com/documentation/swiftui/document
- https://developer.apple.com/documentation/swiftui/documentwriter
- https://developer.apple.com/documentation/swiftui/documentcreationsource
- https://developer.apple.com/documentation/swiftui/dynamicviewcontent/reorderable()
- https://developer.apple.com/documentation/swiftui/view/reordercontainer(for:isenabled:move:)
- https://developer.apple.com/documentation/swiftui/reorderdifference
- https://developer.apple.com/documentation/swiftui/view/dragcontainer(for:in:_:)
- https://developer.apple.com/documentation/swiftui/view/swipeactionscontainer()
- https://developer.apple.com/documentation/swiftui/asyncimage/init(request:scale:)
- https://developer.apple.com/documentation/swiftui/view/asyncimageurlsession(_:)
- https://developer.apple.com/documentation/swiftui/state()
- https://developer.apple.com/documentation/swiftui/contentbuilder
- https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder

新的单集合重排序签名为：

```swift
nonisolated func reorderContainer<Item>(
    for item: Item.Type,
    isEnabled: Bool = true,
    move: @escaping (
        ReorderDifference<Item.ID, ReorderableSingleCollectionIdentifier>
    ) -> ()
) -> some View where Item: Identifiable, Item.ID: Sendable
```

当前 `dragContainer` 的 payload 闭包接收**项目 ID 数组**。WWDC 视频中的旧示例使用单个 ID 形式，因此复制到当前代码前应检查 SDK 签名。

TN3211 迁移检查应与运行时布局检查分开：在 State 赋值前初始化普通存储属性；初始化器提供初始状态时省略内联 State 默认值；显式解决 `Color`／`Text` 名称冲突；存在歧义的 `background`／`overlay` 优先使用 Builder 闭包形式；避免不必要地命名具体 Builder 结果类型。即使目标部署版本较早，升级 SDK 也可能暴露这些编译问题。

## 视频与参考文档的差异

使用实际构建 SDK 中的声明。原稿核验的工具栏参考资料使用 `toolbarMinimizationBehavior`，较早 WWDC26 示例讲解使用 `toolbarMinimizeBehavior`。垂直工具栏使用 `toolbarVerticalCompressionBehavior`。参考说明与 Tech Talk 对保留区域默认行为的描述不同，因此本项目显式请求 `.includeInactive`，并用 `.isActive` 筛选生效数量。SwiftUI 通常为 RTL 镜像保留区域几何；只有配套手动坐标处理时才使用 `.fixed`。

## 局部几何、圆角与侧边栏补充

这些布局主题均已有可运行 API 实验室示例：`LayoutAPIDemo` 处理重新布局和 SwiftUI 圆角，`UIKitAPIDemo` 演示安全区域及 UIKit 圆角，`TabAPIDemo` 提供侧边栏偏好。以下片段解释各 API 契约；完整状态、可用性检查和交互见对应源码。在选择具体产品迁移方案前，工作区保留现有集成。

| API／设置 | 可用性与集成 | 可见效果 |
| --- | --- | --- |
| `GeometryReader`、局部 Environment／Trait、`view.bounds` | 使用当前容器尺寸，避免依赖全局屏幕尺寸。UIKit 渲染比例优先用 `traitCollection.displayScale`。资源需要屏幕时，动态解析 `view.window?.windowScene?.screen`。 | 内容和渲染资源跟随所在窗口。 |
| `UIScreen.main` | 原稿核验的 Apple 文档标明其在 iOS 26 中弃用。移除主屏幕假设，不缓存替代屏幕用于布局。 | 避免屏幕选择歧义。 |
| `ConcentricRectangle`、`UICornerConfiguration` | iOS 26。为旧系统添加可用性检查和兼容圆角形状回退。 | 曲线随容器几何调整。 |
| `.tabViewStyle(.sidebarAdaptable)`／`.defaultTabBarPlacement(.sidebar)` | 样式从 iOS 18 提供，位置偏好从 iOS 27 提供。保留导航目标和选择。 | 在受支持环境中提供更丰富的侧边栏导航。 |
| `UITabBarController.mode = .tabSidebar`／`sidebar.preferredPlacement = .sidebar` | 模式从 iOS 18 提供，位置偏好从 iOS 27 提供。 | UIKit 对应的侧边栏偏好。 |
| `safeAreaInsets`、`safeAreaLayoutGuide` | 独立读取每侧边缘。手动布局使用 `view.bounds.inset(by: view.safeAreaInsets)`，或使用适当安全区域约束。 | 前景避开不对称系统控件和硬件区域。 |

在 UIKit 视图或视图控制器中，用局部 Trait 替换全局比例查询：

```swift
// 修改前
let screenScale = UIScreen.main.scale

// 修改后
let screenScale = traitCollection.displayScale
```

这两个声明是替代关系，不能作为同一代码块粘贴到共享作用域。如果操作确实需要 `UIScreen`，在需要时从已连接的窗口解析：

```swift
// 在 UIViewController 内
if let screen = view.window?.windowScene?.screen {
    // 使用此屏幕执行与该显示屏相关的操作。
}
```

不要用屏幕 bounds 替代当前视图的布局 bounds。在 SwiftUI 中读取局部 Environment 和建议几何信息，避免假定只有一块显示屏或固定设备宽度。

手动 UIKit 布局应避免减去 `safeAreaInsets.left * 2`，另一侧可能不同：

```swift
let foregroundBounds = view.bounds.inset(by: view.safeAreaInsets)
foregroundView.frame = foregroundBounds
backgroundView.frame = view.bounds
```

这些语句应放在所属视图控制器的布局阶段。如果 Auto Layout 管理前景 frame，则改用 `safeAreaLayoutGuide` 约束。布局边距也需要独立处理各侧边缘。

```swift
// SwiftUI：装饰性背景（iOS 26+）
ConcentricRectangle()
    .fill(Color.green)
    .padding(8)
    .ignoresSafeArea()

// UIKit：视图配置（iOS 26+）
myView.cornerConfiguration = .corners(
    radius: .containerConcentric()
)
```

`myView` 是应用自己的 UIView。片段需要对应框架导入、适当的外围上下文和可用性检查。圆角几何不会使可交互内容避开遮挡。

全屏配置不会阻止展开／闭合引起的尺寸变化。Apple 在 04:43 的 `UIRequiresFullScreen` 章节介绍遵循方向设置、按比例缩放的内屏呈现；应将该兼容性上下文与一般自适应布局指导区分开。重新评估局部几何、安全区域和边距，并测试 Split View 两侧、旋转、大字号、键盘及 RTL。

第 15 页专门介绍 Xcode 27.1 的 App Resizability，第 16 页覆盖迁移和性能检查。附带截图展示全应用审查提示词，以及 `UIScreen.main.scale` → `traitCollection.displayScale` 的具体替换。可使用提示词“让我的应用遵循所有窗口大小调整最佳实践”，审阅生成的 diff，再构建两条 SDK 路径并测试状态、辅助功能和过渡。该 skill 辅助 Coding Agent 编辑源码，不是自动修复所有页面的运行时 modifier。此处未在本项目执行该 skill。

## 工具栏容器、语义操作与自定义内容

17 页演示文稿的第 11 页介绍原生工具栏操作，第 12 页介绍优先级／溢出菜单／压缩，第 13 页介绍自定义控件。`ToolbarAPIDemo.swift` 通过可执行操作实现最初清单中的全部七项工具栏策略 API；`UIKitToolbarAPIDemo.swift` 实现 UIKit 对应的优先级、溢出菜单、轴向、压缩和边缘信息。工具栏隐藏时边缘偏好也可能存在；SwiftUI 的 `nil` 表示当前环境不使用垂直工具栏，UIKit 使用 `.unspecified`。

| 集成位置 | SwiftUI | UIKit | 契约与可用性 |
| --- | --- | --- | --- |
| 系统管理的工具栏 | `NavigationStack` 配合 `.toolbar` 和 `.bottomBar` 内容 | 视图控制器的 `toolbarItems`，由其 `UINavigationController` 呈现 | 现有容器 API 在适当 SDK／运行环境中获得系统适配。独立 `UIToolbar` 不提供相同垂直行为。 |
| 具有语义的关闭／取消 | `ToolbarItem(placement: .cancellationAction)` | `navigationItem.leadingItemGroups` | 保留操作含义，不硬编码屏幕坐标。UIKit 项分组从 iOS 16 提供。 |
| 醒目的固定操作 | `ToolbarItem(placement: .topBarPinnedTrailing)` | `navigationItem.pinnedTrailingGroup` | SwiftUI 位置从 iOS 27 提供，UIKit 属性从 iOS 16 提供。固定位置不同于溢出可见性优先级。 |
| 自定义项参与轴向 | `.axisBehavior(.verticalPreferred)` | 在导航容器内配置受支持的 Bar Button 内容 | SwiftUI modifier 从 iOS 27.1 beta 提供。偏好不是旋转任意自定义视图的指令。 |
| 首选垂直边缘 | `@Environment(\.toolbarVerticalEdge)` | `traitCollection.verticalBarEdge` | 均为 iOS 27.1 beta。SwiftUI 类型为 `HorizontalEdge?`，UIKit 为 `UIVerticalBarEdge`。无可见垂直栏时也可描述偏好。不支持时 `nil`／`.unspecified` 属正常情况。 |

从系统容器和带标签操作开始：

```swift
NavigationStack {
    WorkspaceView()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("检查", systemImage: "checkmark.seal") {
                    showReview = true
                }
            }
        }
}
```

此处 `WorkspaceView` 是应用内容视图，`showReview` 是外围视图持有的状态。应用该模式时保留现有呈现入口。不要仅为获得工具栏，就在已有导航层级外再嵌套一个 `NavigationStack`。

```swift
// 在由 UINavigationController 承载的当前 UIViewController 中：
toolbarItems = [reviewItem]
navigationController?.setToolbarHidden(false, animated: false)
```

`reviewItem` 是应用配置的 `UIBarButtonItem`，带有明确的标题、图像和操作。在 `navigationItem` 上配置分组，以表达 leading 和 pinned-trailing 操作语义，不用手工构建的浮动控件区域替代。

对于自定义内容，在符合条件的环境中选择紧凑视觉样式，同时保留语义标签：

```swift
@available(iOS 27.1, *)
struct ReviewActionLabel: View {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge

    var body: some View {
        if verticalEdge != nil {
            Label("检查", systemImage: "checkmark.seal")
                .labelStyle(.iconOnly)
        } else {
            Label("检查", systemImage: "checkmark.seal")
                .labelStyle(.titleAndIcon)
        }
    }
}
```

将此标签放入受支持 `ToolbarItem` 的按钮中，再对该项应用 `.axisBehavior(.verticalPreferred)`。Environment 读取可位于页面内容或工具栏项的自定义视图内。提供合适的 import、构建期 SDK 边界和运行时可用性检查；旧系统保留现有带标签按钮。

设计紧凑样式时审查固定宽高假设。避免保留会挤压垂直工具栏的纯水平尺寸。即使可见样式只显示符号，也为辅助功能和溢出菜单保留标题。不支持某轴向的控件仍需可访问入口。

在普通和 Reduce Transparency 背景下测试可读性。垂直工具栏默认没有 Scroll Edge Effect；Reduce Transparency 会增加背景。Flexible Spacer 在垂直轴向尺寸为零，Fixed Spacer 保留最小尺寸。添加自定义间距前先让系统间距发挥作用。在原生工具栏会话中验证两侧首选边缘、大字号、VoiceOver、溢出菜单、紧凑尺寸及状态连续性。当前编译和现有测试已通过，但这些完整场景尚未全部验证。

## 优先级、溢出菜单与压缩：第 12 页

附带截图区分三种不能混淆的决策：优先级决定操作何时进入溢出菜单；显式溢出菜单容纳次要操作；压缩决定标签栏还是工具栏项先让出垂直空间。

| 决策 | SwiftUI | UIKit | 可用性与行为 |
| --- | --- | --- | --- |
| 优先保留某操作 | `ToolbarContent.visibilityPriority(_:)` | `UIBarButtonItem.visibilityPriority` | 均为 iOS 27。高优先级相对低优先级内容延后溢出，不保证可见或固定位置。 |
| 始终在系统溢出菜单中提供次要操作 | `ToolbarOverflowMenu` | `UINavigationItem.additionalOverflowItems` | SwiftUI 从 iOS 27 提供，UIKit 属性从 iOS 16 提供。UIKit 值为 `UIDeferredMenuElement?`，不是普通操作数组。 |
| 优先保留工具栏项，再保留标签栏 | `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` | `navigationItem.verticalBarCompressionBehavior = .prefersBarItems` | 均为 iOS 27.1 beta。标签栏先压缩；`.automatic` 优先保留标签栏。该偏好用于共享的垂直呈现。 |

```swift
// 现有导航容器中的内容，需要 iOS 27.1 或更高版本。
WorkspaceView()
    .toolbar {
        ToolbarItem(placement: .primaryAction) {
            Button("检查", systemImage: "checkmark.seal") {
                showReview = true
            }
        }
        .visibilityPriority(.high)

        ToolbarOverflowMenu {
            Button("导出", systemImage: "square.and.arrow.up") {
                exportRecords()
            }
        }
    }
    .toolbarVerticalCompressionBehavior(.prefersToolbarItems)
```

`WorkspaceView`、`showReview` 和 `exportRecords()` 是说明片段中的占位名称，并非工作区的准确源码。完整实现见 `NativeToolbarRecords`：检查更新计数，添加改变本地记录数，反转顺序改变排列，摘要打开当前值。保留旧系统分支及构建期 SDK 边界。避免在系统溢出菜单旁再加通用省略号菜单；只有目的和符号均有明确意义时，才保留独立业务菜单。

UIKit 应使用 `UIDeferredMenuElement` 提供者填充 `additionalOverflowItems`，通过 completion 返回菜单元素。其 `init(_:)` 从 iOS 14 提供并缓存结果；需要重新生成菜单内容时使用 `.uncached(_:)`。工具栏压缩时仍保持操作可访问，并验证溢出菜单和 VoiceOver 标签。

### 优先级与溢出菜单参考资料

- https://developer.apple.com/documentation/swiftui/toolbarcontent/visibilitypriority(_:)
- https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu
- https://developer.apple.com/documentation/swiftui/view/toolbarverticalcompressionbehavior(_:)
- https://developer.apple.com/documentation/uikit/uibarbuttonitem/visibilitypriority
- https://developer.apple.com/documentation/uikit/uinavigationitem/additionaloverflowitems
- https://developer.apple.com/documentation/uikit/uinavigationitem/verticalbarcompressionbehavior

## 现有应用迁移与性能：第 16 页

在现有状态归属边界实施修改。`RootView` 已管理标签页、分类和呈现状态；改变容器或组合方式时保留该归属。使用稳定模型 ID，避免每次几何变化都替换整个层级。将请求和高开销派生数据计算移出 `body`。本示例应在每次过渡前后验证筛选记录、分类和呈现方式。这些属于集成检查，不是本版本新增运行时实现。

两张内容重叠的手机截图提供一般性能建议。应将其作为调查线索，技术依据来自 Apple 原始材料。[WWDC26 功耗与性能集体研讨](https://developer.apple.com/videos/play/wwdc2026/8003/) 建议测量实际瓶颈、检查不必要更新，并使用真实数据和条件。不能从布局正确或流畅的 Simulator 截图推断性能提升。

使用 [SwiftUI Instruments 工作流程](https://developer.apple.com/videos/play/wwdc2025/306/) 检查耗时的 View Body 更新和重复失效。沿 Cause & Effect Graph 查找触发工作的状态或依赖，再在 Time Profiler 中检查所选时间区间。针对一项修改，比较等价的窗口调整、旋转、滚动和 Sheet 流程。保留 Trace，并记录设备、构建、数据规模和辅助功能设置。

并发需要明确设计：将同步 CPU 密集代码包装在 `Task {}` 中，不会自动使其脱离 Main Actor。在适当隔离边界后执行高开销处理，安全传递数据，并在所属 Actor 发布 UI 变化。SwiftData 模型和 Context 必须保持隔离，不要随意传给 Detached Task。参见 [探索 SwiftUI 并发](https://developer.apple.com/videos/play/wwdc2025/266/)。

App Resizability 可辅助审查固定尺寸、容器用法、安全区域假设和自定义工具栏内容。审阅建议修改，构建基础与原生路径，再测试过渡、辅助功能、状态连续性和响应性。当前原生构建及上述测试已完成；此处未执行随附 skill、采集 Instruments Trace，或完成全部真机行为验证。演示文稿仍使用原有参考截图。

### 工具栏参考资料

- https://developer.apple.com/videos/play/tech-talks/111462/
- https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge
- https://developer.apple.com/documentation/swiftui/toolbarcontent/axisbehavior(_:)
- https://developer.apple.com/documentation/swiftui/toolbaritemplacement/topbarpinnedtrailing
- https://developer.apple.com/documentation/uikit/uitraitcollection/verticalbaredge
- https://developer.apple.com/documentation/uikit/uinavigationitem/leadingitemgroups
- https://developer.apple.com/documentation/uikit/uinavigationitem/pinnedtrailinggroup

### Apple 参考资料

- https://developer.apple.com/documentation/swiftui/concentricrectangle
- https://developer.apple.com/documentation/uikit/uicornerconfiguration-swift.struct
- https://developer.apple.com/documentation/swiftui/view/defaulttabbarplacement(_:)
- https://developer.apple.com/documentation/uikit/uitabbarcontroller/sidebar-swift.class/preferredplacement
- https://developer.apple.com/documentation/uikit/uiscreen/main
- https://developer.apple.com/videos/play/tech-talks/111461/
