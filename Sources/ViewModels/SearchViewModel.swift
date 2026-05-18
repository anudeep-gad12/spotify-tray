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
                activeMode = .search
                clearMessage()
            }
            startDebouncedSearch(for: query)
        }
    }
    @Published private(set) var activeMode: SearchPanelMode = .search
    @Published private(set) var selectedIndex = 0
    @Published private(set) var panelState: SearchPanelState = .helper
    @Published private(set) var recentState: TrackCollectionState = .idle
    @Published private(set) var queueState: TrackCollectionState = .idle
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
    private var recentTask: Task<Void, Never>?
    private var queueTask: Task<Void, Never>?
    private var currentResults: [SpotifyTrack] = []
    private let debounceDelayMs: UInt64 = 400

    init(apiClient: SpotifyAPIClient, redirectURI: String) {
        self.apiClient = apiClient
        self.redirectURI = redirectURI
    }

    var canMoveSelection: Bool {
        !activeItems.isEmpty
    }

    var canSwitchModes: Bool {
        switch panelState {
        case .setupRequired, .authenticationRequired:
            return false
        default:
            return true
        }
    }

    var searchItems: [TrackListItem] {
        currentResults.map { TrackListItem(track: $0) }
    }

    func prepareForPresentation() {
        clearMessage()
        searchTask?.cancel()
        nowPlayingTask?.cancel()
        recentTask?.cancel()
        queueTask?.cancel()
        recentState = .idle
        queueState = .idle

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
                switch activeMode {
                case .search:
                    if query.isEmpty {
                        currentResults = []
                        selectedIndex = 0
                        panelState = .helper
                    } else {
                        performSearch(for: query)
                    }
                case .recent:
                    fetchRecentTracks(force: true)
                case .queue:
                    fetchQueue(force: true)
                }
            }
        }
    }

    func setMode(_ mode: SearchPanelMode) {
        guard activeMode != mode else { return }
        activeMode = mode
        selectedIndex = 0
        clearMessage()

        switch mode {
        case .search:
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                currentResults = []
                panelState = isSpotifyConfigured?() == false ? .setupRequired : .helper
            } else {
                performSearch(for: query)
            }
        case .recent:
            fetchRecentTracks(force: false)
        case .queue:
            fetchQueue(force: false)
        }
    }

    func cycleMode(backwards: Bool = false) {
        let modes = SearchPanelMode.allCases
        guard let currentIndex = modes.firstIndex(of: activeMode) else {
            setMode(.search)
            return
        }

        let nextIndex: Int
        if backwards {
            nextIndex = currentIndex == modes.startIndex ? modes.index(before: modes.endIndex) : modes.index(before: currentIndex)
        } else {
            nextIndex = modes.index(after: currentIndex) == modes.endIndex ? modes.startIndex : modes.index(after: currentIndex)
        }
        setMode(modes[nextIndex])
    }

    func setInlineMessage(_ message: String, isError: Bool = true) {
        inlineMessage = message
        inlineMessageIsError = isError
    }

    func moveSelection(by offset: Int) {
        let count = activeItems.count
        guard count > 0 else { return }
        selectedIndex = max(0, min(count - 1, selectedIndex + offset))
    }

    func select(index: Int) {
        guard activeItems.indices.contains(index) else { return }
        selectedIndex = index
    }

    func playSelected() {
        guard let track = selectedTrack else { return }
        Task { await onPlayRequested?(track) }
    }

    func queueSelected() {
        guard let track = selectedTrack else { return }
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
        recentTask?.cancel()
        queueTask?.cancel()
        activeMode = .search
        currentResults = []
        recentState = .idle
        queueState = .idle
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

    func refreshQueueAfterPlaybackChange() {
        if activeMode == .queue || queueState.hasLoadedContent {
            fetchQueue(force: true)
        }
    }

    func clearNowPlaying() {
        nowPlayingTask?.cancel()
        nowPlayingState = .hidden
    }
}

extension SearchViewModel {
    private var selectedTrack: SpotifyTrack? {
        guard activeItems.indices.contains(selectedIndex) else { return nil }
        return activeItems[selectedIndex].track
    }

    private var activeItems: [TrackListItem] {
        switch activeMode {
        case .search:
            if case .results = panelState { return searchItems }
            return []
        case .recent:
            if case .loaded(let items) = recentState { return items }
            return []
        case .queue:
            if case .loaded(let items) = queueState { return items }
            return []
        }
    }

