# AdaptiveDuoLab

基于 SwiftUI 和 SwiftData 的演示应用，包含原生的**工作区**、**检查**和**设置**标签页。同一应用中还提供布局、原生工具栏、标签页、呈现方式、UIKit 和相机附属显示等交互式 API 示例。

## 打开项目

解压 ZIP，打开随附的 workspace，并选择 `AdaptiveDuoLab` scheme：

```bash
cd /path/to/AdaptiveDuoLab
open AdaptiveDuoLab.xcworkspace
```

随附的 Xcode 项目已引用新增文件。使用 Tuist 重新生成项目时，也会通过 `Sources/**` 包含这些文件。当前项目默认启用 `DUO_SDK`，原生 Duo 示例需要 **Xcode 27.1 和 iOS 27.1 SDK**，并在 iOS 27.1 或更高版本上运行。

移除 `DUO_SDK` 后，可使用 **Xcode 26 或更高版本及 iOS 26 SDK**构建基础版本，因为现有面板使用了 `glassEffect`。最低部署版本仍为 iOS 17；较早系统通过 Material 和 `tabItem` 回退实现兼容。

## 已集成的功能

- `RootView` 管理原生标签页，以及所选标签页、分类、内容模式和预览姿态。iOS 18+ 分支使用 `Tab`；iOS 17 回退分支使用 `tabItem` 和稳定的 tag。
- 工作区保留 `NavigationSplitView` 和内容面板。检查页面与模态 Sheet 复用相同的本地检查内容。设置页面会更改实际共享的分类、模式和姿态。
- `AdaptiveDuoLabApp` 在所有导航目标上层保留一个 SwiftData 容器，没有为每个标签页创建独立数据库或重新填充示例数据。
- 布局检查仍通过带有“完成”按钮的模态页面打开。标签页用于选择导航目标；检查操作用于打开 Sheet。
- 顶部区域会在需要时堆叠标题、操作和控件。三个模式按钮无法横向放下时，使用原生布局菜单替代。
- 内容高度低于 520 pt，或文字大小达到 XXX Large 及以上时，使用紧凑的原生工具栏控件替代较高的顶部区域，为记录集合保留滚动空间。
- 模拟书本布局要求每个区域内的卡片宽度至少为 280 pt。局部详情区域更窄时，使用包含全部筛选记录的单一集合。这是示例的内容适配规则，并非 Apple 定义的断点。
- 生成项目的部署设置现已与 manifest 一致，均为 iOS 17。此前上传的生成版应用 target 曾要求 iOS 27。
- 设置页面可打开 **API 实验室**，其中包含 **8 个交互示例和 25 项 API 条目**，展示版本要求、源码位置、实现状态及在其他 iPhone 上的行为。
- 重新布局和圆角示例包含可编辑状态、`AnyLayout` 过渡、`ConcentricRectangle` 对比，以及具有独立安全区域边缘、`UICornerConfiguration` 和分栏导航的 UIKit 视图。
- 工具栏会话可测试溢出菜单、优先级、轴向偏好、最小化、压缩、首选边缘读取和垂直工具栏偏好。检查、置顶、添加和反转顺序操作会实际更改本地会话状态。
- 标签页和呈现方式示例会在导航目标或呈现几何信息变化时保留草稿。标签页示例可优先使用侧边栏；Sheet、Popover、Alert 和菜单控件均执行具体的本地操作。
- 相机示例仅在轻点**启动相机**后启动真实的后置相机预览。系统报告可用时，可选的 `CameraCaptureAccessory` 会共享可交互的演讲提示。示例未配置照片、音频、录制或保存输出。
- 系统布局示例使用所选分类中的实际记录。原生排列、保留区域和铰链行为，与工作区中明确标注为模拟的姿态预览相互独立。
- 在辅助功能字号下，工作区使用单列和单一连续区域。较矮的桌面模式窗口会回退为普通集合。卡片显示完整标题和摘要，元数据可采用堆叠布局。
- 界面说明和操作文字使用简体中文，专业术语及 API 名称保留英文。存储原始值、启动参数和自动化标识保持稳定；未被用户修改的旧版内置英文记录会自动转换为中文。

