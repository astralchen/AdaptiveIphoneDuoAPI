import SwiftData
import SwiftUI

@main
struct AdaptiveDuoLabApp: App {
    private let container: ModelContainer

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: arguments.contains("-ui-testing")
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
