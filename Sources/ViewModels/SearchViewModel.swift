import Foundation

enum NowPlayingState: Equatable {
    case hidden
    case loading
    case showing(NowPlayingSummary)
}

struct NowPlayingSummary: Equatable {
    let title: String
    let artistLine: String
    let artworkURL: URL?
    let isPlaying: Bool
    let deviceName: String?
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = "" {
        didSet {
            if !query.isEmpty {
                clearMessage()
            }
            startDebouncedSearch(for: query)
        }
    }
    @Published private(set) var selectedIndex = 0
    @Published private(set) var panelState: SearchPanelState = .helper
    @Published private(set) var inlineMessage: String?
    @Published private(set) var inlineMessageIsError = false
    @Published private(set) var loginInProgress = false
    @Published private(set) var focusRequestID = UUID()
    @Published private(set) var nowPlayingState: NowPlayingState = .hidden
    @Published var setupClientID = ""
    @Published var hasSavedClientID = false

    var onPlayRequested: ((SpotifyTrack) async -> Void)?
    var onQueueRequested: ((SpotifyTrack) async -> Void)?
    var onLoginRequested: (() -> Void)?
    var onSaveClientIDRequested: ((String) -> Void)?
    var onClearConfigurationRequested: (() -> Void)?
    var isSpotifyConfigured: (() -> Bool)?
    var currentConfiguredClientID: (() -> String)?

    private let apiClient: SpotifyAPIClient
    let redirectURI: String
    private var searchTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?
    private var nowPlayingTask: Task<Void, Never>?
    private var currentResults: [SpotifyTrack] = []
    private let debounceDelayMs: UInt64 = 400

    init(apiClient: SpotifyAPIClient, redirectURI: String) {
        self.apiClient = apiClient
        self.redirectURI = redirectURI
    }

    func prepareForPresentation() {
        clearMessage()
        searchTask?.cancel()
        nowPlayingTask?.cancel()

        guard isSpotifyConfigured?() != false else {
            nowPlayingState = .hidden
            presentSetup(clientID: currentConfiguredClientID?() ?? "", hasSavedClientID: hasSavedClientID)
            return
        }

        Task {
            let authorizationState = await apiClient.authorizationStateForSearch()

            switch authorizationState {
            case .requiresInteractiveLogin:
                currentResults = []
                selectedIndex = 0
                nowPlayingState = .hidden
                panelState = .authenticationRequired("Sign in to Spotify to search.")
            case .interactiveLoginInProgress:
                currentResults = []
                selectedIndex = 0
                nowPlayingState = .hidden
                panelState = .authenticationRequired("Finish Spotify login in the browser.")
            case .ready:
                refreshNowPlaying()
                if query.isEmpty {
                    currentResults = []
                    selectedIndex = 0
                    panelState = .helper
                } else {
                    performSearch(for: query)
                }
            }
        }
    }

    func setInlineMessage(_ message: String, isError: Bool = true) {
        inlineMessage = message
        inlineMessageIsError = isError
    }

    func moveSelection(by offset: Int) {
        guard !currentResults.isEmpty else { return }
        selectedIndex = max(0, min(currentResults.count - 1, selectedIndex + offset))
    }

    func select(index: Int) {
        guard currentResults.indices.contains(index) else { return }
        selectedIndex = index
    }

    func playSelected() {
        guard currentResults.indices.contains(selectedIndex) else { return }
        let track = currentResults[selectedIndex]
        Task { await onPlayRequested?(track) }
    }

    func queueSelected() {
        guard currentResults.indices.contains(selectedIndex) else { return }
        let track = currentResults[selectedIndex]
        Task { await onQueueRequested?(track) }
    }

    func requestLogin() {
        guard !loginInProgress else { return }
        onLoginRequested?()
    }

    func retrySearchIfNeeded() {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        performSearch(for: query)
    }

    func setLoginInProgress(_ inProgress: Bool) {
        loginInProgress = inProgress
    }

