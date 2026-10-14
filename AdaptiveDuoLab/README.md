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

## Xcode Canvas 预览

选择 `AdaptiveDuoLab` scheme 和 Debug 配置，打开 `Sources/Views/` 中的任意 Swift 文件，通过 **Editor → Canvas** 显示画布，再轻点刷新按钮启动预览。默认启用的原生示例仍要求 Xcode 27.1 SDK；使用 iOS 27.1 预览设备可查看原生分支，较早系统会显示相应回退界面。

14 个界面文件共提供 23 个具名 `#Preview`：

| 文件或界面 | 预览内容 |
| --- | --- |
| `RootView` | 完整应用首页，包含工作区、检查和设置标签页 |
| `DashboardView` | 窄屏列表、宽屏网格、书本折叠、桌面模式、辅助功能大字体、深色网格、RTL 列表 |
| `DemoSettingsView` | 可交互的分类、内容模式和姿态设置；分类变更同步更新计数和 API 实验室数据 |
| `LayoutAuditView` | Sheet 页面及导航中的 `LayoutAuditContent` |
| `WorkItemCard` | 完整卡片、紧凑卡片、大字体长文本 |
| `APILabView` 与 8 个 API 演示 | 各自的默认页面，保留导航、工具栏会话、标签页会话和 Sheet 编辑交互 |

工作区窄屏尺寸为 390 × 844 pt，宽屏尺寸为 1000 × 800 pt；辅助功能场景使用 `accessibility3` 字号。查看固定尺寸或自适应卡片尺寸时，使用 Canvas 的布局预览模式；设备模式仍由所选设备提供窗口大小。工作区中的“布局检查”按钮会打开与当前配置一致的 Sheet。

`Sources/PreviewSupport.swift` 为每个需要示例数据的预览创建独立 SwiftData 内存容器，复用 `DemoSeeder` 的中文记录并按更新时间排序。`StateObject` 保持交互刷新期间的数据生命周期；销毁并重新创建预览宿主后恢复示例数据。应用入口在 Debug 的 Xcode Preview 环境中也使用内存数据库，避免访问正常运行时的持久化记录。预览声明和支持代码仅参与 Debug 编译，Tuist 的 `Sources/**` 会包含支持文件。

相机默认预览处于未启动状态，打开 Canvas 不会请求相机权限或启动采集。真实相机、相机附属显示和物理铰链行为需要对应设备能力；书本折叠和桌面模式预览仅使用应用已有的模拟内容布局，不代表硬件验证。

### 本次预览验证记录（2026-10-13）

构建结果与 Canvas 结果分别记录。Canvas 使用 Xcode 27.1、iOS 27.1 的 iPhone Duo 预览设备；固定尺寸场景使用 Resizable 模式，交互使用 Live 模式。Resizable 的手动尺寸会在场景之间保留，切换后需核对底部宽高，不能仅根据场景名称判断实际尺寸。

