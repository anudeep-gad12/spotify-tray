import Foundation

enum SpotifyAPIError: LocalizedError, Equatable {
    case missingConfiguration
    case unauthorized
    case noDevice
    case restrictedDevice
    case premiumRequired
    case playbackControlUnavailable
    case invalidResponse
    case message(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Add your Spotify Client ID before logging in."
        case .unauthorized:
            return "Spotify authorization expired. Sign in again."
        case .noDevice:
            return "Open Spotify on this Mac."
        case .restrictedDevice:
            return "Spotify reported this device cannot be controlled."
        case .premiumRequired:
            return "Spotify Premium is required for playback control."
        case .playbackControlUnavailable:
            return "Spotify couldn't run that playback command right now."
        case .invalidResponse:
            return "Spotify returned an unexpected response."
        case .message(let message):
            return message
        }
    }
}

struct SpotifyToken: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiryDate: Date

    var isExpired: Bool {
        expiryDate <= Date().addingTimeInterval(60)
    }
}

actor SpotifyAPIClient {
    private let authManager: SpotifyAuthManager
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(authManager: SpotifyAuthManager, session: URLSession = .shared) {
        self.authManager = authManager
        self.session = session
    }

    func authorizationStateForSearch() async -> SpotifyAuthorizationState {
        await authManager.authorizationStateForSearch()
    }

    func searchTracks(query: String) async throws -> [SpotifyTrack] {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "limit", value: "8")
        ]

        let response: SpotifySearchResponse = try await sendJSONRequest(
            url: components.url!,
            method: "GET",
            token: token.accessToken
        )
        return response.tracks.items
    }

    func currentQueue() async throws -> SpotifyQueueResponse {
        let token = try await authManager.ensureAuthorized()
        return try await sendJSONRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player/queue")!,
            method: "GET",
            token: token.accessToken
        )
    }

    func recentlyPlayedTracks(limit: Int = 20) async throws -> [SpotifyRecentlyPlayedItem] {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/recently-played")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: String(max(1, min(limit, 50))))
        ]

        let response: SpotifyRecentlyPlayedResponse = try await sendJSONRequest(
            url: components.url!,
            method: "GET",
            token: token.accessToken
        )
        return response.items
    }

    func availableDevices() async throws -> [SpotifyDevice] {
        let token = try await authManager.ensureAuthorized()
        let response: SpotifyDevicesResponse = try await sendJSONRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player/devices")!,
            method: "GET",
            token: token.accessToken
        )
        return response.devices
    }

    func currentPlaybackState() async throws -> SpotifyPlaybackState? {
        let token = try await authManager.ensureAuthorized()
        return try await sendOptionalJSONRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player")!,
            method: "GET",
            token: token.accessToken
        )
    }

    func transferPlayback(deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        let body = ["device_ids": [deviceID], "play": true] as [String : Any]
        try await sendEmptyRequest(
            url: URL(string: "https://api.spotify.com/v1/me/player")!,
            method: "PUT",
            token: token.accessToken,
            body: body
        )
    }

    func play(trackURI: String, deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/play")!
        components.queryItems = [URLQueryItem(name: "device_id", value: deviceID)]
        try await sendEmptyRequest(
            url: components.url!,
            method: "PUT",
            token: token.accessToken,
            body: ["uris": [trackURI]]
        )
    }

    func queue(trackURI: String, deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/queue")!
        components.queryItems = [
            URLQueryItem(name: "uri", value: trackURI),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        try await sendEmptyRequest(
            url: components.url!,
            method: "POST",
            token: token.accessToken,
            body: nil
        )
    }

    func resume(deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/play")!
        components.queryItems = [URLQueryItem(name: "device_id", value: deviceID)]
        try await sendEmptyRequest(
            url: components.url!,
            method: "PUT",
            token: token.accessToken,
            body: nil
        )
    }

    func pause(deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/pause")!
        components.queryItems = [URLQueryItem(name: "device_id", value: deviceID)]
        try await sendEmptyRequest(
            url: components.url!,
            method: "PUT",
            token: token.accessToken,
            body: nil
        )
    }

    func skipNext(deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/next")!
        components.queryItems = [URLQueryItem(name: "device_id", value: deviceID)]
        try await sendEmptyRequest(
            url: components.url!,
            method: "POST",
            token: token.accessToken,
            body: nil
        )
    }

    func skipPrevious(deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/previous")!
        components.queryItems = [URLQueryItem(name: "device_id", value: deviceID)]
        try await sendEmptyRequest(
            url: components.url!,
            method: "POST",
            token: token.accessToken,
            body: nil
        )
    }

    func seek(positionMS: Int, deviceID: String) async throws {
        let token = try await authManager.ensureAuthorized()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/seek")!
        components.queryItems = [
            URLQueryItem(name: "position_ms", value: String(max(0, positionMS))),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        try await sendEmptyRequest(
            url: components.url!,
            method: "PUT",
            token: token.accessToken,
            body: nil
        )
    }

    private func sendJSONRequest<Response: Decodable>(
        url: URL,
        method: String,
        token: String
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        return try decoder.decode(Response.self, from: data)
    }

    private func sendOptionalJSONRequest<Response: Decodable>(
        url: URL,
        method: String,
        token: String
    ) async throws -> Response? {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyAPIError.invalidResponse
        }

        if httpResponse.statusCode == 204 {
            return nil
        }

        try validate(response: response, data: data)
        return try decoder.decode(Response.self, from: data)
    }

    private func sendEmptyRequest(
        url: URL,
        method: String,
        token: String,
        body: [String: Any]?
    ) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
    }

    private func validate(response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyAPIError.invalidResponse
        }

        let parsedMessage = spotifyErrorMessage(from: data)

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            throw SpotifyAPIError.unauthorized
        case 403:
            throw mapForbiddenError(message: parsedMessage)
        case 404:
            throw SpotifyAPIError.noDevice
        default:
            if let parsedMessage {
                if parsedMessage.localizedCaseInsensitiveContains("premium") {
                    throw SpotifyAPIError.premiumRequired
                }
                throw SpotifyAPIError.message(parsedMessage)
            }
            throw SpotifyAPIError.message("Spotify request failed (\(httpResponse.statusCode)).")
        }
    }

    private func spotifyErrorMessage(from data: Data?) -> String? {
        guard
            let data,
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }

        if let error = object["error"] as? [String: Any],
           let message = error["message"] as? String,
           !message.isEmpty
        {
            return message
        }

        if let error = object["error"] as? String, !error.isEmpty {
            return error
        }

        if let message = object["message"] as? String, !message.isEmpty {
            return message
        }

        return nil
    }

    private func mapForbiddenError(message: String?) -> SpotifyAPIError {
        guard let message, !message.isEmpty else {
            return .playbackControlUnavailable
        }

        let normalized = message.localizedLowercase

        if normalized.contains("premium") {
            return .premiumRequired
        }

        if normalized.contains("restricted") {
            return .restrictedDevice
        }

        if normalized.contains("no previous")
            || normalized.contains("nothing to skip")
            || normalized.contains("unknown command")
            || normalized.contains("failed")
        {
            return .message(message)
        }

        return .message(message)
    }
}
