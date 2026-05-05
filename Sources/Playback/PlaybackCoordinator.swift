import Foundation

actor PlaybackCoordinator {
    private let apiClient: SpotifyAPIClient

    init(apiClient: SpotifyAPIClient) {
        self.apiClient = apiClient
    }

    func play(track: SpotifyTrack) async throws {
        let device = try await resolvePlaybackDevice()
        if !device.isActive {
            try await apiClient.transferPlayback(deviceID: device.id)
        }
        try await apiClient.play(trackURI: track.uri, deviceID: device.id)
    }

    func queue(track: SpotifyTrack) async throws {
        let device = try await resolvePlaybackDevice()
        try await apiClient.queue(trackURI: track.uri, deviceID: device.id)
    }

    func playPause() async throws {
        if let playbackState = try await apiClient.currentPlaybackState(),
           playbackState.isPlaying {
            let device = try resolvedAddressableDevice(from: playbackState.device)
            try await apiClient.pause(deviceID: device.id)
            return
        }

        let device = try await resolvePlaybackDevice()
        if !device.isActive {
            try await apiClient.transferPlayback(deviceID: device.id)
        }
        try await apiClient.resume(deviceID: device.id)
    }

    func nextTrack() async throws {
        let device = try await resolvePlaybackDevice()
        if !device.isActive {
            try await apiClient.transferPlayback(deviceID: device.id)
        }
        try await apiClient.skipNext(deviceID: device.id)
    }

    func previousTrack() async throws {
        let device = try await resolvePlaybackDevice()
        if !device.isActive {
            try await apiClient.transferPlayback(deviceID: device.id)
        }
        try await apiClient.skipPrevious(deviceID: device.id)
    }

    func resolvePlaybackDevice(from devices: [SpotifyDevice]) throws -> AddressableSpotifyDevice {
        guard let device = PlaybackCoordinator.preferredDevice(from: devices) else {
            throw SpotifyAPIError.noDevice
        }
        return try resolvedAddressableDevice(from: device)
    }

    private func resolvePlaybackDevice() async throws -> AddressableSpotifyDevice {
        let devices = try await apiClient.availableDevices()
        return try resolvePlaybackDevice(from: devices)
    }

    private func resolvedAddressableDevice(from device: SpotifyDevice?) throws -> AddressableSpotifyDevice {
        guard let device else {
            throw SpotifyAPIError.noDevice
        }
        guard !device.isRestricted else {
            throw SpotifyAPIError.restrictedDevice
        }
        guard let id = device.id, !id.isEmpty else {
            throw SpotifyAPIError.noDevice
        }
        return AddressableSpotifyDevice(
            id: id,
            isActive: device.isActive
        )
    }

    static func preferredDevice(from devices: [SpotifyDevice]) -> SpotifyDevice? {
        let addressableDevices = devices.filter { ($0.id?.isEmpty == false) }

        if let activeComputer = addressableDevices.first(where: { $0.type == "Computer" && $0.isActive }) {
            return activeComputer
        }

        if let namedComputer = addressableDevices.first(where: { $0.type == "Computer" && $0.name.localizedCaseInsensitiveContains(Host.current().localizedName ?? "") }) {
            return namedComputer
        }

        return addressableDevices.first(where: { $0.type == "Computer" })
    }
}

struct AddressableSpotifyDevice {
    let id: String
    let isActive: Bool
}
