import AppKit
import Carbon
import SwiftUI

private final class SearchPanelWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
final class SearchPanelController: NSWindowController, NSWindowDelegate {
    private let environment: AppEnvironment
    private var localEventMonitor: Any?

    var isVisible: Bool {
        window?.isVisible == true
    }

    init(environment: AppEnvironment) {
        self.environment = environment

        let panel = SearchPanelWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 680),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.moveToActiveSpace, .transient]
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.delegate = nil

        let rootView = SearchPanelView(
            viewModel: environment.searchViewModel
        )
        let hostingController = NSHostingController(rootView: rootView)
        hostingController.view.wantsLayer = true
        panel.contentViewController = hostingController

        super.init(window: panel)

        panel.delegate = self
        installLocalMonitor()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggle() {
        AppLogger.shared.log("toggle requested visible=\(isVisible)", category: "panel")
        isVisible ? close() : show()
    }

    func show() {
        guard let window else { return }
        AppLogger.shared.log("show begin", category: "panel")
        position(window: window)
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window.makeKeyAndOrderFront(nil)
        environment.searchViewModel.requestSearchFocus()
        AppLogger.shared.log("show end", category: "panel")
    }

    override func close() {
        AppLogger.shared.log("close begin", category: "panel")
        super.close()
        window?.orderOut(nil)
        AppLogger.shared.log("close end", category: "panel")
    }

    func focusSearchField() {
        environment.searchViewModel.requestSearchFocus()
    }

    func windowDidResignKey(_ notification: Notification) {
        if environment.authManager.isInteractiveAuthInProgress {
            AppLogger.shared.log("windowDidResignKey ignored during auth", category: "panel")
            return
        }
        AppLogger.shared.log("windowDidResignKey", category: "panel")
        close()
    }

    private func installLocalMonitor() {
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.isVisible else { return event }

            switch Int(event.keyCode) {
            case kVK_Escape:
                self.environment.closePanel()
                return nil
            case kVK_UpArrow:
                if case .results = self.environment.searchViewModel.panelState {
                    self.environment.searchViewModel.moveSelection(by: -1)
                    return nil
                }
                return event
            case kVK_DownArrow:
                if case .results = self.environment.searchViewModel.panelState {
                    self.environment.searchViewModel.moveSelection(by: 1)
                    return nil
                }
                return event
            case kVK_Return:
                if case .results = self.environment.searchViewModel.panelState {
                    if event.modifierFlags.contains(.command) {
                        self.environment.searchViewModel.queueSelected()
                    } else {
                        self.environment.searchViewModel.playSelected()
                    }
                    return nil
                }
                return event
            default:
                return event
            }
        }
    }

    private func position(window: NSWindow) {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let originX = screenFrame.midX - window.frame.width / 2
        let originY = screenFrame.maxY - window.frame.height - 80

        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }
}
