import Foundation

enum SearchFocusMode: Equatable {
    case mainList
    case albumDetail
}

enum SearchResultRow: Identifiable, Equatable {
    case track(SpotifyTrack)
    case album(SpotifyAlbumItem)

    var id: String {
        switch self {
        case .track(let t): return t.id
        case .album(let a): return a.id
        }
    }

    var albumItem: SpotifyAlbumItem? {
        if case .album(let album) = self { return album }
        return nil
    }

    var track: SpotifyTrack? {
        if case .track(let t) = self { return t }
        return nil
    }
}

enum SearchPanelState: Equatable {
    case setupRequired
    case helper
    case loading
    case authenticationRequired(String)
    case results([SearchResultRow])
    case empty
    case error(String)
}

enum SearchPanelMode: String, CaseIterable, Identifiable, Equatable {
    case search
    case recent
    case queue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .search:
            return "Search"
        case .recent:
            return "Recent"
        case .queue:
            return "Queue"
        }
    }
}

enum TrackCollectionState: Equatable {
    case idle
    case loading
    case loaded([TrackListItem])
    case empty
    case error(String)
}

struct TrackListItem: Identifiable, Equatable {
    let id: String
    let track: SpotifyTrack
    let metadata: String?

    init(id: String? = nil, track: SpotifyTrack, metadata: String? = nil) {
        self.id = id ?? track.id
        self.track = track
        self.metadata = metadata
    }
}
