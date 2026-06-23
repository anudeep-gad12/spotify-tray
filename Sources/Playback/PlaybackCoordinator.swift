import Foundation

actor PlaybackCoordinator {
    private let apiClient: SpotifyAPIClient

    init(apiClient: SpotifyAPIClient) {
        self.apiClient = apiClient
    }

    func play(track: SpotifyTrack) async throws {
        guard let device = try await findPlaybackDevice() else {
            AppLogger.shared.log("device discovery empty; trying Spotify active-device playback", category: "playback")
            try await apiClient.play(trackURI: track.uri, deviceID: nil)
            return
        }
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
        if let playbackState = try await apiClient.currentPlaybackState(),
           let currentDevice = try? resolvedAddressableDevice(from: playbackState.device),
           let progressMs = playbackState.progressMs,
           progressMs > 3_000
        {
            if !currentDevice.isActive {
                try await apiClient.transferPlayback(deviceID: currentDevice.id)
            }
            try await apiClient.seek(positionMS: 0, deviceID: currentDevice.id)
            return
        }

        let device = try await resolvePlaybackDevice()
        if !device.isActive {
            try await apiClient.transferPlayback(deviceID: device.id)
        }
        do {
            try await apiClient.skipPrevious(deviceID: device.id)
        } catch let error as SpotifyAPIError {
            if case .message(let message) = error,
               message.localizedCaseInsensitiveContains("restriction violated")
            {
                try await apiClient.seek(positionMS: 0, deviceID: device.id)
                return
            }
            throw error
        }
    }

    func seek(to positionMS: Int) async throws {
        let device = try await resolvePlaybackDevice()
        if !device.isActive {
            try await apiClient.transferPlayback(deviceID: device.id)
        }
        try await apiClient.seek(positionMS: max(0, positionMS), deviceID: device.id)
    }

    func resolvePlaybackDevice(
        from devices: [SpotifyDevice],
        currentPlaybackDevice: SpotifyDevice? = nil
    ) throws -> AddressableSpotifyDevice {
        guard let device = PlaybackCoordinator.preferredDevice(from: devices)
            ?? PlaybackCoordinator.preferredCurrentDevice(currentPlaybackDevice)
        else {
            throw SpotifyAPIError.noDevice
        }
        return try resolvedAddressableDevice(from: device)
    }

    private func resolvePlaybackDevice() async throws -> AddressableSpotifyDevice {
        guard let device = try await findPlaybackDevice() else {
            throw SpotifyAPIError.noDevice
        }
        return device
    }

    private func findPlaybackDevice() async throws -> AddressableSpotifyDevice? {
        let devices = try await apiClient.availableDevices()
        if let device = PlaybackCoordinator.preferredDevice(from: devices) {
            return try resolvedAddressableDevice(from: device)
        }

        let playbackDevice = try await apiClient.currentPlaybackState()?.device
        if let device = PlaybackCoordinator.preferredCurrentDevice(playbackDevice) {
            AppLogger.shared.log("using current playback device because devices endpoint omitted the Mac", category: "playback")
            return try resolvedAddressableDevice(from: device)
        }

        if devices.isEmpty, playbackDevice == nil {
            AppLogger.shared.log("Spotify device discovery returned no devices or playback state", category: "playback")
            return nil
        }

        let summary = devices.map {
            "type=\($0.type),active=\($0.isActive),restricted=\($0.isRestricted),hasID=\($0.id?.isEmpty == false)"
        }.joined(separator: ";")
        AppLogger.shared.log("no addressable Mac device count=\(devices.count) devices=[\(summary)]", category: "playback")
        throw SpotifyAPIError.noDevice
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

    private static func preferredCurrentDevice(_ device: SpotifyDevice?) -> SpotifyDevice? {
        guard let device,
              device.type == "Computer",
              device.id?.isEmpty == false
        else {
            return nil
        }
        return device
    }
}

struct AddressableSpotifyDevice {
    let id: String
    let isActive: Bool
}
