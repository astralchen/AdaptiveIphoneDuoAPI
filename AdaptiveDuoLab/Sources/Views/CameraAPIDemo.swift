import AVFoundation
import Combine
import SwiftUI
import UIKit

/// 由用户主动启用的真实相机流程；没有 scene accessory 时仍可使用预览。
/// 未配置麦克风输入、照片输出、录制功能或照片图库访问。
struct CameraAPIDemo: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var model = CameraDemoModel()

    var body: some View {
        Group {
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                NativeCameraDemo(model: model)
            } else {
                CameraDemoScreen(model: model) {
                    Text("此处可使用相机预览。可选的相机附属显示功能需要 iOS 27.1 或更高版本。")
                }
            }
            #else
            CameraDemoScreen(model: model) {
                Text("此处可使用相机预览。使用 iOS 27.1 SDK 并设置 DUO_SDK=1 构建，可启用原生相机附属显示功能。")
            }
            #endif
        }
        .navigationTitle("相机附属显示")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("apiLab.cameraScreen")
        .onDisappear { model.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { model.stop() }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: AVCaptureSession.wasInterruptedNotification,
            object: model.engine.session
        ).receive(on: DispatchQueue.main)) { _ in
            model.stop(message: "相机已中断。恢复可用后，轻点“启动相机”。")
        }
        .onReceive(NotificationCenter.default.publisher(
            for: AVCaptureSession.runtimeErrorNotification,
            object: model.engine.session
        ).receive(on: DispatchQueue.main)) { _ in
            model.stop(message: "相机会话意外停止，请尝试重新启动。")
        }
    }
}

private struct CameraDemoScreen<AccessoryControls: View>: View {
    @ObservedObject var model: CameraDemoModel
    @ViewBuilder let accessoryControls: () -> AccessoryControls
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("实时相机与演讲提示")
                    .font(.title2.bold())
                Text("启动后置相机以预览取景。演讲者可在符合条件的附属显示屏上阅读相同提示。")
                    .foregroundStyle(.secondary)

                ZStack {
                    CameraPreview(engine: model.engine)
                    if !model.isRunning {
                        Rectangle().fill(.black)
                        ContentUnavailableView(
                            "相机已关闭",
                            systemImage: "camera",
                            description: Text("轻点“启动相机”以请求访问权限并显示实时预览。")
                        )
                        .foregroundStyle(.white)
                    }
                }
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .frame(maxWidth: 500)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: .infinity)
                .accessibilityLabel(model.isRunning ? "后置相机实时预览" : "相机预览已关闭")
                .accessibilityIdentifier("apiLab.cameraPreview")

                Text(model.status)
                    .font(.callout)
                    .accessibilityIdentifier("apiLab.cameraStatus")

                if model.isRunning || model.isStarting {
                    Button {
                        model.stop()
                    } label: {
                        Label(model.isStarting ? "取消启动相机" : "停止相机", systemImage: "stop.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("apiLab.cameraStop")
                } else {
                    Button {
                        Task { await model.start() }
                    } label: {
                        Label("启动相机", systemImage: "camera")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("apiLab.cameraStart")
                }

                if model.canOpenSettings,
                   let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    Button("打开相机权限设置") { openURL(settingsURL) }
                }

                Divider()
                CameraPromptCard(model: model)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("可选的相机附属显示").font(.headline)
                    accessoryControls()
                    Text("系统决定是否显示此内容及其显示位置。相机必须运行且应用必须位于前台。没有可用的附属显示屏时，主屏幕会保留全部控件。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("仅供预览，不会拍照、录制或保存内容。离开此页面或将应用切至后台会停止相机。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct CameraPromptCard: View {
    @ObservedObject var model: CameraDemoModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("演讲提示", systemImage: "text.bubble")
                .font(.headline)
            Text(model.currentPrompt)
                .font(.title2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("apiLab.cameraPrompt")
            Button("下一条提示", systemImage: "arrow.right") {
                model.nextPrompt()
            }
            .buttonStyle(.bordered)
        }
    }
}

#if DUO_SDK
@available(iOS 27.1, *)
private struct NativeCameraDemo: View {
    @ObservedObject var model: CameraDemoModel
    @State private var accessoryEnabled = false
    @State private var accessoryAvailable = false
    @State private var accessoryPresented = false

    var body: some View {
        CameraDemoScreen(model: model) {
            Toggle("在附属显示屏上显示演讲提示", isOn: $accessoryEnabled)
                .disabled(!model.isRunning || !accessoryAvailable)
                .accessibilityIdentifier("apiLab.cameraAccessoryToggle")
            LabeledContent("系统可用性", value: accessoryAvailable ? "可用" : "不可用")
            LabeledContent("附属显示内容", value: accessoryPresented ? "已显示" : "未显示")
            if !model.isRunning {
                Text("请先启动相机，再启用附属显示功能。")
                    .font(.footnote)
            }
        }
        .sceneAccessory {
            CameraCaptureAccessory(isEnabled: $accessoryEnabled) {
                ScrollView {
                    CameraPromptCard(model: model)
                        .padding()
                }
                .onAppear { accessoryPresented = true }
                .onDisappear { accessoryPresented = false }
            }
            .onAvailabilityChange { available in
                accessoryAvailable = available
                if !available { accessoryEnabled = false }
            }
        }
        .onChange(of: model.isRunning) { _, running in
            if !running { accessoryEnabled = false }
        }
        .onDisappear { accessoryEnabled = false }
    }
}
#endif

@MainActor
private final class CameraDemoModel: ObservableObject {
    @Published private(set) var isStarting = false
    @Published private(set) var isRunning = false
    @Published private(set) var canOpenSettings = false
    @Published private(set) var status = "已就绪。仅在轻点“启动相机”后请求相机访问权限。"
    @Published private(set) var promptIndex = 0

    let engine = CameraDemoEngine()
    private var requestGeneration = 0
    private let prompts = [
        "应用可以适应不断变化的显示尺寸，同时保留内容和状态。",
        "使用局部几何信息和原生导航，避免假定屏幕尺寸固定不变。",
        "将可交互控件保持在安全区域内，确保每项功能均可访问。"
    ]

    var currentPrompt: String { prompts[promptIndex] }

    func nextPrompt() {
        promptIndex = (promptIndex + 1) % prompts.count
    }

    func start() async {
        guard !isStarting, !isRunning else { return }
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil else {
            status = "没有可用的后置相机。请使用真机运行此预览；模拟器中不会模拟相机采集。"
            return
        }

        requestGeneration += 1
        let generation = requestGeneration
        isStarting = true
        canOpenSettings = false
        status = "正在检查相机权限…"

        let allowed: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            allowed = true
        case .notDetermined:
            allowed = await AVCaptureDevice.requestAccess(for: .video)
        default:
            allowed = false
        }
        // 权限弹窗可能在此界面关闭后仍然存在；界面关闭后不得启动相机会话。
        guard generation == requestGeneration else { return }
        guard allowed else {
            isStarting = false
            let authorization = AVCaptureDevice.authorizationStatus(for: .video)
            canOpenSettings = authorization == .denied
            status = authorization == .restricted
                ? "此设备限制了相机访问。"
                : "无法访问相机。请在设置中允许相机访问，以使用预览。"
            return
        }

        status = "正在启动后置相机…"
        engine.start { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self, self.requestGeneration == generation else { return }
                self.isStarting = false
                switch result {
                case .success:
                    self.isRunning = true
                    self.status = "后置相机实时预览，不会保存照片或录制内容。"
                case .failure(let error):
                    self.isRunning = false
                    self.status = error.message
                }
            }
        }
    }

    func stop(message: String = "相机已停止。轻点“启动相机”以恢复预览。") {
        requestGeneration += 1
        isStarting = false
        isRunning = false
        status = message
        engine.stop()
    }
}