预览姿态影响内容的组合方式。原生容器由系统选择受支持的标签栏位置。姿态菜单不会强制显示垂直工具栏，也不能确定设备的实际物理姿态。

## 在 Mac 上运行和测试

以下保留原演示包的自动化脚本用法。当前仓库未包含 `Automation/` 目录；只有在演示包提供这些脚本时才能执行。当前检出版本可直接在 Xcode 中运行应用，并通过 **Product → Test** 执行测试。

脚本默认构建随附项目。设置 `DEVICE_ID` 可指定 Simulator，设置 `DEVICE_NAME` 可按名称匹配。设置 `REGENERATE_PROJECT=1` 后，会使用 PATH 中的 Tuist 重新生成项目。

```bash
./Automation/run-demo.sh -demo-tab Review -demo-presentation Grid
./Automation/run-tests.sh
```

使用匹配的 SDK 和已安装的 Simulator 启用原生示例：

```bash
DEVICE_ID="your-simulator-udid" ./Automation/run-api-demos.sh
```

此快捷命令会启用 `DUO_SDK` 并打开设置页面；共享启动脚本会检查 SDK。等效的显式命令和原生测试命令如下：

```bash
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-demo.sh -demo-tab Settings
DUO_SDK=1 DEVICE_ID="your-simulator-udid" ./Automation/run-tests.sh
```

安装多个 Xcode 时，请设置 `DEVELOPER_DIR`。原演示包中的脚本会在构建前检查 SDK 版本，并在启用原生示例时向 `SWIFT_ACTIVE_COMPILATION_CONDITIONS` 追加 `DUO_SDK`。当前项目已默认启用该标志；如需使用较早 SDK，请从对应配置的 **Active Compilation Conditions** 中移除它，并保留其他已有值。原生分支还会检查运行中的系统版本；仅启用此标志不会增加硬件能力。

启动参数保持英文原始值：

```text
-demo-tab Workspace|Review|Settings
-demo-pose "Current Window"|"Outer Portrait"|"Outer Landscape"|"Inner Open"|"Book Fold"|Tabletop
-demo-presentation Automatic|List|Grid
-show-audit
-ui-testing
-reset-data
```

包含空格的值需加引号。`-ui-testing` 使用内存存储；`-reset-data` 重置示例记录。

## 标签页操作流程

1. 在工作区选择网格。模式按钮无法直接显示时，打开布局菜单。
2. 打开检查页面，查看当前分类、模式、姿态和记录数。
3. 在设置中选择研究、列表和书本折叠。研究分类包含两条预置记录。
4. 返回检查页面和工作区，确认所选值保持不变。
5. 调整详情区域大小。在空间足以容纳两个可读区域之前，书本折叠使用单一集合。
6. 打开并关闭布局检查，然后再次切换标签页。
7. 在普通 iPhone 和目标 Duo 运行环境中执行此流程，包括辅助功能字号、VoiceOver 和从右到左的布局。

## API 实验室操作流程

