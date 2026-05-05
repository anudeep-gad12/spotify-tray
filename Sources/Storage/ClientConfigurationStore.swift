import Foundation

enum ClientConfigurationError: LocalizedError, Equatable {
    case invalidClientID

    var errorDescription: String? {
        switch self {
        case .invalidClientID:
            return "That does not look like a Spotify Client ID."
        }
    }
}

final class ClientConfigurationStore: @unchecked Sendable {
    private let defaults: UserDefaults
    private let bundledClientID: String
    private let defaultsKey = "spotify.client-id"

    init(defaults: UserDefaults = .standard, bundledClientID: String) {
        self.defaults = defaults
        self.bundledClientID = Self.normalizedClientID(bundledClientID)
    }

    var hasConfiguredClientID: Bool {
        !currentClientID().isEmpty
    }

    var hasUserConfiguredClientID: Bool {
        !(defaults.string(forKey: defaultsKey)?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    func currentClientID() -> String {
        if let stored = defaults.string(forKey: defaultsKey) {
            let normalized = Self.normalizedClientID(stored)
            if !normalized.isEmpty {
                return normalized
            }
        }

        return bundledClientID
    }

    func saveClientID(_ rawValue: String) throws {
        let normalized = Self.normalizedClientID(rawValue)
        guard Self.isPlausibleClientID(normalized) else {
            throw ClientConfigurationError.invalidClientID
        }

        defaults.set(normalized, forKey: defaultsKey)
    }

    func clearClientID() throws {
        defaults.removeObject(forKey: defaultsKey)
    }

    private static func normalizedClientID(_ rawValue: String) -> String {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty || value == "CHANGE_ME" {
            return ""
        }
        return value
    }

    private static func isPlausibleClientID(_ value: String) -> Bool {
        guard value.count >= 20, value.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
            return false
        }

        return value.unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) }
    }
}