    func presentSetup(clientID: String, hasSavedClientID: Bool) {
        searchTask?.cancel()
        currentResults = []
        selectedIndex = 0
        nowPlayingState = .hidden
        setupClientID = clientID
        self.hasSavedClientID = hasSavedClientID
        panelState = .setupRequired
        requestSearchFocus()
    }

    func saveClientID() {
        onSaveClientIDRequested?(setupClientID)
    }

    func clearConfiguration() {
        onClearConfigurationRequested?()
    }

    func requestSearchFocus() {
        focusRequestID = UUID()
    }

    func clearMessage() {
        inlineMessage = nil
        inlineMessageIsError = false
    }

    func clearQuery() {
        query = ""
    }

    func refreshNowPlaying() {
        nowPlayingTask?.cancel()

        guard canShowNowPlaying else {
            nowPlayingState = .hidden
            return
        }

        nowPlayingState = .loading
        nowPlayingTask = Task {
            do {
                let playbackState = try await apiClient.currentPlaybackState()
                guard !Task.isCancelled else { return }
                guard let summary = Self.makeNowPlayingSummary(from: playbackState) else {
                    nowPlayingState = .hidden
                    return
                }
                nowPlayingState = .showing(summary)
            } catch {
                guard !Task.isCancelled else { return }
                nowPlayingState = .hidden
            }
        }
    }

    func clearNowPlaying() {
        nowPlayingTask?.cancel()
        nowPlayingState = .hidden
    }
}

extension SearchViewModel {
    private func startDebouncedSearch(for query: String) {
        debounceTask?.cancel()
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            currentResults = []
            selectedIndex = 0
            panelState = isSpotifyConfigured?() == false ? .setupRequired : .helper
            return
        }

        debounceTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(debounceDelayMs))
                guard !Task.isCancelled else { return }
                performSearch(for: trimmedQuery)
            } catch {
                // Task was cancelled, ignore
            }
        }
    }

    private func performSearch(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            currentResults = []
            selectedIndex = 0
            panelState = isSpotifyConfigured?() == false ? .setupRequired : .helper
            return
        }

        searchTask = Task {
            guard self.isSpotifyConfigured?() != false else {
                self.presentSetup(clientID: self.currentConfiguredClientID?() ?? "", hasSavedClientID: self.hasSavedClientID)
                return
            }

            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }

            let authorizationState = await apiClient.authorizationStateForSearch()
            guard !Task.isCancelled else { return }

            switch authorizationState {
            case .requiresInteractiveLogin:
                currentResults = []
                nowPlayingState = .hidden
                panelState = .authenticationRequired("Sign in to Spotify to search.")
                return
            case .interactiveLoginInProgress:
                currentResults = []
                nowPlayingState = .hidden
                panelState = .authenticationRequired("Finish Spotify login in the browser.")
                return
            case .ready:
                panelState = .loading
            }

            do {
                let tracks = try await apiClient.searchTracks(query: trimmedQuery)
                guard !Task.isCancelled else { return }
                currentResults = tracks
                selectedIndex = 0
                panelState = tracks.isEmpty ? .empty : .results(tracks)
            } catch {
                guard !Task.isCancelled else { return }
                currentResults = []
                panelState = .error(error.localizedDescription)
            }
        }
    }

    private var canShowNowPlaying: Bool {
        switch panelState {
        case .setupRequired, .authenticationRequired:
            return false
        default:
            return true
        }
    }

    private static func makeNowPlayingSummary(from playbackState: SpotifyPlaybackState?) -> NowPlayingSummary? {
        guard let playbackState, let item = playbackState.item else {
            return nil
        }

        return NowPlayingSummary(
            title: item.name,
            artistLine: item.artistLine,
            artworkURL: item.artworkURL,
            isPlaying: playbackState.isPlaying,
            deviceName: playbackState.device?.name
        )
    }
}
