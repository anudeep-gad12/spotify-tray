import SwiftUI

struct SearchPanelView: View {
    private enum FocusField: Hashable {
        case search
        case clientID
    }

    @ObservedObject var viewModel: SearchViewModel
    @FocusState private var focusedField: FocusField?

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 18) {
                header
                searchField

                if let message = viewModel.inlineMessage {
                    inlineMessage(message)
                }

                if shouldShowNowPlayingCard {
                    nowPlayingCard
                }

                resultsSurface
                footer
            }
            .padding(22)
        }
        .frame(width: 800, height: 740)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.36), radius: 38, y: 18)
        .onAppear {
            requestFocus()
        }
        .onChange(of: viewModel.focusRequestID) {
            requestFocus()
        }
    }

    private var background: some View {
        ZStack {
            // Deep base gradient
            LinearGradient(
                colors: [
                    Color(nsColor: NSColor(calibratedRed: 0.055, green: 0.06, blue: 0.08, alpha: 1.0)),
                    Color(nsColor: NSColor(calibratedRed: 0.03, green: 0.035, blue: 0.05, alpha: 1.0))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle top-to-bottom light overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.025),
                            Color.clear,
                            Color.white.opacity(0.01)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Top-left ambient glow (green)
            Circle()
                .fill(Color.green.opacity(0.15))
                .blur(radius: 100)
                .frame(width: 280, height: 280)
                .offset(x: -260, y: -230)

            // Bottom-right ambient glow (purple)
            Circle()
                .fill(Color.purple.opacity(0.12))
                .blur(radius: 130)
                .frame(width: 340, height: 340)
                .offset(x: 280, y: 240)

            // Top-right accent glow (cyan)
            Circle()
                .fill(Color.cyan.opacity(0.08))
                .blur(radius: 80)
                .frame(width: 200, height: 200)
                .offset(x: 320, y: -180)

            // Subtle noise texture overlay
            Rectangle()
                .fill(Color.white.opacity(0.015))
                .blur(radius: 0.5)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("SpotifyTray")
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(headerSubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.62))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                compactPill("Cmd+Shift+Space")

                HStack(spacing: 6) {
                    Circle()
                        .fill(statusTint)
                        .frame(width: 7, height: 7)

                    Text(statusLabel)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(statusTint)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule(style: .continuous)
                        .fill(statusTint.opacity(0.10))
                )
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Color.green.opacity(0.85))

            TextField("Type a track or artist", text: $viewModel.query)
                .textFieldStyle(.plain)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .focused($focusedField, equals: .search)
                .disabled(isSetupState)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white.opacity(0.30))
                }
                .buttonStyle(.plain)
                .disabled(isSetupState)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(isSetupState ? 0.035 : 0.05))

                // Inner glow on focus
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.green.opacity(0.04))
                    .blur(radius: 8)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.green.opacity(0.15),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .opacity(isSetupState ? 0.64 : 1)
    }

    private func inlineMessage(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.inlineMessageIsError ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                .foregroundStyle(viewModel.inlineMessageIsError ? Color.orange : Color.green)

            Text(message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(viewModel.inlineMessageIsError ? Color.orange.opacity(0.95) : Color.white.opacity(0.78))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(viewModel.inlineMessageIsError ? Color.orange.opacity(0.11) : Color.green.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(viewModel.inlineMessageIsError ? Color.orange.opacity(0.18) : Color.green.opacity(0.12), lineWidth: 1)
        )
    }

    private var resultsSurface: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text(sectionTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                sectionMeta
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.035))

                // Subtle inner highlight at top
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.025),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
    }

    @ViewBuilder
    private var nowPlayingCard: some View {
        switch viewModel.nowPlayingState {
        case .hidden:
            EmptyView()
        case .loading:
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 58, height: 58)
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white.opacity(0.75))
                            .scaleEffect(0.72)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Now Playing")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.46))
                        .textCase(.uppercase)
                        .tracking(1.1)

                    Text("Checking current playback")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.88))

                    Text("Spotify is syncing what’s on right now.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.50))
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(nowPlayingBackground)
        case .showing(let summary):
            HStack(spacing: 14) {
                AsyncImage(url: summary.artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.34))
                        }
                }
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("Now Playing")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.46))
                            .textCase(.uppercase)
                            .tracking(1.1)

                        HStack(spacing: 5) {
                            Circle()
                                .fill(summary.isPlaying ? Color.green.opacity(0.95) : Color.orange.opacity(0.95))
                                .frame(width: 7, height: 7)

                            Text(summary.isPlaying ? "Playing" : "Paused")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(summary.isPlaying ? Color.green.opacity(0.95) : Color.orange.opacity(0.95))
                        }
                    }

                    Text(summary.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(summary.artistLine)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if let deviceName = summary.deviceName, !deviceName.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Device")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.34))
                            .textCase(.uppercase)
                            .tracking(1.0)

                        Text(deviceName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.62))
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: 120, alignment: .trailing)
                }
            }
            .padding(16)
            .background(nowPlayingBackground)
        }
    }

    @ViewBuilder
    private var sectionMeta: some View {
        switch viewModel.panelState {
        case .results(let tracks):
            Text("\(tracks.count) live matches")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.42))
        case .setupRequired:
            Text("First launch")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.42))
        default:
            Text("Top 8")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.30))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.panelState {
        case .setupRequired:
            setupContent
        case .helper:
            emptyState(
                icon: "sparkles",
                title: "Start typing to launch something good",
                subtitle: "Live search stays focused on tracks and keeps the strongest matches in one view."
            )
        case .loading:
            VStack(alignment: .leading, spacing: 18) {
                emptyState(
                    icon: "waveform.and.magnifyingglass",
                    title: "Searching Spotify",
                    subtitle: "Pulling the strongest matches from the catalog."
                )

                // Animated loading indicator
                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { index in
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.9), Color.cyan.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 4, height: 16)
                            .modifier(BounceAnimation(delay: Double(index) * 0.1))
                    }
                }
                .padding(.top, 8)
            }
        case .authenticationRequired(let message):
            VStack(alignment: .leading, spacing: 18) {
                emptyState(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Connect Spotify",
                    subtitle: message
                )

                Button(viewModel.loginInProgress ? "Waiting For Spotify..." : "Login / Reconnect") {
                    viewModel.requestLogin()
                }
                .buttonStyle(.plain)
                .disabled(viewModel.loginInProgress)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(primaryButtonBackground)
                .foregroundStyle(Color.black.opacity(0.86))
                .font(.system(size: 14, weight: .bold))
            }
        case .empty:
            emptyState(
                icon: "music.note",
                title: "No matches found",
                subtitle: "Try a shorter phrase or search by artist first."
            )
        case .error(let message):
            emptyState(
                icon: "exclamationmark.octagon.fill",
                title: "Something went wrong",
                subtitle: message,
                tint: .orange
            )
        case .results(let tracks):
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                            SearchResultRow(track: track, isSelected: index == viewModel.selectedIndex)
                                .id(track.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.select(index: index)
                                    viewModel.playSelected()
                                }
                        }
                    }
                    .padding(.bottom, 2)
                }
                .scrollIndicators(.hidden)
                .onChange(of: viewModel.selectedIndex) {
                    guard tracks.indices.contains(viewModel.selectedIndex) else { return }
                    withAnimation(.easeInOut(duration: 0.14)) {
                        proxy.scrollTo(tracks[viewModel.selectedIndex].id, anchor: .center)
                    }
                }
            }
        }
    }

    private var setupContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Bring your own Spotify app")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Create a Spotify developer app, add the redirect below, then paste its Client ID here. The value stays local to this Mac.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 12) {
                setupStep(number: "1", title: "Spotify redirect URI", detail: viewModel.redirectURI, emphasis: true)
                setupStep(number: "2", title: "Allowed API", detail: "Enable Spotify Web API for the app.")
                setupStep(number: "3", title: "Paste Client ID", detail: "Client secret is not used and should never be stored here.")
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Spotify Client ID")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .textCase(.uppercase)
                    .tracking(0.9)

                TextField("32-character Client ID", text: $viewModel.setupClientID)
                    .textFieldStyle(.plain)
                    .font(.system(size: 19, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .focused($focusedField, equals: .clientID)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.055))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.075), lineWidth: 1)
                    )
            }

            HStack(spacing: 12) {
                Button("Save Client ID") {
                    viewModel.saveClientID()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(primaryButtonBackground)
                .foregroundStyle(Color.black.opacity(0.86))
                .font(.system(size: 14, weight: .bold))

                if viewModel.hasSavedClientID {
                    Button("Clear Saved Setup") {
                        viewModel.clearConfiguration()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.07))
                    )
                    .foregroundStyle(Color.white.opacity(0.84))
                    .font(.system(size: 14, weight: .bold))
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func setupStep(number: String, title: String, detail: String, emphasis: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.88))

                Text(detail)
                    .font(.system(size: emphasis ? 13 : 14, weight: emphasis ? .bold : .medium, design: emphasis ? .monospaced : .default))
                    .foregroundStyle(Color.white.opacity(emphasis ? 0.82 : 0.58))
                    .textSelection(.enabled)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func emptyState(
        icon: String,
        title: String,
        subtitle: String,
        tint: Color = .green
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.13))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(tint.opacity(0.96))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.60))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 12)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if !isSetupState {
                    keyboardHint("Enter", "Play")
                    keyboardHint("Cmd+Enter", "Queue")
                    keyboardHint("↑ ↓", "Move")
                }

                keyboardHint("Esc", "Close")
            }

            if !isSetupState {
                HStack(spacing: 10) {
                    keyboardHint("Ctrl+Opt+P", "Pause")
                    keyboardHint("Ctrl+Opt+N", "Next")
                    keyboardHint("Ctrl+Opt+B", "Previous")
                }
            }
        }
    }

    private var sectionTitle: String {
        switch viewModel.panelState {
        case .setupRequired:
            return "Setup"
        case .results:
            return "Results"
        case .loading:
            return "Searching"
        case .authenticationRequired:
            return "Connection"
        case .empty:
            return "No Results"
        case .error:
            return "Error"
        case .helper:
            return "Discover"
        }
    }

    private var headerSubtitle: String {
        switch viewModel.panelState {
        case .setupRequired:
            return "First-run setup for your own Spotify developer app."
        default:
            return "Search, play, and queue tracks on your Mac without touching the Spotify window."
        }
    }

    private var statusLabel: String {
        switch viewModel.panelState {
        case .setupRequired:
            return "Setup needed"
        case .authenticationRequired:
            return "Ready to connect"
        case .loading:
            return "Searching"
        default:
            return "Premium flow"
        }
    }

    private var statusTint: Color {
        switch viewModel.panelState {
        case .setupRequired:
            return Color.orange.opacity(0.95)
        case .authenticationRequired:
            return Color.cyan.opacity(0.95)
        default:
            return Color.green.opacity(0.95)
        }
    }

    private var isSetupState: Bool {
        if case .setupRequired = viewModel.panelState {
            return true
        }
        return false
    }

    private var shouldShowNowPlayingCard: Bool {
        switch viewModel.panelState {
        case .setupRequired, .authenticationRequired:
            return false
        case .helper, .loading, .results, .empty, .error:
            if case .hidden = viewModel.nowPlayingState {
                return false
            }
            return true
        }
    }

    private var primaryButtonBackground: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.green.opacity(0.96), Color.cyan.opacity(0.78)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }

    private var nowPlayingBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.white.opacity(0.045))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func compactPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundStyle(Color.white.opacity(0.82))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
    }

    private func keyboardHint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 8) {
            Text(key)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )

            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.54))
        }
    }

    private func requestFocus() {
        DispatchQueue.main.async {
            focusedField = isSetupState ? .clientID : .search
        }
    }
}

