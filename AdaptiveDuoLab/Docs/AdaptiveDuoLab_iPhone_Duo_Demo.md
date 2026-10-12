# AdaptiveDuoLab iPhone Duo 技术分享

**修订日期：** 2026 年 10 月 12 日（原稿：2026 年 9 月 26 日）

**演示文稿：** AdaptiveDuoLab_iPhone_Duo_Demo.pptx，共 17 页，介绍现有应用的适配

## 分享结构

| 页码 | API／功能 | 可见效果与代码状态 |
| --- | --- | --- |
| 1 | 开场介绍 | **iPhone Duo 自适应布局**：使用 SwiftUI 和 UIKit 适配现有应用。主讲人 Somendra。目标是在保留状态的同时实现自适应 UI。 |
| 2 | iPhone Duo 自适应布局 | 使用项目较早的紧凑布局截图说明目标：让同一个应用适应变化的空间并保留状态。 |
| 3 | `GeometryReader`、`horizontalSizeClass`、`AnyLayout` | 重新布局示例根据局部宽度和文字大小切换同一个 `AnyLayout`，同时保留编辑状态。标签页示例读取当前 Size Class。不要根据硬件名称推断布局。 |
| 4 | `TabView`、`Tab`、侧边栏偏好 | 应用保留三个原生标签页。独立标签页示例实现 `.sidebarAdaptable` 及适用的默认位置 modifier，并保留共享笔记和稳定选择。 |
| 5 | `NavigationSplitView` | 导航列折叠或展开时，保持同一层级和稳定的分类选择。项目较早的宽布局截图用于说明内容，不代表新的原生运行验证。 |
| 6 | `ignoresSafeArea`、`safeAreaInsets`、`safeAreaLayoutGuide` | 扩展背景并保护前景控件。独立读取每侧边距，测试 Split View 两侧位置。 |
| 7 | `ViewThatFits`、`fixedSize` | 提供清晰可读的适配备选布局。项目截图裁剪展示修复前的问题；此页未替换为当前顶部区域和文本实现的运行截图。 |
| 8 | `ArrangementView`、`.split` | API 实验室通过比例偏好排列实际记录和摘要。叠层示例适配前景控件并筛选实际记录。工作区仍使用独立的组合方式。 |
| 9 | `reservedRegions`、`.division`、`.occlusion`、`isActive` | 自定义控件示例测量检查按钮并避开生效区域边框。按钮无法放下时，原生工具栏提供回退入口。空结果和未生效结果均有效。 |
| 10 | `ConcentricRectangle`、`UICornerConfiguration` | SwiftUI 和 UIKit 交互示例可调整内边距，并比较同心圆角与固定圆角。旧系统路径仍可使用；圆角匹配不能代替安全区域处理。 |
| 11 | 原生工具栏操作 | 工具栏示例使用导航容器，并提供可操作的关闭按钮和其他操作。API 指南列出准确源码位置及各框架的覆盖范围。 |
| 12 | 优先级、溢出菜单和压缩 | `visibilityPriority` 影响溢出顺序；`ToolbarOverflowMenu` 容纳次要操作；`.prefersToolbarItems` 优先压缩标签栏。附带的垂直工具栏截图用于说明溢出菜单控件。 |
| 13 | `toolbarVerticalEdge`、`.axisBehavior(.verticalPreferred)` | 自定义检查控件在支持垂直工具栏的环境中适配。即使工具栏隐藏，边缘偏好仍可能存在，不能据此判断可见性。 |
| 14 | `.sheet`、`NavigationStack`、`presentationDetents` | PresentationAPIDemo 实现带 Detent 的可编辑 Sheet，以及 Popover、Alert 和菜单。父视图管理草稿与操作结果。 |
| 15 | Xcode 27.1 中的 App Resizability | 使用工作流程截图说明全应用审查、局部 Trait 替换，以及审阅／构建／测试检查。此处未在本项目中执行该 skill。 |
| 16 | 现有应用迁移与性能 | 审查、选择针对性的 API、保留状态、限定 SDK 使用并分析过渡性能。App Resizability 辅助修改源代码，开发者负责审阅和验证。 |
| 17 | 致谢 | 以 Somendra 和保持统一应用体验的主题结束。 |

