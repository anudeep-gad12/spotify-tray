import AppKit

@MainActor
final class StatusBarController: NSObject {
    private let environment: AppEnvironment
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    init(environment: AppEnvironment) {
        self.environment = environment
        super.init()
    }

    func install() {
        guard let button = statusItem.button else {
            return
        }

        if let symbolImage = NSImage(
            systemSymbolName: "music.note.list",
            accessibilityDescription: "SpotifyTray"
        ) {
            let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let image = symbolImage.withSymbolConfiguration(configuration) ?? symbolImage
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageOnly
            button.title = ""
        } else {
            button.image = nil
            button.title = "♪"
        }

        refreshMenu()
    }

    func refreshMenu() {
        let menu = NSMenu()
        menu.addItem(makeItem(title: "Open Search", action: #selector(openSearch)))
        menu.addItem(makeItem(title: "Spotify Setup", action: #selector(openSetup)))
        menu.addItem(makeItem(title: "Login / Reconnect", action: #selector(loginReconnect)))
        menu.addItem(makeItem(title: "Sign Out", action: #selector(signOut)))
        menu.addItem(makeItem(title: "Open Spotify", action: #selector(openSpotify)))
        menu.addItem(.separator())
        menu.addItem(makeItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            state: environment.launchAtLoginEnabled ? .on : .off
        ))
        if environment.canUseSparkleUpdater {
            menu.addItem(.separator())
            menu.addItem(makeItem(title: "Check for Updates…", action: #selector(checkForUpdates)))
        }
        menu.addItem(.separator())
        menu.addItem(makeItem(title: "Quit SpotifyTray", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func makeItem(
        title: String,
        action: Selector,
        keyEquivalent: String = "",
        state: NSControl.StateValue = .off
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        item.state = state
        return item
    }

    @objc private func openSearch() {
        environment.togglePanel()
    }

    @objc private func loginReconnect() {
        environment.loginReconnect()
    }

    @objc private func openSetup() {
        environment.openSetup()
    }

    @objc private func signOut() {
        environment.signOut()
    }

    @objc private func openSpotify() {
        environment.openSpotify()
    }

    @objc private func toggleLaunchAtLogin() {
        environment.toggleLaunchAtLogin()
    }

    @objc private func checkForUpdates() {
        environment.checkForUpdates()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