| 验证项目 | 结果与实际观察 |
| --- | --- |
| Debug / Release Simulator 构建 | **通过**。两次构建均得到 `BUILD SUCCEEDED`，Release 产物未包含预览辅助类型符号。 |
| 14 个文件的默认入口 | **通过**。首页、工作区、设置、布局检查、卡片、API 实验室及 8 个 API 演示均在 Canvas 实际显示；共 23 个具名场景均已渲染。首页成功读取中文示例记录。 |
| 工作区固定尺寸 | **通过**。窄屏列表、大字体和 RTL 使用 390 × 844 pt；普通网格、深色网格、书本折叠、桌面模式使用 1000 × 800 pt。检查了可见区域内的文字换行、控件排列、三列网格、模拟分区、RTL 对齐及深色状态颜色。 |
| 卡片补充场景 | **通过**。完整卡片、紧凑卡片、大字体长文本均显示；大字体卡片的标题、摘要、进度和元数据可见，无重叠。 |
| 布局检查两个入口 | **通过**。独立 Sheet 页面包含“完成”；导航中的 `LayoutAuditContent` 显示配置、8 条记录和检查建议。 |
| 设置筛选和实验室导航 | **通过**。从“全部”切换为“研究”，当前数量从 8 变为 2，总数仍为 8；打开实验室并进入系统布局，显示 2 条研究记录及完成 / 进行中各 1 条的统计。 |
| 工作区交互 | **通过**。网格可切换为列表；姿态菜单从“当前窗口”切换“书本折叠”后变为左右两个区域；“布局检查”可打开并关闭与当前配置对应的 Sheet。 |
| SwiftUI 工具栏会话 | **通过**。检查次数从 0 变为 1，置顶状态改变；关闭后重新打开会话，计数和置顶状态保留。 |
| UIKit 工具栏会话 | **通过**。检查次数从 0 变为 1，添加记录后数量从 30 变为 31，并显示添加结果。 |
| 标签页会话 | **通过**。打开带侧边栏的会话，在“笔记”编辑文字后切到“摘要”，显示同一份修改后的草稿。 |
| Sheet 编辑 | **通过**。编辑草稿、完成后父页面显示修改内容，重新打开 Sheet 后内容仍保留。 |
| 重新布局示例 | **通过**。进度从 2/5 调为 3/5，摘要剩余数量变为 2；切换为纵向排列后状态保留。 |
| 相机初始状态 | **通过**。默认页面显示“相机已关闭”；未点击启动，未出现权限请求或采集画面。 |
| 工作区滚动 | 2026-10-13 的 Canvas 输入验证**被环境阻塞**；2026-10-14 改用独立设备补做运行时对照，见下方续验记录。Canvas 输入问题与 Simulator 运行时结果分开记录。 |
| 内存数据销毁重建、正常启动持久化对照 | 2026-10-13 尚未执行；2026-10-14 已补做真实预览宿主生命周期、应用入口存储分支及正常进程重启对照，见下方续验记录。 |
| 工程格式与差异检查 | **通过**。`.pbxproj` 格式及 `git diff --check` 通过。 |

Canvas 加载期间多次出现 `Updating took more than 5 seconds`、预览 thunk 构建超时或启动超时；刷新、重新选择场景或切换 Live / Resizable 后完成了上述渲染。成功记录表示实际见到对应画面，不表示这些加载超时已根治。

排查期间临时使用了 Legacy Previews Execution：首页、SwiftUI / UIKit 工具栏、标签页和 Sheet 交互的成功记录包含该模式。Legacy 模式下相机预览替换模块编译出现 `sending 'self' risks causing data races`；恢复默认 JIT 后相机默认预览成功。最终已恢复 JIT，没有为 Legacy 模式改写业务代码。正常 Debug / Release 构建通过不代表 Legacy 替换模块编译通过。

真实相机、相机附属显示和物理铰链不在本次验收范围内。2026-10-13 的续验仅更新此记录，没有提交或推送 Git。


### 独立设备续验（2026-10-14）

本次新建 `AdaptiveDuoLab-Validation-20261014`，设备 UUID 为 `0AE5D9C5-AFDB-41E6-8AD0-D68CE7845E86`，运行 iPhone Duo / iOS 27.1。构建和测试均指定该 UUID，并使用独立的 `/private/tmp/AdaptiveDuoLab-isolated-validation` DerivedData。本次没有操作 PageContainer 的 Simulator 窗口或设备。

新增 `Tests/PreviewRuntimeTests.swift` 与 3 个 UI 测试，保留原应用入口、`PreviewSupport` 和工作区实现；三份源码的 SHA-256 在续验前后保持一致。新测试文件已加入 Xcode 测试 target，Tuist 的 `Tests/**` 自动涵盖它。

最终单元结果为 **4 项通过、0 失败、0 跳过**，UI 结果为 **3 项通过、0 失败、0 跳过**。两个最终 `.xcresult` 的状态均为 `Passed`，对应日志均含 `TEST SUCCEEDED`，两个 `xcodebuild` 进程均以 0 退出。这是本次新增范围的定向验证，没有将之前完整测试集的历史结果计入本次通过数。

