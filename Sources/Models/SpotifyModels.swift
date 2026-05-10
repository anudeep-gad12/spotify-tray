import Foundation

struct SpotifyTrack: Decodable, Identifiable, Equatable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let uri: String
    let durationMs: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, uri
        case durationMs = "duration_ms"
    }

    var artistLine: String {
        artists.map(\.name).joined(separator: ", ")
    }

    var artworkURL: URL? {
        album.images.first?.url
    }
}

struct SpotifyArtist: Decodable, Equatable {
    let name: String
}

struct SpotifyAlbum: Decodable, Equatable {
    let name: String
    let images: [SpotifyImage]
}

struct SpotifyImage: Decodable, Equatable {
    let url: URL
    let width: Int?
    let height: Int?
}

struct SpotifySearchResponse: Decodable {
    let tracks: SpotifyTrackContainer
}

struct SpotifyTrackContainer: Decodable {
    let items: [SpotifyTrack]
}

struct SpotifyDevice: Decodable, Equatable {
    let id: String?
    let isActive: Bool
    let isRestricted: Bool
    let name: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isRestricted = "is_restricted"
        case name
        case type
    }
}

struct SpotifyDevicesResponse: Decodable {
    let devices: [SpotifyDevice]
}

struct SpotifyPlaybackState: Decodable, Equatable {
    let device: SpotifyDevice?
    let isPlaying: Bool
    let progressMs: Int?
    let item: SpotifyPlaybackItem?

    enum CodingKeys: String, CodingKey {
        case device
        case isPlaying = "is_playing"
        case progressMs = "progress_ms"
        case item
    }
}

struct SpotifyPlaybackItem: Decodable, Equatable {
    let id: String?
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyPlaybackAlbum?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, uri
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        artists = try container.decodeIfPresent([SpotifyArtist].self, forKey: .artists) ?? []
        album = try container.decodeIfPresent(SpotifyPlaybackAlbum.self, forKey: .album)
        uri = try container.decodeIfPresent(String.self, forKey: .uri)
    }

    var artistLine: String {
        let names = artists.map(\.name).filter { !$0.isEmpty }
        return names.isEmpty ? "Spotify" : names.joined(separator: ", ")
    }

    var artworkURL: URL? {
        album?.images.first?.url
    }
}

struct SpotifyPlaybackAlbum: Decodable, Equatable {
    let name: String?
    let images: [SpotifyImage]

    enum CodingKeys: String, CodingKey {
        case name, images
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        images = try container.decodeIfPresent([SpotifyImage].self, forKey: .images) ?? []
    }
}
