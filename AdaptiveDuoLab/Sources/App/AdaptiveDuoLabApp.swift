import SwiftData
import SwiftUI

@main
struct AdaptiveDuoLabApp: App {
    private let container: ModelContainer

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        var usesMemoryStore = arguments.contains("-ui-testing")
        #if DEBUG
        // Canvas 启动应用宿主时也使用内存存储，避免访问正式演示数据库。
        usesMemoryStore = usesMemoryStore || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #endif
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: usesMemoryStore
        )

        do {
            container = try ModelContainer(
                for: WorkItem.self,
                configurations: configuration
            )
            try DemoSeeder.seedIfNeeded(
                in: ModelContext(container),
                reset: arguments.contains("-reset-data")
            )
        } catch {
            fatalError("无法创建演示数据库： \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