1. 打开**设置 → 打开 API 实验室**。了解原生容器适配、应用布局决策和 Xcode skill 之间的区别。
2. 打开**重新布局与同心圆角**。编辑任务、更改完成数量并切换为垂直布局。调整窗口大小或增大字号。在 iOS 26+ 上调整内边距，比较同心圆角与固定圆角。
3. 打开 **UIKit 布局与导航**。比较**无**、**左侧 +44** 和**右侧 +44** 的安全区域测试边距。更改圆角内边距，然后选择**打开 UIKit 标签页与分栏导航**，一边调整窗口大小，一边编辑主题草稿。附加边距是显式控制的测试值。
4. 打开 **SwiftUI 工具栏操作**，选择偏好并启动会话。执行检查、置顶、反转顺序或添加记录，查看状态变化。原生设置需要 `DUO_SDK` 和 iOS 27.1。基础预览使用普通系统工具栏项，不会模拟新 API。同时打开 **UIKit 工具栏操作**，比较原生 UIKit 操作、溢出菜单、轴向／优先级／压缩设置及首选边缘信息。
5. 在**标签页与侧边栏**中选择偏好，然后选择**打开标签页示例**。编辑笔记、切换到摘要并调整窗口大小。更改位置偏好后，重新打开会话。受支持的位置由系统选择，示例不会人为绘制侧边工具栏。
6. 打开 **Sheet 与呈现方式**。编辑 Sheet 草稿、显示 Popover、显示 Alert 并使用操作菜单。确认父视图保留本地草稿和操作结果。
7. 在**相机附属显示**中，使用真机轻点**启动相机**并授予访问权限。尝试**下一条提示**。如果原生系统报告附属显示功能可用，启用**在附属显示屏上显示演讲提示**。没有附属显示能力时，主预览和控件仍可使用。缺少硬件或拒绝权限时会显示原因说明；示例不会模拟相机输出。
8. 打开**系统布局与区域**。在原生构建版本中，通过**系统布局详情 → 叠层排列**更改“仅显示已完成”筛选，或通过**移动自定义控件**让检查按钮避开生效区域。区域边框已包含交互边距，不会重复添加。如果没有合适的安全位置，请使用工具栏中的检查操作。基础版本显示连续列表。对于普通 iPhone，区域结果为空或没有铰链信息均属有效情况。
9. 选择 API 清单中的条目，查看准确的源码位置、可用条件和回退行为。这些示例位于本项目中，并不表示工作区的每个页面都已迁移到对应 API。

完整实现对应关系请参阅 [API 采用指南](Docs/API_Adoption_Guide.md)；面向整个项目的 Agent 提示词请参阅 [Apple App Resizability 工作流程](Docs/Apple_App_Resizability_Workflow.md)。

## 验证状态

2026 年 10 月 12 日，中文界面版本已使用 **Xcode 27.1** 在 **iPhone Duo（iOS 27.1）Simulator** 上通过编译和测试：

- **18 项单元测试通过**：10 项布局策略测试、7 项保留区域放置测试，以及 1 项旧示例数据中文转换兼容测试。
- **7 项 UI 测试通过，0 失败**：覆盖共享应用状态、API 实验室导航、旋转时保留编辑状态、工具栏会话重新打开后的状态，以及相机初始关闭状态。
- 中文转换兼容测试验证旧内置记录可转换为中文，并保留 ID、进度、时间及分类／状态原始值；用户编辑过的内容保持不变。

这些测试未覆盖所有原生 API 或真机相机能力。较早系统、关闭 `DUO_SDK` 的基础构建，以及完整的 VoiceOver 和从右到左布局验证，均未在本次测试中执行。

布局检查使用本地规则，没有接入实时 AIHubServices 客户端。API 实验室包含可执行示例，包括此前仅列于清单中的工具栏和相机 API。源码实现本身不能证明某个新 API 已成功编译或运行；以上验证结论以本次实际构建和测试覆盖范围为限。工作区的书本折叠／桌面模式区域仍为模拟内容，其内容面板未被实验室示例替换。根视图存在期间，共享应用状态保留在内存中；演示会话草稿由各自的内存状态持有者管理。应用重新启动后的状态恢复不属于本示例范围。此处尚未运行 Apple App Resizability。

## 演示文稿与资料来源

`Docs/AdaptiveDuoLab_iPhone_Duo_Demo.pptx` 包含 Somendra 分享的 17 页演示文稿，内容涵盖 API 代码、UI 示例，以及开场介绍和致谢结尾。资料链接保留在备注和指南中，没有单独的参考资料页。项目中已有图片来自较早的截图，不能作为新增示例的最新验证证据。请在 Mac 上构建并运行更新后的应用，再采集截图。

- [TabView](https://developer.apple.com/documentation/swiftui/tabview)
- [Tab](https://developer.apple.com/documentation/swiftui/tab)
- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [使用 iPhone Duo 提升工具栏体验，03:30](https://developer.apple.com/videos/play/tech-talks/111462/?time=210)

更新于 2026 年 10 月 12 日。