    private func startDebouncedSearch(for query: String) {
        debounceTask?.cancel()
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            currentResults = []
            if activeMode == .search {
                selectedIndex = 0
                panelState = isSpotifyConfigured?() == false ? .setupRequired : .helper
            }
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
            if activeMode == .search {
                selectedIndex = 0
                panelState = isSpotifyConfigured?() == false ? .setupRequired : .helper
            }
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

    private func fetchRecentTracks(force: Bool) {
        guard isSpotifyConfigured?() != false else {
            presentSetup(clientID: currentConfiguredClientID?() ?? "", hasSavedClientID: hasSavedClientID)
            return
        }
        if !force, recentState.shouldSkipFetch { return }

        recentTask?.cancel()
        recentState = .loading
        selectedIndex = 0
        recentTask = Task {
            do {
                let items = try await apiClient.recentlyPlayedTracks(limit: 20)
                guard !Task.isCancelled else { return }
                let rows = items.map { item in
                    TrackListItem(
                        id: "recent-\(item.playedAt?.timeIntervalSince1970 ?? 0)-\(item.track.id)",
                        track: item.track,
                        metadata: Self.relativePlayedTime(from: item.playedAt)
                    )
                }
                recentState = rows.isEmpty ? .empty : .loaded(rows)
                selectedIndex = 0
            } catch {
                guard !Task.isCancelled else { return }
                recentState = .error(Self.libraryErrorMessage(error, fallback: "Couldn't load recent tracks."))
            }
        }
    }

    private func fetchQueue(force: Bool) {
        guard isSpotifyConfigured?() != false else {
            presentSetup(clientID: currentConfiguredClientID?() ?? "", hasSavedClientID: hasSavedClientID)
            return
        }
        if !force, queueState.shouldSkipFetch { return }

        queueTask?.cancel()
        queueState = .loading
        selectedIndex = 0
        queueTask = Task {
            do {
                let response = try await apiClient.currentQueue()
                guard !Task.isCancelled else { return }
                var rows: [TrackListItem] = []
                if let currentlyPlaying = response.currentlyPlaying {
                    rows.append(
                        TrackListItem(
                            id: "queue-current-\(currentlyPlaying.id)",
                            track: currentlyPlaying,
                            metadata: "Now playing"
                        )
                    )
                }
                let upcomingTracks = Self.deduplicatedQueueTracks(
                    response.queue,
                    excludingCurrentTrackID: response.currentlyPlaying?.id
                )
                rows.append(
                    contentsOf: upcomingTracks.enumerated().map { index, track in
                        TrackListItem(
                            id: "queue-\(index)-\(track.id)",
                            track: track,
                            metadata: "#\(index + 1) in queue"
                        )
                    }
                )
                queueState = rows.isEmpty ? .empty : .loaded(rows)
                selectedIndex = 0
            } catch {
                guard !Task.isCancelled else { return }
                queueState = .error(Self.libraryErrorMessage(error, fallback: "Couldn't load the queue."))
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

    private static func relativePlayedTime(from date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Played \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    private static func libraryErrorMessage(_ error: Error, fallback: String) -> String {
        if let apiError = error as? SpotifyAPIError {
            switch apiError {
            case .unauthorized:
                return "Reconnect Spotify to enable this view."
            case .message(let message) where message.localizedCaseInsensitiveContains("scope"):
                return "Reconnect Spotify to grant the new permission."
            default:
                return apiError.localizedDescription
            }
        }
        return error.localizedDescription.isEmpty ? fallback : error.localizedDescription
    }

    nonisolated static func deduplicatedQueueTracks(
        _ tracks: [SpotifyTrack],
        excludingCurrentTrackID currentTrackID: String?
    ) -> [SpotifyTrack] {
        var seenTrackIDs = Set<String>()
        if let currentTrackID {
            seenTrackIDs.insert(currentTrackID)
        }

        return tracks.filter { track in
            guard !seenTrackIDs.contains(track.id) else { return false }
            seenTrackIDs.insert(track.id)
            return true
        }
    }
}

private extension TrackCollectionState {
    var shouldSkipFetch: Bool {
        switch self {
        case .loading, .loaded, .empty:
            return true
        case .idle, .error:
            return false
        }
    }

    var hasLoadedContent: Bool {
        if case .loaded = self { return true }
        return false
    }
}