演示文稿保持主线简洁，将格式化的 Swift 代码与相关 UI 配对，并以致谢结束。不另设参考资料或附录页；来源链接和较长技术细节保留在演讲者备注及这些指南中。备注标明应用自定义的辅助类型和省略的上下文。本版本在同一应用中加入可执行示例，并同步实现状态。源代码存在、SDK 编译成功与实际设备行为属于不同证据层级。当前中文版本已通过 Xcode 27.1 构建、18 项单元测试和 7 项 UI 测试，完整硬件验证仍待执行。

设计指导遵循 Apple 的 *Design for iPhone Duo*：保留同一层级和相同功能，使用实际窗口 Trait 与安全区域，让系统组件提供受支持的适配。外屏 Compact、内屏 Regular 是有用的设计描述，不能作为识别硬件的规则。多任务和固定的 Picture in Picture 可改变应用的可用空间。

Xcode 27.1 中的 Apple **App Resizability** 由应用现代化 skill 更名而来，支持 SwiftUI 和 Duo。它辅助 Coding Agent 修改源码。系统容器适配自身 UI；开发者仍需决定自定义内容如何适配及状态如何保留。没有一个运行时 modifier 能修复整个应用。

## 现有项目的实现

工作区、检查和设置共享偏好与一个 SwiftData 容器。`RootView` 在原生容器上层管理所选标签页、分类、呈现方式和预览姿态。iOS 18+ 使用原生 `Tab`，iOS 17 使用 `tabItem`。工作区使用同一个 `NavigationSplitView`，不会为不同尺寸切换独立导航层级。

顶部区域选择适合空间的备选布局。卡片显示完整标题和摘要，元数据可堆叠。背景渐变忽略安全区域，但可交互前景不应用该 modifier。辅助功能字号下，集合使用单列。窗口较矮或字号较大时，控件可移入紧凑菜单。受限的书本折叠／桌面模式预览会回退布局，同时保留所选预设。

**设置 → 打开 API 实验室**提供 **8 个交互示例和 25 项 API 条目**，涵盖重新布局／圆角、SwiftUI 和 UIKit 工具栏、标签页／侧边栏、UIKit 导航、呈现方式、相机和系统布局。系统布局示例使用当前筛选记录。原生 Split／Overlay、生效区域避让及只读铰链诊断均已实现源码。每条记录均可访问，摘要也有额外入口。工作区姿态仍为模拟；实验室没有替换工作区的每个页面。

检查操作显示为**布局检查**，提供本地配置检查。它不会测量每个页面，也不是云端 AI 服务。已有记录会保留；未被用户修改的旧版内置英文记录会自动转换为中文，同时保留 ID、进度和时间。

## 示例集成与现存边界

- **自适应网格：** 采用随字号缩放的可读宽度偏好时，保留显式列表／网格／自动选项，并检查小于首选卡片宽度的容器。较长的网格示例保留为指南内容，不单独占用幻灯片。`AdaptiveLayoutPolicy` 当前使用 620 pt 自动网格阈值，以及 560、820、1100 pt 列数阈值。这些是示例内容规则，并非 Apple 显示断点。书本折叠／桌面模式仍由 `DemoPose` 和内容空间检查驱动。
- **AnyLayout：** 第 3 页对应 `LayoutAPIDemo`，其编辑器和摘要始终是同一个 `AnyLayout` 的子视图。640 pt 示例内容偏好、辅助功能字号和手动垂直偏好共同选择轴向。当前 Dashboard 仍有自己的策略；Size Class 本身不是完整布局算法。
- **安全区域：** 第 6 页对应现有渐变／前景分离，以及 `UIKitAPIDemo` 的局部约束。UIKit 示例可独立添加左侧或右侧测试边距，便于在普通手机上检查行为。
- **原生排列：** API 实验室已实现 Split、Overlay、比例偏好、区域查询和自定义控件避让。工作区尚未迁移到这些 API。Arrangement 表达内容关系，不替代导航或所有滚动内容流。
- **工具栏 API：** 第 11–13 页对应可执行的工具栏会话，操作会改变状态。策略在启动会话前选定，以保持垂直工具栏偏好稳定。`toolbarVerticalEdge` 在工具栏隐藏时仍表示首选边缘；`nil` 表示当前环境不使用垂直工具栏。具体 SwiftUI／UIKit 覆盖范围与回退路径见 API 指南。
- **Sheet：** `PresentationAPIDemo` 提供带 medium／large Detent 的草稿编辑器，以及 Popover、Alert 和菜单。布局检查保留现有入口。自定义区域避让需要应用显式处理；连续滚动内容不必绕开折叠处。

