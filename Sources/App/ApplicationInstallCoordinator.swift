import AppKit

@MainActor
final class ApplicationInstallCoordinator {
    private let launchAtLoginManager = LaunchAtLoginManager()

    func promptToInstallInApplicationsFolderIfNeeded() {
        guard ApplicationInstallLocation.needsInstallToApplicationsFolder else {
            return
        }

        let alert = NSAlert()
        alert.messageText = "Move SpotifyTray to Applications?"
        alert.informativeText = """
        You only need to do this once. After SpotifyTray is in Applications, updates install automatically and you will not see this again.

        This happens when the app is opened from Downloads or a disk image instead of Applications.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Move to Applications")
        alert.addButton(withTitle: "Not Now")

        guard alert.runModal() == .alertFirstButtonReturn else {
            return
        }

        moveToApplicationsFolder()
    }

    func moveToApplicationsFolder() {
        do {
            if launchAtLoginManager.currentStatus {
                try launchAtLoginManager.setEnabled(false)
            }

            let installedURL = try ApplicationInstallLocation.installToApplicationsFolder()

            guard NSWorkspace.shared.open(installedURL) else {
                throw InstallLocationError.couldNotOpenInstalledCopy
            }

            NSApp.terminate(nil)
        } catch {
            let alert = NSAlert(error: error)
            alert.messageText = "Could not move SpotifyTray"
            alert.runModal()
        }
    }
}
