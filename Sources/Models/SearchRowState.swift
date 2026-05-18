import Foundation

enum SearchPanelState: Equatable {
    case setupRequired
    case helper
    case loading
    case authenticationRequired(String)
    case results([SpotifyTrack])
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