铰链读数仅用于诊断，不通过角度阈值选择布局。无事件、无铰链和空区域结果均属正常。`CameraAPIDemo` 提供真实的、由用户主动启动的后置相机预览和共享演讲提示；仅在系统报告可用时提供原生相机附属显示。未配置麦克风、录制、照片输出或通用外接显示屏播放。

## Mac 操作流程

基础版本需要 Xcode 26+，以编译现有 `glassEffect` 符号。最低部署版本保持 iOS 17。当前项目默认启用 `DUO_SDK`，原生示例需要 Xcode 27.1／iOS 27.1 SDK；构建基础版本前需移除此编译条件。

以下保留原演示包的命令；当前仓库未包含 `Automation/` 脚本，请直接在 Xcode 中运行和测试：

```bash
open AdaptiveDuoLab.xcworkspace
./Automation/run-demo.sh -demo-tab Settings
./Automation/run-tests.sh

DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-demo.sh -demo-tab Settings
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-tests.sh
```

1. 在设置中选择研究、列表和书本折叠。确认各标签页中的值一致，且均显示两条记录。
2. 调整工作区大小并增大 Dynamic Type。分别说明其现有策略与 API 实验室重新布局示例，不要将工作区行为归因于未使用的 API。
3. 打开布局检查，区分配置指导与实测几何信息。
4. 打开 API 实验室，检查某个 API 的状态，然后进入**系统布局与区域**。
5. 使用原生构建，通过 Device Hub 调整大小。检查区域及铰链事件文本，打开叠层排列并使用移动自定义控件。内容无法放下时，展示额外的检查／摘要入口。
6. 在普通 iPhone 上重复操作。分隔区域结果为空、没有铰链信息均有效。
7. 使用第 4 页说明原生标签页。应用姿态菜单模拟内容布局，不会重新定位原生工具栏。
8. 使用第 3 页说明局部几何信息和 Trait 决策，第 5 页说明同一应用中的导航列。多任务下读取实际 Trait，并检查调整大小时的选择连续性。
9. 打开第 11–13 页对应的工具栏会话。检查可执行操作、溢出菜单、VoiceOver 标签、紧凑尺寸、两侧垂直边缘和 Reduce Transparency。分别在基础和原生构建路径中重复验证。
10. 使用第 16 页说明迁移清单。采集真实过渡 Trace，比较每项修改前后的状态、请求和响应性。

## 证据与待完成工作

当前源码包含 **18 项单元测试**（10 项布局策略、7 项保留区域放置、1 项旧示例数据中文转换兼容测试）和 **7 项 UI 测试**。2026 年 10 月 12 日已在 Xcode 27.1／iPhone Duo（iOS 27.1）Simulator 上通过编译及上述全部测试。此处未执行 Apple 随附 skill。关闭 `DUO_SDK` 的基础构建、旧系统及完整真机验证仍待执行。源码审查和几何测试不能证明原生工具栏移动、相机附属显示可用性或物理折叠过渡。

截图的含义需要明确。第 2、5 页使用项目较早的紧凑和宽布局截图。第 7 页使用旧版拥挤控件的裁剪图，展示修复前问题。它们不代表最新编译的原生版本或新增示例。Apple 参考 UI 用于说明系统行为，与项目运行证据不同。API 实验室显式允许两个分割轴向。工具栏、相机和区域避让仍需按实际设备能力补齐运行验证与截图。

