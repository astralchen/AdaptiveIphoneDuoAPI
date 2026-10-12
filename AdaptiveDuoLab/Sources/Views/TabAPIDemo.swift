import SwiftUI

/// 独立于 API Lab 的导航栈呈现真实的标签页容器。
struct TabAPIDemo: View {
    @State private var prefersSidebar = true
    @State private var showsSession = false

	var body: some View {
		Form {
			Section {
				Toggle(
					"在支持时优先使用侧边栏",
					isOn: $prefersSidebar
				)
				.accessibilityIdentifier(
					"tabsDemo.sidebarPreference"
				)

				Button("打开标签页示例") {
					showsSession = true
				}
				.accessibilityIdentifier(
					"tabsDemo.open"
				)
			} header: {
				Text("呈现偏好")
			} footer: {
				Text(
					"系统会为当前窗口选择受支持的呈现位置。" +
					"更改偏好后，请重新打开示例。"
				)
			}

			Section {
				Text(
					"编辑笔记、切换页面，然后调整窗口大小或旋转设备。" +
					"笔记和所选页面属于同一个会话。"
				)

				Text(
					"在 iPad 上，自适应标签栏使用自身的默认位置偏好。" +
					"较新的 defaultTabBarPlacement API 用于设置" +
					"受支持 iPhone 环境中的位置偏好。"
				)
			} header: {
				Text("试一试")
			}
		}
		.navigationTitle("标签页与侧边栏")
		.fullScreenCover(isPresented: $showsSession) {
			TabDemoSession(
				prefersSidebar: prefersSidebar
			)
		}
	}
}

private struct TabDemoSession: View {
    let prefersSidebar: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedTab = 0
    @State private var draft = "我的自适应笔记"

    var body: some View {
        tabs.tint(.indigo)
    }

    @ViewBuilder
    private var tabs: some View {
        if #available(iOS 18.0, *) {
            modernPresentation
        } else {
            TabView(selection: $selectedTab) {
                editor.tabItem { Label("笔记", systemImage: "note.text") }.tag(0)
                summary.tabItem { Label("摘要", systemImage: "doc.text.magnifyingglass") }.tag(1)
            }
        }
    }

    @available(iOS 18.0, *)
    @ViewBuilder
    private var modernPresentation: some View {
        #if DUO_SDK
        if #available(iOS 27.0, *) {
            modernTabs
                .tabViewStyle(.sidebarAdaptable)
                .defaultAdaptableTabBarPlacement(prefersSidebar ? .sidebar : .tabBar)
                .defaultTabBarPlacement(prefersSidebar ? .sidebar : .tabBar)
        } else {
            adaptableTabs
        }
        #else
        adaptableTabs
        #endif
    }

    @available(iOS 18.0, *)
    private var adaptableTabs: some View {
        modernTabs
            .tabViewStyle(.sidebarAdaptable)
            .defaultAdaptableTabBarPlacement(prefersSidebar ? .sidebar : .tabBar)
    }

    @available(iOS 18.0, *)
    private var modernTabs: some View {
        TabView(selection: $selectedTab) {
            Tab("笔记", systemImage: "note.text", value: 0) { editor }
            Tab("摘要", systemImage: "doc.text.magnifyingglass", value: 1) { summary }
        }
    }

    private var editor: some View {
        NavigationStack {
            Form {
                Section("共享笔记") {
                    TextField("笔记", text: $draft, axis: .vertical)
                        .accessibilityIdentifier("tabsDemo.draft")
                }
                Section("当前窗口") {
                    LabeledContent("Size Class", value: sizeClass == .regular ? "Regular" : "Compact 或未指定")
                    Text("此处读取当前环境，不会根据屏幕尺寸推断设备类型。")
                }
            }
            .navigationTitle("笔记")
            .toolbar { closeButton }
        }
    }

    private var summary: some View {
        NavigationStack {
            Form {
                Section("同一份笔记") {
                    Text(draft.isEmpty ? "暂无笔记" : draft)
                        .accessibilityIdentifier("tabsDemo.summary")
                }
            }
            .navigationTitle("摘要")
            .toolbar { closeButton }
        }
    }

    @ToolbarContentBuilder
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("关闭示例") { dismiss() }
                .accessibilityIdentifier("tabsDemo.close")
        }
    }
}