- **预览宿主生命周期：通过。** 在真实 `UIWindow` 中挂载 `SampleDataPreview`，修改模型标题和进度并保存；刷新同一宿主时 UUID 和修改保留，第二个独立预览实例仍为原始示例。移除宿主后用弱引用确认旧 `PreviewSampleData` 与 `ModelContainer` 均释放；重新挂载后恢复 8 条示例、首条进度 100%，且 UUID 与旧容器不重合。
- **应用入口存储分支：通过。** 测试直接执行真实 `AdaptiveDuoLabApp.init()`，在作用域内设置并恢复 Preview 环境变量，检查实际容器配置。正常入口使用磁盘；Preview 入口使用内存，修改、保存、释放、重建后恢复示例；恢复正常环境后，磁盘标记的 UUID、标题和 `0.314` 进度不变。该检查不复制一份容器选择逻辑，也不增加业务公开 API。
- **固定尺寸滚动范围：通过。** 在真实窗口中挂载相同的 `SampleDataPreview` 和 `DashboardView`，覆盖窄屏列表、大字体列表、宽屏网格、书本双区域和桌面模式，共 6 个可滚动区域。检查滚动及手势识别器启用，并在 LazyVStack 高度稳定后，以程序设置偏移确认真实末端和起点均可到达。这项检查验证运行时几何与偏移，不冒充触摸或 Canvas 输入。
- **正常启动持久化：通过。** 不传 `-ui-testing`、`-reset-data` 或 Preview 环境变量，连续启动和终止应用 3 次，均读取同一 UUID 的“持久化对照标记”，UI 进度为 31%（存储值 `0.314`）。随后以只读 SQLite 查询核对 8 条记录的 UUID、标题、进度和更新时间，均与入口对照前一致；没有用重新播种的相似记录代替持久化证据。
- **普通与大字体触摸滚动：通过。** 在真实应用中执行 XCTest 触摸手势，两种字号均能滚到最后一条“感知场景的几何信息”，此时首条记录不可触达；反向滑动后首条记录再次可触达。最终截图已目视复核。普通字号首个手势使首条卡片 Y 从 345.7 变为 −34.7 pt，大字体从 159.3 变为 −1.7 pt。大字体卡片高于可见区域，触摸断言验证最后卡片可触达；精确几何末端另由上面的固定尺寸宿主测试验证。

固定尺寸宿主的内容区域为窄屏 390 × 844 pt、宽屏 1000 × 800 pt；以下是最终运行时测得的纵向滚动范围（pt，四舍五入到一位小数）：

| 场景 | 纵向滚动范围 | 实际检查 |
| --- | --- | --- |
| 窄屏列表 | 0–1176.7 | 末端及返回起点通过 |
| 辅助功能大字体列表 | 0–2520.3 | 末端及返回起点通过 |
| 宽屏网格 | 0–103.0 | 末端及返回起点通过 |
| 书本折叠左 / 右区域 | 0–258.7 / 0–295.7 | 两个区域分别通过 |
| 桌面模式 | 0–387.7 | 末端及返回起点通过 |

初次 UI 对照尝试直接设置 `XCODE_RUNNING_FOR_PREVIEWS=1` 启动普通应用，得到只有空白根视图的可访问性树，无法进入工作区；该次运行是 **1 项通过、1 项失败**。单独设置变量不等于 Xcode 的完整 Preview 注入协议，因此改用宿主测试检查应用入口的真实容器，再用普通进程重启验证磁盘记录。保留初次失败的 `runtime-ui.xcresult`，不将它计入成功结果。

中间运行还暴露了测试时序假设：LazyVStack 的估算高度会在滚动后变化，SwiftData 容器可能延迟释放，大字体的首个手势也不保证首条记录坐标立即改变。`ui-complete.xcresult` 的普通字号测试在滑动后读取已移出可访问性树的首条记录 `frame`，因此诊断日志自身报错；该包实际为 2 项通过、1 项失败。最终测试分别等待实际高度稳定、等待弱引用释放，在读取屏外节点前检查存在性，并检查完整触摸往返。修订仅涉及测试。超时或手动停止的中间结果包单独保留，不计入最终通过数。