演讲者备注记录了视觉来源和时间戳。原稿所核验的 27.1 参考资料处于 beta 阶段；API 采用指南记录参考 API 名称与早期视频示例的差异。截图本身不能确立 SDK 版本、API 采用情况、硬件状态、过渡成功或测试结果。

API 清单见 [API 采用指南](API_Adoption_Guide.md)；skill、导出及整个项目的提示词见 [Apple App Resizability 工作流程](Apple_App_Resizability_Workflow.md)。应验证大字号、VoiceOver、RTL、键盘与呈现变化、窗口调整及状态连续性。需要区分现有和新增 API：`AnyLayout` 与 `ViewThatFits` 从 iOS 16 提供；`LazyVGrid` 与 `ScaledMetric` 从 iOS 14 提供；`dynamicTypeSize` 环境值需要 iOS 15。现有 API 可在适当系统环境中提供新的设备行为。

## 资料来源

- [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466/)：设计原则、安全区域、内外屏布局、Sheet 和折叠处避让。
- [Prepare your app，App Resizability 位于 09:12](https://developer.apple.com/videos/play/tech-talks/111461/?time=552)
- [Raise the bar with iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111462/)
- [Strike a pose with adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Multiple displays and scenes](https://developer.apple.com/videos/play/tech-talks/111464/)
- [What's new in SwiftUI，WWDC26](https://developer.apple.com/videos/play/wwdc2026/269/)
- [Modernize your UIKit app，WWDC26](https://developer.apple.com/videos/play/wwdc2026/278/)
- [State 与 ContentBuilder 迁移，TN3211](https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder)

## 其他适配细节

第 3、4、6、10 页覆盖局部几何信息、标签页容器、安全区域和圆角。每项均有 API 实验室实现，指南另行标明哪些 API 也用于工作区。UIKit 布局、圆角和分栏导航示例通过 SwiftUI Controller Host 执行；其他 UIKit API 对应关系与源码覆盖情况分别记录。

将 `UIRequiresFullScreen` 和支持方向设置与布局逻辑区分开。视频 04:43 的 `UIRequiresFullScreen` 章节描述遵循方向设置、按比例缩放的内屏呈现，包括 Split View；附带截图明确标注了此上下文。这是限定范围的兼容性指导，并非通用内屏方向规则。展开和闭合仍会改变应用尺寸。读取当前 bounds 和 Trait，并使用目标 SDK 验证配置行为。

侧边栏偏好需要自适应标签栏样式。保留现有所选标签页状态。同心几何调整的是形状，不会避让折叠处、相机或工具栏。仍需遵循安全区域并使用适当的容器布局。

## 工具栏采用细节

第 11–13 页覆盖工具栏容器、操作和自定义内容。在 SwiftUI 中，将 `.toolbar` 附加到导航容器内的内容上，按操作角色使用 `.bottomBar`、`.cancellationAction`、`.topBarPinnedTrailing` 等语义位置。在 UIKit 中配置视图控制器的 `toolbarItems`，通过 `setToolbarHidden(false, animated:)` 显示导航控制器的工具栏。由系统导航容器负责管理；单独创建的 `UIToolbar` 不具备相同的垂直适配行为。

源码直接演示这些角色：SwiftUI 置顶操作使用 `.topBarPinnedTrailing`；UIKit 的关闭、检查／排序和置顶操作分别使用 leading、trailing 和 pinned-trailing 分组，添加／摘要则是受管理的底部工具栏项。UIKit 溢出菜单使用 `additionalOverflowItems` 和延迟菜单提供者。准确的八个示例名称及源文件见 API 指南。

为操作同时提供标题和符号。紧凑视觉样式可隐藏标题，但应为辅助功能和溢出菜单保留语义标签。关闭／取消操作应使用语义位置，不应使用手动定位的角落按钮。固定位置与可见性优先级不同；应保留正常导航，有选择地使用固定位置。

`toolbarVerticalEdge` 是支持垂直工具栏环境中的可选首选 `HorizontalEdge`，即使当前垂直工具栏不可见也可能存在。`nil` 表示当前环境不使用垂直工具栏。UIKit 对应的 `traitCollection.verticalBarEdge` 返回 `UIVerticalBarEdge`，不支持垂直工具栏时为 `.unspecified`。两者均不能用于检测可见性。对于合适的自定义工具栏项，使用 `.axisBehavior(.verticalPreferred)` 允许参与垂直布局，再按需选择紧凑标签并调整固定宽高假设。较宽控件可保持水平，同时提供适当的可访问入口。

检查普通和 Reduce Transparency 背景下的自定义内容。Flexible Spacer 在垂直轴向尺寸为零，Fixed Spacer 保留最小尺寸。避免添加与系统布局冲突的手动间距。当前代码已通过上述构建和测试，但本演示文稿中的既有截图未替换为最新运行截图。

## 七份新增附件的说明

以下五个截图时间均指 2026 年 9 月 26 日。这些图片为代码和指导提供依据；并非每份附件都作为完整图片出现在幻灯片上。

| 附件 | 提供的内容 | 使用位置 |
| --- | --- | --- |
| 上午 09:50:15 的截图 | SwiftUI 和 UIKit 可见性优先级 | 第 12 页及 API 指南：高优先级延后溢出，不保证可见。两个 API 均从 iOS 27 提供。 |
| 上午 09:51:17 的截图 | SwiftUI 和 UIKit 垂直压缩偏好 | 第 12 页：`.prefersToolbarItems`／`.prefersBarItems` 优先压缩标签栏。这些偏好属于 iOS 27.1 beta。 |
| 上午 09:53:51 的截图 | `ToolbarOverflowMenu` 和 UIKit `additionalOverflowItems` | 第 12 页及指南：显式次要操作保留在系统溢出菜单中。SwiftUI 从 iOS 27 提供，UIKit 属性从 iOS 16 提供。 |
| 上午 09:55:11 的截图 | 垂直工具栏中可见的溢出菜单控件 | 第 12 页 UI 示例，与可编辑代码配对，不作为项目已集成的证据。 |
| 上午 09:58:13 的截图 | 审查、构建、自定义项和溢出菜单检查 | 第 16 页迁移清单；完整实现细节保留在指南中。 |
| `IMG_5133.PNG` | 关于自适应几何、低成本更新、状态和真实过渡的第三方建议 | 第 16 页性能／状态指导，已与下方 Apple 视频核对。 |
| `IMG_5134.PNG` | 同一性能建议的重叠续篇 | 与上一张图合并，避免重复内容。演示文稿无需包含作者姓名或社交信息流界面元素。 |

稍后的 App Resizability 截图保存在 `Docs/Screenshots/06_app_resizability.png`，对应独立的第 15 页。它展示提示词“让我的应用遵循所有窗口大小调整最佳实践”，以及将 `UIScreen.main.scale` 替换为 `traitCollection.displayScale` 的示例。说明审查 → 审阅 diff → 构建 → 测试的流程，不将截图视为该 skill 已在本项目运行的证据。

## 第 16 页的性能与状态检查

布局变化时保持选择状态和模型归属稳定，不从 `body` 发起请求或执行高开销处理。调整尺寸应重新排列同一体验，避免重复工作。示例在各自状态持有者的生命周期内保留状态，但此处未测得性能提升。

分析真实的窗口调整、旋转、标签页和 Sheet 过渡。使用 SwiftUI Instrument 定位高开销或重复更新，通过 Cause & Effect Graph 追踪依赖，再用 Time Profiler 检查 CPU 工作。完成针对性修改后，比较等价运行。参见 [Optimize SwiftUI performance with Instruments](https://developer.apple.com/videos/play/wwdc2025/306/) 和 [Power and Performance Group Lab](https://developer.apple.com/videos/play/wwdc2026/8003/)。

`Task {}` 创建异步工作，但本身不会将 CPU 密集工作移出 Main Actor。以明确的隔离和安全的数据传递分离高开销非 UI 处理，再在所属 Actor 上发布 UI 状态。参见 [Explore concurrency in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/266/)。不能仅凭这些截图声称性能已提升或运行验证已完成。
