# SpotifyTray

SpotifyTray is a tiny macOS menu bar app for Spotify. Press a hotkey, search tracks in a polished popup, then play or queue them without switching to the Spotify window.

<p align="center">
  <img src="https://github.com/anudeep-gad12/spotify-tray/releases/download/v0.1.8/spotifytray-demo.gif" alt="SpotifyTray demo" width="840" />
</p>

Features:

- `Cmd+Shift+Space` opens the search popup
- live track search with album art
- `Enter` plays the selected track
- `Cmd+Enter` queues the selected track
- `Ctrl+Option+P` play/pause
- `Ctrl+Option+N` next
- `Ctrl+Option+B` previous

Requirements:

- macOS 14 or later
- Spotify desktop app installed
- Spotify Premium
- your own Spotify Developer app `Client ID`

## Install

Download the latest `SpotifyTray.app.zip` from GitHub Releases, then run:

This project ships unsigned by default. macOS will quarantine it after download. Pick one approach:

**Option A — Terminal:**

```bash
cd ~/Downloads
unzip -o SpotifyTray.app.zip
rm -rf ~/Applications/SpotifyTray.app
mv SpotifyTray.app ~/Applications/
xattr -dr com.apple.quarantine ~/Applications/SpotifyTray.app
open ~/Applications/SpotifyTray.app
```

**Option B — Right-click:**

1. Right-click `SpotifyTray.app`
2. Click `Open`
3. Confirm the macOS warning once

If Option B fails, use Option A.

## First-Time Spotify Setup

Each user needs their own Spotify developer app. SpotifyTray does not ship with your credentials.

1. Go to `https://developer.spotify.com/dashboard`
2. Create an app
3. Add this exact redirect URI:

```text
http://127.0.0.1:43821/callback
```

4. Save the app settings
5. Copy the app’s `Client ID`
6. Open SpotifyTray
7. Choose `Spotify Setup` from the menu bar icon, or open the popup
8. Paste the `Client ID` into the setup screen and save it locally
9. Click `Login / Reconnect`

Do not paste your `Client secret`. SpotifyTray does not use it.

## Build From Source

Requirements:

- Xcode 16+
- `xcodegen`

Commands:

```bash
xcodegen generate
open SpotifyTray.xcodeproj
```

For a local debug build:

```bash
./dev.sh fresh
```

Log tail:

```bash
./dev.sh traces
```

## Project Notes

- user tokens are stored locally in `~/Library/Application Support/SpotifyTray/spotify-token.json`
- logs are stored locally in `~/Library/Logs/SpotifyTray/app.log`
- user client IDs are stored locally in app preferences
- the repo does not need a real `SPOTIFY_CLIENT_ID` to build

## License

MIT. See [LICENSE](LICENSE).
