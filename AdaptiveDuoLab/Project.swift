import ProjectDescription

let project = Project(
    name: "AdaptiveDuoLab",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "DEVELOPMENT_LANGUAGE": "zh-Hans",
            "SWIFT_STRICT_CONCURRENCY": "complete",
            // 默认启用原生演示分支，编译需要包含对应 API 的 iOS 27.1 SDK。
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DUO_SDK"
        ]
    ),
    targets: [
        .target(
            name: "AdaptiveDuoLab",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.example.AdaptiveDuoLab",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
                    "CFBundleLocalizations": ["zh-Hans"],
                    "NSCameraUsageDescription": "用于在相机 API 示例中显示后置相机实时预览。",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ]
                ]
            ),
            sources: ["Sources/**"]
        ),
        .target(
            name: "AdaptiveDuoLabTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.example.AdaptiveDuoLabTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "AdaptiveDuoLab")]
        ),
        .target(
            name: "AdaptiveDuoLabUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "com.example.AdaptiveDuoLabUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["UITests/**"],
            dependencies: [.target(name: "AdaptiveDuoLab")]
        )
    ]
)
