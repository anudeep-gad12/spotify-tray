import Foundation

@MainActor
final class AppleScriptTransportController {
    func playPause() {
        run(script: #"tell application "Spotify" to playpause"#)
    }

    func nextTrack() {
        run(script: #"tell application "Spotify" to next track"#)
    }

    func previousTrack() {
        run(script: #"tell application "Spotify" to previous track"#)
    }

    private func run(script: String) {
        let appleScript = NSAppleScript(source: script)
        var errorDictionary: NSDictionary?
        appleScript?.executeAndReturnError(&errorDictionary)
        if let errorDictionary {
            AppLogger.shared.log("AppleScript failed script=\(script) error=\(errorDictionary)", category: "transport")
        } else {
            AppLogger.shared.log("AppleScript succeeded script=\(script)", category: "transport")
        }
    }
}