private struct SearchResultRow: View {
    let track: SpotifyTrack
    let isSelected: Bool

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 14) {
            // Artwork with glow effect when selected
            ZStack {
                AsyncImage(url: track.artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.white.opacity(0.25))
                        }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Selection ring
                if isSelected {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }

            // Track info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(track.artistLine)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .lineLimit(1)

                    if !track.album.name.isEmpty {
                        Text("•")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.30))

                        Text(track.album.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.40))
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 10)

            // Duration badge
            if let duration = track.durationMs {
                Text(formatDuration(duration))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.45))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
            }

            // Play indicator
            if isSelected {
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.95), Color.cyan.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            } else if isHovered {
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.green.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.green.opacity(0.12))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.green.opacity(0.25), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            ZStack {
                if isSelected {
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.14),
                            Color.cyan.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else if isHovered {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.04),
                            Color.white.opacity(0.025)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    isSelected
                    ? Color.green.opacity(0.30)
                    : isHovered
                        ? Color.white.opacity(0.08)
                        : Color.white.opacity(0.04),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(isSelected ? 0.12 : 0.06), radius: isSelected ? 6 : 3, y: 2)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    private func formatDuration(_ ms: Int) -> String {
        let totalSeconds = ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Loading Animation

private struct BounceAnimation: ViewModifier {
    let delay: Double

    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .opacity(isAnimating ? 1.0 : 0.4)
            .animation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
