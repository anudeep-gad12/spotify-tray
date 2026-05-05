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
