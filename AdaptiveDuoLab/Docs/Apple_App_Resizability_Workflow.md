# 在 AdaptiveDuoLab 中使用 Apple 的 App Resizability skill

资料核验日期：2026 年 9 月 26 日。中文文档更新于 2026 年 10 月 12 日。本文介绍如何在 Mac 上运行 Apple 提供的 skill。准备本项目时未执行随附的 Apple skill，本文也不是 Apple skill 的导出文件。

随附演示文稿的第 15 页专门介绍此流程，使用 `Docs/Screenshots/06_app_resizability.png`。原演示包可在选择匹配的 Xcode SDK 和 Simulator 后，通过 `./Automation/run-api-demos.sh` 启动原生 API 示例。当前仓库未包含 `Automation/` 脚本，请直接使用 Xcode 运行。API 实验室包含工具栏、布局、UIKit、相机和呈现方式示例；它不会执行开发用的 skill。

## 补充说明 App Resizability skill

Apple 的 **App Resizability** skill 随 **Xcode 27.1** 提供。它由 WWDC26 推出的应用现代化 skill 更名而来，现已扩展支持 **SwiftUI 和 iPhone Duo**。Apple 在 [Prepare your app for iPhone Duo，9:12](https://developer.apple.com/videos/play/tech-talks/111461/?time=552) 中介绍了新名称。

| Apple 提供的 skill | 适用场景 |
| --- | --- |
| App Resizability — Xcode 27.1 | 审阅并更新现有应用，使其支持窗口大小调整和自适应布局，包括 SwiftUI 和 Duo。 |
| SwiftUI Specialist Skill — Xcode 27 | 审阅 SwiftUI 实现、数据流、性能和正确性。 |
| What’s New In SwiftUI Skill — Xcode 27 | 根据最新框架指导，辅助采用新的 SwiftUI API。 |

后两项的名称及其在 Coding Assistant 中的可用性，记录于 [What’s new in SwiftUI](https://developer.apple.com/videos/play/wwdc2026/269/)。这些 skill 用于开发阶段，并非 SwiftUI modifier、链接到应用中的库，也不是应用检查页面的功能。

## 三类自动行为

| 机制 | 实际行为 | 开发者仍需提供的内容 |
| --- | --- | --- |
| 标准 SwiftUI 容器 | 导航、标签栏、工具栏和呈现方式会响应受支持的环境。 | 合适的内容层级、清晰可读的自定义内容，以及状态保留。 |
| 使用较新的 SDK 构建 | iOS 27.1 SDK 启用 Apple 介绍的更完整 Duo 屏幕布局和更新后的标准工具栏行为。 | 与 SDK 兼容的构建，并验证最终布局。升级 SDK 不要求提高本应用的 iOS 17 最低部署版本。 |
| App Resizability 与 Coding Agent 配合 | Agent 使用项目上下文和 skill 指导，提出或执行源代码修改。 | 明确的范围、代码审阅、成功的构建与测试，以及用户体验验证。 |

Apple 在 [Prepare your app for iPhone Duo，0:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=30) 和 [5:01](https://developer.apple.com/videos/play/tech-talks/111461/?time=301) 演示了前两类机制。现有文档并未提供一个只需一行代码就能修复应用所有自定义页面的运行时 API。

早期应用现代化 skill 的演示工作包括替换主屏幕引用、更新依赖方向的布局，以及将旧式 UIKit 应用生命周期代码迁移到 Scene。Apple 也说明，复杂工作可能需要提问，未完成的大型任务可能记录在注释中。参见 [Modernize your UIKit app，14:07](https://developer.apple.com/videos/play/wwdc2026/278/?time=847)。应将其视为辅助实现流程，并验证结果。

## 应用于整个现有 workspace

1. 在版本控制中保存项目检查点，然后用 Xcode 27.1 打开 `AdaptiveDuoLab.xcworkspace`。选择 `AdaptiveDuoLab` scheme 和已安装的 Simulator 运行环境。除非另有产品决策，否则保持 iOS 17 最低部署版本。
2. 打开已配置 Agent 的 Coding Assistant。输入 `/` 查看已加载的 skill 和命令，选择界面中显示的 App Resizability skill。使用补全功能，不要假定斜杠命令的拼写。Apple 在 [Coding Intelligence for Beginners，5:31](https://developer.apple.com/videos/play/wwdc2026/8007/?time=331) 中介绍了此发现机制。
3. 向 Agent 提供整个 workspace 和下方提示词。文件列表只是初始索引，还应要求它检查相关文件和 API 实验室。
4. 检查建议的修改及其对现有流程的影响。要求 Agent 构建项目、运行测试、修复失败项，并列出无法完成的检查。
5. 在 Device Hub 中测试不同宽度和 Duo 姿态，再在真机上验证适用流程。Apple 在 [Modernize your UIKit app，8:19](https://developer.apple.com/videos/play/wwdc2026/278/?time=499) 中演示了窗口大小调整工具。

为 AdaptiveDuoLab 编写的项目提示词建议：

```text
使用 Apple 的 App Resizability skill 审查并更新整个 AdaptiveDuoLab workspace，
覆盖所有标签页、Sheet 和自定义内容视图。

保留 iOS 17 最低部署版本、现有 SwiftData 模型和预置记录、所选分类、
呈现选项、导航状态和标签页状态。按需检查相关文件，首先查看
AdaptiveDuoLabApp、RootView、DashboardView、WorkItemCard、LayoutAuditView、
DemoSettingsView、AdaptiveLayoutPolicy、LayoutModels 和 API 实验室。

查找对固定屏幕、device idiom、方向、安全区域和文字大小的假设。
在合适的位置使用局部可用几何信息和标准导航容器。
确保前景控件可访问，并正确处理不对称安全区域。
检查窄分栏、普通 iPhone、iPad、可调整大小的 iPhone 窗口、Dynamic Type、
长标签和从右到左的布局。

区分系统自动适配与需要显式采用的 API。对于建议引入的每个 API，
核对其符号、SDK 和系统可用性，确定实际调用位置，并实现旧系统回退。
只有在服务于具体功能时才添加相机或铰链行为。明确区分模拟演示姿态
与实际设备几何信息及能力观测结果。

先逐文件列出问题和修改方案，再实现适用的修复。
构建应用并运行现有单元测试和 UI 测试。验证切换标签页、分类、尺寸和
呈现方式时的状态连续性。报告实际执行的检查、结果、剩余问题和未执行项。
不能仅因源代码已修改就将问题标记为已修复。
```

应用的策略阈值属于示例产品选择，并非 Apple 规定的断点。只有在内容测量和实际可用性能够支持时，才保留这些阈值。

## 继续进行针对性的 SwiftUI 审阅

布局修改成功构建后，使用 SwiftUI Specialist Skill 检查正确性，使用 What’s New In SwiftUI Skill 检查 API 采用情况。后续提示词建议：

```text
使用 SwiftUI Specialist Skill 和 What’s New In SwiftUI Skill，审阅更新后的
AdaptiveDuoLab 实现。核对 TabView、NavigationSplitView、Sheet 和备选布局
中的视图身份及状态归属是否稳定。检查 Dynamic Type、VoiceOver 标签、
Main Actor 工作和集合渲染。

将 API 实验室、API 采用指南与实际源代码进行比较。将每个 API 标记为：
应用已使用、实验室已演示、仅有文档，或在当前构建／运行环境中不可用。
删除无依据的声明。保留 iOS 17 回退，并使用所选 Xcode SDK 检查每个可用性边界。

构建并重新运行受影响的测试。简要说明每项重要修改及其验证证据。
列出所有需要真机检查的内容。
```

这些提示词是项目指导，并非 Apple 官方 skill 内容，也不保证对应某种固定调用语法。

## 源码审查已确认的内容

| 现有源代码 | 发现 | 含义 |
| --- | --- | --- |
| `Sources/App/AdaptiveDuoLabApp.swift` | SwiftUI `App` 使用 `WindowGroup` 和共享 SwiftData 模型容器。 | 本应用的起始问题不涉及旧式 UIKit Scene 迁移。 |
| `Sources/Views/RootView.swift` | 使用原生标签页和 `NavigationSplitView`；共享工作区选项由标签页内容的上层管理。 | 检查状态连续性和呈现行为，重构时保留这一归属关系。 |
| `Sources/Views/DashboardView.swift` | 使用局部 `GeometryReader` 测量和 `ViewThatFits` 备选布局。 | 已有灵活布局基础，仍需在实际可用空间中验证自定义内容。 |
| `Sources` 审查 | 在已检查的基线代码中未发现 `UIScreen.main`、`UIDevice`、`userInterfaceIdiom` 或 `interfaceOrientation` 引用。 | 除非后续改动引入这些模式，否则不要声称替换了它们。 |

仍需验证的内容包括窄分栏和大字号、各侧安全区域、真实 Duo 工具栏位置、窗口调整及过渡中的状态连续性，以及 SDK／运行环境可用性。2026 年 10 月 12 日已完成当前中文版本的 Xcode 27.1 构建、18 项单元测试和 7 项 UI 测试；这些结果不覆盖上述全部场景。修改前的截图只反映旧版界面。手动选择预览姿态不能证明真实铰链 API 或系统姿态过渡已被触发。

项目中的检查页面是本地布局检查清单，不会运行 Apple 的 Xcode skill。API 实验室和 [API 采用指南](API_Adoption_Guide.md) 标明当前实现与演示情况；应结合所选 Mac 工具链上的成功构建核对这些状态。

## 将 Apple skill 导出到其他编程工具

Apple 在 [Modernize your UIKit app，15:05](https://developer.apple.com/videos/play/wwdc2026/278/?time=905) 中公开了以下命令：

```bash
xcrun agent skills export
```

在 Mac 上选择目标 Xcode 后运行此命令。根据命令输出找到导出的 Markdown 文件，再按接收工具文档中的 skill 机制导入。引用的视频并未确立通用的导出目录或外部 Agent 安装路径。导出指导文件不会执行迁移，也不会改变应用的运行时行为。

本项目归档不包含 Apple 的 skill 文件或 Xcode。如果 Coding Assistant 中缺少某个 skill，请先检查已安装的 Xcode 版本和已加载 skill 列表，再声明可以调用它。

## 区分第三方指导

[SwiftUI Expert Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) 是独立的社区 skill。其 [5.1.0 版本](https://github.com/AvdLee/SwiftUI-Agent-Skill/releases/tag/5.1.0) 增加了窗口大小调整和 iPhone Duo 指导。它可补充编程工作流程，但并非 Apple 的 App Resizability skill。

POC 中拟议的 AIHubServices 集成也是独立内容。服务构想或本地生成的布局建议，都不能证明任何 Apple 开发 skill 已被调用。
