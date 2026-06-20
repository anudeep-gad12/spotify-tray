import Combine
import Foundation

enum AppearancePreference: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    var title: String {
        rawValue.capitalized
    }
}

final class AppearancePreferenceStore: ObservableObject {
    @Published private(set) var preference: AppearancePreference

    private let defaults: UserDefaults
    private let defaultsKey = "appearance.preference"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        preference = defaults.string(forKey: defaultsKey)
            .flatMap(AppearancePreference.init(rawValue:)) ?? .system
    }

    func setPreference(_ preference: AppearancePreference) {
        guard self.preference != preference else { return }
        self.preference = preference
        defaults.set(preference.rawValue, forKey: defaultsKey)
    }
}
