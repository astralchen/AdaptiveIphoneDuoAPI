import SwiftUI

/// 独立于工作区的 NavigationSplitView 呈现。
struct APILabView: View {
	let items: [WorkItem]
	let category: WorkCategory

	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			List {
				Section {
					ForEach(APIDemoRoute.allCases) { route in
						NavigationLink {
							APIDemoDestination(
								route: route,
								items: items,
								category: category
							)
						} label: {
							Label(
								route.title,
								systemImage: route.symbol
							)
						}
						.accessibilityIdentifier(
							route.accessibilityIdentifier
						)
					}
				} header: {
					Text("交互示例")
				} footer: {
					Text(
						"系统布局使用所选分类中的记录。" +
						"其他示例各自保留可编辑的演示状态。" +
						"系统决定支持的呈现位置和硬件能力。"
					)
				}

				Section {
					Text(
						"原生导航和系统栏会自动调整呈现方式。" +
						"应用负责提供内容关系、回退布局和状态。"
					)

					Text(
						"Apple 的 App Resizability skill 可在 Xcode 中辅助修改源代码；" +
						"它不属于运行时布局 API。"
					)
				} header: {
					Text("自动适配")
				}

				Section {
					ForEach(APICatalogEntry.entries) { entry in
						NavigationLink {
							APICatalogDetail(
								entry: entry,
								items: items,
								category: category
							)
						} label: {
							VStack(
								alignment: .leading,
								spacing: 5
							) {
								Text(entry.name)
									.font(.headline)

								Text(entry.version)
									.font(.caption)
									.foregroundStyle(.secondary)

								Text(entry.status)
									.font(.subheadline)
							}
							.padding(.vertical, 3)
						}
						.accessibilityIdentifier(
							"apiLab.entry.\(entry.id)"
						)
					}
				} header: {
					Text("API 清单")
				}
			}
			.navigationTitle("API 实验室")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("完成") {
						dismiss()
					}
					.accessibilityIdentifier("apiLab.done")
				}
			}
		}
		.accessibilityIdentifier("apiLab.screen")
	}
}


private struct APICatalogDetail: View {
	let entry: APICatalogEntry
	let items: [WorkItem]
	let category: WorkCategory

	var body: some View {
		List {
			if let route = entry.demoRoute {
				Section {
					NavigationLink {
						APIDemoDestination(
							route: route,
							items: items,
							category: category
						)
					} label: {
						Label(
							"体验此 API",
							systemImage: "play.circle"
						)
					}
				}
			}

			Section {
				Text(entry.version)
			} header: {
				Text("可用条件")
			}

			Section {
				Text(entry.purpose)
			} header: {
				Text("作用")
			}

			Section {
				Text(entry.status)

				Text(entry.source)
					.font(.footnote)
					.foregroundStyle(.secondary)
			} header: {
				Text("本项目中的实现")
			}

			Section {
				Text(entry.ordinaryPhone)
			} header: {
				Text("其他受支持的 iPhone")
			}

			Section {
				if let url = entry.documentationURL {
					Link(
						"Apple 文档",
						destination: url
					)
				}
			} footer: {
				Text(
					"部分示例需要启用原生 API 的构建版本及受支持的系统。" +
					"硬件功能仍为可选能力。"
				)
			}
		}
		.navigationTitle(entry.name)
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityIdentifier(
			"apiLab.detail.\(entry.id)"
		)
	}
}


private struct APIDemoDestination: View {
	let route: APIDemoRoute
	let items: [WorkItem]
	let category: WorkCategory

	@ViewBuilder
	var body: some View {
		switch route {
		case .system:
			SystemArrangementDemo(
				items: items,
				category: category
			)

		case .toolbar:
			ToolbarAPIDemo()

		case .tabs:
			TabAPIDemo()

		case .layout:
			LayoutAPIDemo()

		case .uikit:
			UIKitAPIDemo()

		case .uikitToolbar:
			UIKitToolbarAPIDemo()

		case .presentations:
			PresentationAPIDemo()

		case .camera:
			CameraAPIDemo()
		}
	}
}
