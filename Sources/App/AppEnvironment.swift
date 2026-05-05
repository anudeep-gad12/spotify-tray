import AppKit
import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var launchAtLoginEnabled = false

    let configuration: AppConfiguration
    let clientConfigurationStore: ClientConfigurationStore
    let authManager: SpotifyAuthManager
    let apiClient: SpotifyAPIClient
    let playbackCoordinator: PlaybackCoordinator
    let launchAtLoginManager = LaunchAtLoginManager()
    let searchViewModel: SearchViewModel

    private weak var panelController: SearchPanelController?
    private weak var statusBarController: StatusBarController?

    init() {
        let configuration = AppConfiguration.load()
        let clientConfigurationStore = ClientConfigurationStore(bundledClientID: configuration.bundledSpotifyClientID)
        self.configuration = configuration
        self.clientConfigurationStore = clientConfigurationStore
        AppLogger.shared.configure(logFileURL: configuration.logFileURL)
        AppLogger.shared.log("appSupportDirectory=\(configuration.appSupportDirectory.path)", category: "app")
        AppLogger.shared.log("logFile=\(configuration.logFileURL.path)", category: "app")
        let keychain = KeychainStore(
            service: "app.spotifytray",
            fileURL: configuration.tokenFileURL
        )
        authManager = SpotifyAuthManager(
            configuration: configuration,
            keychain: keychain,
            clientIDProvider: { [clientConfigurationStore] in
                clientConfigurationStore.currentClientID()
            }
        )
        apiClient = SpotifyAPIClient(authManager: authManager)
        playbackCoordinator = PlaybackCoordinator(apiClient: apiClient)
        searchViewModel = SearchViewModel(apiClient: apiClient, redirectURI: configuration.redirectURI)

        authManager.onAuthorizationSucceeded = { [weak self] in
            AppLogger.shared.log("authorization success callback", category: "auth")
            NSApp.activate(ignoringOtherApps: true)
            self?.searchViewModel.prepareForPresentation()
            self?.panelController?.show()
            self?.searchViewModel.retrySearchIfNeeded()
        }

        searchViewModel.onPlayRequested = { [weak self] track in
            await self?.play(track: track)
        }
        searchViewModel.onQueueRequested = { [weak self] track in
            await self?.queue(track: track)
        }
        searchViewModel.onLoginRequested = { [weak self] in
            self?.loginReconnect()
        }
        searchViewModel.isSpotifyConfigured = { [weak self] in
            self?.clientConfigurationStore.hasConfiguredClientID ?? false
        }
        searchViewModel.currentConfiguredClientID = { [weak self] in
            self?.clientConfigurationStore.currentClientID() ?? ""
        }
        searchViewModel.hasSavedClientID = clientConfigurationStore.hasUserConfiguredClientID
        searchViewModel.onSaveClientIDRequested = { [weak self] clientID in
            self?.saveClientID(clientID)
        }
        searchViewModel.onClearConfigurationRequested = { [weak self] in
            self?.clearSpotifyConfiguration()
        }
    }

    func bind(panelController: SearchPanelController, statusBarController: StatusBarController) {
        self.panelController = panelController
        self.statusBarController = statusBarController
    }

    func configureLaunchAtLogin() {
        AppLogger.shared.log("configureLaunchAtLogin", category: "app")
        launchAtLoginEnabled = launchAtLoginManager.currentStatus
        if !launchAtLoginEnabled {
            do {
                try launchAtLoginManager.setEnabled(true)
                launchAtLoginEnabled = true
            } catch {
                searchViewModel.setInlineMessage(error.localizedDescription)
            }
        }
        statusBarController?.refreshMenu()
    }

    func togglePanel() {
        AppLogger.shared.log("togglePanel visible=\(panelController?.isVisible == true)", category: "panel")
        panelController?.toggle()
        if panelController?.isVisible == true {
            searchViewModel.prepareForPresentation()
            panelController?.focusSearchField()
        }
    }

    func closePanel() {
        AppLogger.shared.log("closePanel", category: "panel")
        panelController?.close()
    }

    func focusSearchField() {
        panelController?.focusSearchField()
    }

    func openSetup() {
        searchViewModel.presentSetup(
            clientID: clientConfigurationStore.currentClientID(),
            hasSavedClientID: clientConfigurationStore.hasUserConfiguredClientID
        )
        panelController?.show()
    }

    func playPause() {
        guard clientConfigurationStore.hasConfiguredClientID else {
            openSetup()
            searchViewModel.setInlineMessage("Add your Spotify Client ID before using transport controls.")
            return
        }
        Task {
            AppLogger.shared.log("playPause requested", category: "transport")
            do {
                try await playbackCoordinator.playPause()
                AppLogger.shared.log("playPause succeeded", category: "transport")
            } catch {
                AppLogger.shared.log("playPause failed error=\(error.localizedDescription)", category: "transport")
                searchViewModel.setInlineMessage(error.localizedDescription)
                panelController?.show()
            }
        }
    }

    func nextTrack() {
        guard clientConfigurationStore.hasConfiguredClientID else {
            openSetup()
            searchViewModel.setInlineMessage("Add your Spotify Client ID before using transport controls.")
            return
        }
        Task {
            AppLogger.shared.log("nextTrack requested", category: "transport")
            do {
                try await playbackCoordinator.nextTrack()
                AppLogger.shared.log("nextTrack succeeded", category: "transport")
            } catch {
                AppLogger.shared.log("nextTrack failed error=\(error.localizedDescription)", category: "transport")
                searchViewModel.setInlineMessage(error.localizedDescription)
                panelController?.show()
            }
        }
    }

    func previousTrack() {
        guard clientConfigurationStore.hasConfiguredClientID else {
            openSetup()
            searchViewModel.setInlineMessage("Add your Spotify Client ID before using transport controls.")
            return
        }
        Task {
            AppLogger.shared.log("previousTrack requested", category: "transport")
            do {
                try await playbackCoordinator.previousTrack()
                AppLogger.shared.log("previousTrack succeeded", category: "transport")
            } catch {
                AppLogger.shared.log("previousTrack failed error=\(error.localizedDescription)", category: "transport")
                searchViewModel.setInlineMessage(error.localizedDescription)
                panelController?.show()
            }
        }
    }

    func loginReconnect() {
        guard clientConfigurationStore.hasConfiguredClientID else {
            openSetup()
            searchViewModel.setInlineMessage("Enter your Spotify Client ID before signing in.")
            return
        }
        guard !searchViewModel.loginInProgress else { return }
        searchViewModel.setLoginInProgress(true)

        Task {
            AppLogger.shared.log("loginReconnect started", category: "auth")
            do {
                _ = try await authManager.ensureAuthorized(forceReauthentication: true)
                AppLogger.shared.log("loginReconnect succeeded", category: "auth")
                searchViewModel.setInlineMessage("Spotify connected.")
                searchViewModel.prepareForPresentation()
                panelController?.show()
            } catch {
                AppLogger.shared.log("loginReconnect failed: \(error.localizedDescription)", category: "auth")
                searchViewModel.setInlineMessage(error.localizedDescription)
                panelController?.show()
            }

            searchViewModel.setLoginInProgress(false)

            if case .authenticationRequired = searchViewModel.panelState {
                if searchViewModel.inlineMessage == nil {
                    searchViewModel.setInlineMessage("Spotify login did not complete.")
                }
            }
        }
    }

    func openSpotify() {
        if let spotifyURL = URL(string: "spotify:") {
            NSWorkspace.shared.open(spotifyURL)
        }
    }

    func toggleLaunchAtLogin() {
        do {
            try launchAtLoginManager.setEnabled(!launchAtLoginEnabled)
            launchAtLoginEnabled = launchAtLoginManager.currentStatus
            statusBarController?.refreshMenu()
        } catch {
            searchViewModel.setInlineMessage(error.localizedDescription)
        }
    }

    func signOut() {
        do {
            try authManager.clearStoredAuthorization()
            searchViewModel.setInlineMessage("Spotify login cleared.", isError: false)
            searchViewModel.prepareForPresentation()
        } catch {
            searchViewModel.setInlineMessage(error.localizedDescription)
        }
    }

    private func play(track: SpotifyTrack) async {
        do {
            AppLogger.shared.log("play requested track=\(track.id)", category: "playback")
            _ = try await authManager.ensureAuthorized()
            try await playbackCoordinator.play(track: track)
            AppLogger.shared.log("play succeeded track=\(track.id)", category: "playback")
            searchViewModel.setInlineMessage("Playing \(track.name)", isError: false)
            searchViewModel.clearQuery()
            closePanel()
        } catch {
            AppLogger.shared.log("play failed track=\(track.id) error=\(error.localizedDescription)", category: "playback")
            searchViewModel.setInlineMessage(error.localizedDescription)
            panelController?.show()
            focusSearchField()
        }
    }

    private func queue(track: SpotifyTrack) async {
        do {
            AppLogger.shared.log("queue requested track=\(track.id)", category: "playback")
            _ = try await authManager.ensureAuthorized()
            try await playbackCoordinator.queue(track: track)
            AppLogger.shared.log("queue succeeded track=\(track.id)", category: "playback")
            searchViewModel.setInlineMessage("Queued \(track.name)", isError: false)
            searchViewModel.clearQuery()
            // Auto-clear the message after 1.5 seconds
            Task {
                try? await Task.sleep(for: .seconds(1))
                searchViewModel.clearMessage()
            }
        } catch {
            AppLogger.shared.log("queue failed track=\(track.id) error=\(error.localizedDescription)", category: "playback")
            searchViewModel.setInlineMessage(error.localizedDescription)
            panelController?.show()
            focusSearchField()
        }
    }

    private func saveClientID(_ clientID: String) {
        let trimmed = clientID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchViewModel.setInlineMessage("Paste your Spotify Client ID first.")
            searchViewModel.presentSetup(clientID: trimmed, hasSavedClientID: clientConfigurationStore.hasUserConfiguredClientID)
            return
        }

        do {
            try clientConfigurationStore.saveClientID(trimmed)
            try authManager.clearStoredAuthorization()
            searchViewModel.hasSavedClientID = clientConfigurationStore.hasUserConfiguredClientID
            searchViewModel.setInlineMessage("Client ID saved. Connect Spotify.", isError: false)
            searchViewModel.prepareForPresentation()
            panelController?.show()
        } catch {
            searchViewModel.setInlineMessage(error.localizedDescription)
            searchViewModel.presentSetup(clientID: trimmed, hasSavedClientID: clientConfigurationStore.hasUserConfiguredClientID)
        }
    }

    private func clearSpotifyConfiguration() {
        do {
            try clientConfigurationStore.clearClientID()
            try authManager.clearStoredAuthorization()
            searchViewModel.hasSavedClientID = false
            searchViewModel.setInlineMessage("Saved Spotify setup cleared.", isError: false)
            searchViewModel.presentSetup(clientID: "", hasSavedClientID: false)
            panelController?.show()
        } catch {
            searchViewModel.setInlineMessage(error.localizedDescription)
        }
    }
}