private enum CameraDemoError: Error, Sendable {
    case noRearCamera
    case cannotAddInput
    case configuration(String)
    case didNotStart

    var message: String {
        switch self {
        case .noRearCamera:
            return "此设备没有可用的后置相机。"
        case .cannotAddInput:
            return "相机输入不可用。请关闭其他使用相机的功能后重试。"
        case .configuration(let detail):
            return "无法配置相机：\(detail)"
        case .didNotStart:
            return "无法启动相机。请在相机采集可用时重试。"
        }
    }
}

/// AVCaptureSession 不遵循 Sendable。仅此封装可修改会话状态：
/// 所有配置、启动和停止操作均在 `queue` 上串行执行。
/// MainActor 仅将稳定的会话引用关联到 AVCaptureVideoPreviewLayer。
private final class CameraDemoEngine: @unchecked Sendable {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "com.example.AdaptiveDuoLab.camera")
    private var configured = false

    func start(completion: @escaping @Sendable (Result<Void, CameraDemoError>) -> Void) {
        queue.async { [self] in
            do {
                try configureIfNeeded()
                if !session.isRunning { session.startRunning() }
                if session.isRunning {
                    completion(.success(Void()))
                } else {
                    completion(.failure(.didNotStart))
                }
            } catch let error as CameraDemoError {
                completion(.failure(error))
            } catch {
                completion(.failure(.configuration(error.localizedDescription)))
            }
        }
    }

    func stop() {
        queue.async { [self] in
            if session.isRunning { session.stopRunning() }
        }
    }

    private func configureIfNeeded() throws {
        dispatchPrecondition(condition: .onQueue(queue))
        guard !configured else { return }
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back
        ) else { throw CameraDemoError.noRearCamera }
        let input = try AVCaptureDeviceInput(device: camera)
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        if session.canSetSessionPreset(.high) { session.sessionPreset = .high }
        guard session.canAddInput(input) else { throw CameraDemoError.cannotAddInput }
        session.addInput(input)
        configured = true
    }
}

private struct CameraPreview: UIViewRepresentable {
    let engine: CameraDemoEngine

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.attach(session: engine.session)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.updateRotation()
    }

    static func dismantleUIView(_ uiView: CameraPreviewUIView, coordinator: Void) {
        uiView.detach()
    }
}

@MainActor
private final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?

    func attach(session: AVCaptureSession) {
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = session
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back
        ) else { return }
        let coordinator = AVCaptureDevice.RotationCoordinator(device: camera, previewLayer: previewLayer)
        rotationCoordinator = coordinator
        rotationObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in self?.updateRotation() }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateRotation()
    }

    func updateRotation() {
        guard let connection = previewLayer.connection,
              let angle = rotationCoordinator?.videoRotationAngleForHorizonLevelPreview,
              connection.isVideoRotationAngleSupported(angle) else { return }
        connection.videoRotationAngle = angle
    }

    func detach() {
        rotationObservation = nil
        rotationCoordinator = nil
        previewLayer.session = nil
    }
}