**Canvas 输入边界仍保留。** 本次没有重新接管 Xcode Canvas；运行时窗口的滚动范围、触摸手势与内存生命周期证据，不能替代 Canvas Live 模式的输入验收。目前没有在独立 Simulator 重现“集合完全不能滚动”，也没有足够证据将 Canvas 无位移归因于应用布局或某个确定的 Xcode 缺陷。

证据保存在本机 `/private/tmp/AdaptiveDuoLab-validation-20261014/`：

| 证据 | 文件 |
| --- | --- |
| 最终 4 项单元测试 | `unit-final-pass.xcresult`、`unit-final-pass.log`、`unit-summary.json` |
| 最终 3 项 UI 测试 | `ui-final-pass.xcresult`、`ui-final-pass.log`、`ui-summary.json` |
| 最终滚动及持久化截图 | `ui-final-attachments/`，`manifest.json` 对应测试与截图 |
| 磁盘记录前后只读快照 | `disk-before.json`、`disk-final.json`，两者 SHA-256 均为 `5fe2fc5638ff38eaec94ff8e744a356d602899ffd2b2f3827b4fee816abda388` |
| 业务源码核对 | `source-before.sha256`，入口、预览支持和工作区三份源码校验均为 `OK` |

快照比较的是上述 4 个模型字段，不表示数据库所有文件字节相同。`.pbxproj` 格式、scheme XML 和 `git diff --check` 均通过。本次没有重新运行 Release 构建；应用源码沿用已通过 Debug / Release 构建的预览实现，新增运行时测试使用 Debug。保留原有工程及 scheme 修改，没有提交或推送 Git。

复现时必须使用名称以 `AdaptiveDuoLab-Validation-` 开头的专用设备，并关闭并行测试；涉及默认磁盘数据库的夹具和入口对照会在其他设备上跳过。按以下顺序运行：

1. `-only-testing:AdaptiveDuoLabTests/PreviewRuntimeTests`，先验证内存生命周期并准备磁盘夹具。
2. `-only-testing:AdaptiveDuoLabUITests/AdaptiveDuoLabUITests/testNormalLaunchesPreservePersistentRecord`。
3. `-only-testing:AdaptiveDuoLabUITests/AdaptiveDuoLabUITests/testWorkspaceScrollReachesLastRecord` 和 `-only-testing:AdaptiveDuoLabUITests/AdaptiveDuoLabUITests/testAccessibilityWorkspaceScrollReachesLastRecord`。

上述测试使用 `AdaptiveDuoLab` scheme / Debug，以及 `-destination 'platform=iOS Simulator,id=<专用设备 UUID>' -parallel-testing-enabled NO`。磁盘夹具会在专用设备留下“持久化对照标记”（进度 `0.314`）供再次核对，不更改其他设备的数据。

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

布局检查使用本地规则，没有接入实时 AIHubServices 客户端。API 实验室包含可执行示例，包括此前仅列于清单中的工具栏和相机 API。源码实现本身不能证明某个新 API 已成功编译或运行；以上验证结论以本次实际构建和测试覆盖范围为限。工作区的书本折叠／桌面模式区域仍为模拟内容，其内容面板未被实验室示例替换。根视图存在期间，共享应用状态保留在内存中；演示会话草稿由各自的内存状态持有者管理。标签、分类、姿态和会话草稿在应用重新启动后的恢复不属于本示例范围；SwiftData 记录的持久化已在上方 2026-10-14 专用设备对照中验证。此处尚未运行 Apple App Resizability。

## 演示文稿与资料来源

`Docs/AdaptiveDuoLab_iPhone_Duo_Demo.pptx` 包含 Somendra 分享的 17 页演示文稿，内容涵盖 API 代码、UI 示例，以及开场介绍和致谢结尾。资料链接保留在备注和指南中，没有单独的参考资料页。项目中已有图片来自较早的截图，不能作为新增示例的最新验证证据。请在 Mac 上构建并运行更新后的应用，再采集截图。

- [TabView](https://developer.apple.com/documentation/swiftui/tabview)
- [Tab](https://developer.apple.com/documentation/swiftui/tab)
- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [使用 iPhone Duo 提升工具栏体验，03:30](https://developer.apple.com/videos/play/tech-talks/111462/?time=210)

更新于 2026 年 10 月 14 日。
