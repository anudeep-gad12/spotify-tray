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

            VStack(alignment: .leading, spacing: 16) {
                header
                searchField

                if shouldShowModeSwitcher {
                    modeSwitcher
                }

                if let message = viewModel.inlineMessage {
                    inlineMessage(message)
                }

                if shouldShowNowPlayingCard {
                    nowPlayingCard
                }

                resultsSurface
                footer
            }
            .padding(24)
        }
        .frame(width: 800, height: 740)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.16), Color.white.opacity(0.055)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.62), radius: 46, y: 24)
        .onAppear {
            requestFocus()
        }
        .onChange(of: viewModel.focusRequestID) {
            requestFocus()
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.panelCanvas,
                    Color.panelSurface.opacity(0.96),
                    Color.panelCanvas
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            PanelGrid()
                .opacity(0.42)

            Circle()
                .fill(Color.accentGreen.opacity(0.12))
                .blur(radius: 96)
                .frame(width: 310, height: 310)
                .offset(x: -285, y: -245)

            Circle()
                .fill(Color.purple.opacity(0.11))
                .blur(radius: 130)
                .frame(width: 360, height: 360)
                .offset(x: 300, y: 255)

            Circle()
                .fill(Color.accentCyan.opacity(0.075))
                .blur(radius: 80)
                .frame(width: 220, height: 220)
                .offset(x: 320, y: -180)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.028), Color.clear, Color.black.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("SpotifyTray")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(-1.1)

                Text(headerSubtitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.48))
                    .lineLimit(2)
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
                        .fill(statusTint.opacity(0.11))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(statusTint.opacity(0.13), lineWidth: 1)
                )
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Color.accentGreen.opacity(0.86))

            TextField("Type a track or artist", text: $viewModel.query)
                .textFieldStyle(.plain)
                .font(.system(size: 22, weight: .black, design: .rounded))
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
                    .fill(Color.cardFill.opacity(isSetupState ? 0.58 : 0.92))

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentGreen.opacity(0.035))
                    .blur(radius: 8)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.accentGreen.opacity(0.10),
                            Color.white.opacity(0.055)
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

    private var modeSwitcher: some View {
        HStack(spacing: 6) {
            ForEach(SearchPanelMode.allCases) { mode in
                let isActive = viewModel.activeMode == mode
                Button {
                    viewModel.setMode(mode)
                } label: {
                    Text(mode.title)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(isActive ? Color.black.opacity(0.88) : Color.white.opacity(0.54))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(isActive ? Color.accentGreen.opacity(0.94) : Color.clear)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(isActive ? Color.accentCyan.opacity(0.22) : Color.clear, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(4)
        .background(
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.075), lineWidth: 1)
        )
    }

    private func inlineMessage(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.inlineMessageIsError ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                .foregroundStyle(viewModel.inlineMessageIsError ? Color.orange : Color.accentGreen)

            Text(message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(viewModel.inlineMessageIsError ? Color.orange.opacity(0.95) : Color.white.opacity(0.78))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(viewModel.inlineMessageIsError ? Color.orange.opacity(0.10) : Color.accentGreen.opacity(0.075))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(viewModel.inlineMessageIsError ? Color.orange.opacity(0.18) : Color.accentGreen.opacity(0.11), lineWidth: 1)
        )
    }

    private var resultsSurface: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Text(sectionTitle)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.64))
                    .textCase(.uppercase)
                    .tracking(1.6)

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
                    .fill(Color.cardFill.opacity(0.84))

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.030),
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
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.055),
                            Color.white.opacity(0.035)
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
                    .fill(Color.white.opacity(0.055))
                    .frame(width: 58, height: 58)
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accentGreen.opacity(0.85))
                            .scaleEffect(0.72)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Now Playing")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color.white.opacity(0.40))
                        .textCase(.uppercase)
                        .tracking(1.6)

                    Text("Checking current playback")
                        .font(.system(size: 15, weight: .black, design: .rounded))
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
                        .fill(Color.white.opacity(0.055))
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
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Color.white.opacity(0.40))
                            .textCase(.uppercase)
                            .tracking(1.6)

                        HStack(spacing: 5) {
                            Circle()
                                .fill(summary.isPlaying ? Color.accentGreen.opacity(0.95) : Color.orange.opacity(0.95))
                                .frame(width: 7, height: 7)

                            Text(summary.isPlaying ? "Playing" : "Paused")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(summary.isPlaying ? Color.accentGreen.opacity(0.95) : Color.orange.opacity(0.95))
                        }
                    }

                    Text(summary.title)
                        .font(.system(size: 18, weight: .black, design: .rounded))
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
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Color.white.opacity(0.32))
                            .textCase(.uppercase)
                            .tracking(1.3)

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
        Text(sectionMetaText)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.38))
    }

    @ViewBuilder
    private var content: some View {
        if case .setupRequired = viewModel.panelState {
            setupContent
        } else if case .authenticationRequired(let message) = viewModel.panelState {
            authenticationContent(message)
        } else {
            switch viewModel.activeMode {
            case .search:
                searchContent
            case .recent:
                collectionContent(
                    state: viewModel.recentState,
                    loadingIcon: "clock.arrow.circlepath",
                    loadingTitle: "Loading recent tracks",
                    loadingSubtitle: "Pulling the last songs Spotify says you played.",
                    emptyIcon: "clock",
                    emptyTitle: "No recent tracks yet",
                    emptySubtitle: "Play something in Spotify, then open this again."
                )
            case .queue:
                collectionContent(
                    state: viewModel.queueState,
                    loadingIcon: "list.bullet.rectangle",
                    loadingTitle: "Loading queue",
                    loadingSubtitle: "Checking what Spotify has lined up next.",
                    emptyIcon: "text.line.first.and.arrowtriangle.forward",
                    emptyTitle: "Queue is empty",
                    emptySubtitle: "Queue a track from search or recent tracks."
                )
            }
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        switch viewModel.panelState {
        case .helper:
            emptyState(
                icon: "sparkles",
                title: "Start typing to launch something good",
                subtitle: "Live search stays focused on tracks and keeps the strongest matches in one view."
            )
        case .loading:
            loadingState(
                icon: "waveform.and.magnifyingglass",
                title: "Searching Spotify",
                subtitle: "Pulling the strongest matches from the catalog."
            )
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
        case .results:
            trackList(viewModel.searchItems)
        case .setupRequired, .authenticationRequired:
            EmptyView()
        }
    }

    @ViewBuilder
    private func collectionContent(
        state: TrackCollectionState,
        loadingIcon: String,
        loadingTitle: String,
        loadingSubtitle: String,
        emptyIcon: String,
        emptyTitle: String,
        emptySubtitle: String
    ) -> some View {
        switch state {
        case .idle, .loading:
            loadingState(icon: loadingIcon, title: loadingTitle, subtitle: loadingSubtitle)
        case .loaded(let items):
            trackList(items)
        case .empty:
            emptyState(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle)
        case .error(let message):
            emptyState(
                icon: "exclamationmark.octagon.fill",
                title: "Couldn’t load this view",
                subtitle: message,
                tint: .orange
            )
        }
    }

    private func authenticationContent(_ message: String) -> some View {
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
    }

    private func loadingState(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            emptyState(icon: icon, title: title, subtitle: subtitle)

            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentGreen.opacity(0.86), Color.accentCyan.opacity(0.62)],
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
    }

    private func trackList(_ items: [TrackListItem]) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        TrackListRow(item: item, isSelected: index == viewModel.selectedIndex)
                            .id(item.id)
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
                guard items.indices.contains(viewModel.selectedIndex) else { return }
                withAnimation(.easeInOut(duration: 0.14)) {
                    proxy.scrollTo(items[viewModel.selectedIndex].id, anchor: .center)
                }
            }
        }
    }

    private var setupContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Bring your own Spotify app")
                    .font(.system(size: 23, weight: .black, design: .rounded))
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
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .textCase(.uppercase)
                    .tracking(1.3)

                TextField("32-character Client ID", text: $viewModel.setupClientID)
                    .textFieldStyle(.plain)
                    .font(.system(size: 19, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .focused($focusedField, equals: .clientID)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.cardFill.opacity(0.88))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.085), lineWidth: 1)
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
                            .fill(Color.white.opacity(0.065))
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
                .foregroundStyle(Color.accentGreen)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.accentGreen.opacity(0.10))
                )
                .overlay(
                    Circle()
                        .stroke(Color.accentGreen.opacity(0.14), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .black))
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
                .fill(Color.cardFill.opacity(0.74))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.065), lineWidth: 1)
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
                    .fill(tint.opacity(0.105))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(tint.opacity(0.13), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(tint.opacity(0.96))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 21, weight: .black, design: .rounded))
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                if !isSetupState {
                    keyboardHint("Enter", "Play")
                    keyboardHint("Cmd+Enter", "Queue")
                    keyboardHint("↑ ↓", "Move")
                }

                keyboardHint("Esc", "Close")
            }

            if !isSetupState {
                HStack(spacing: 9) {
                    keyboardHint("Ctrl+Opt+P", "Pause")
                    keyboardHint("Ctrl+Opt+N", "Next")
                    keyboardHint("Ctrl+Opt+B", "Previous")
                }

                HStack(spacing: 9) {
                    keyboardHint("Tab", "Next tab")
                    keyboardHint("Shift+Tab", "Previous tab")
                }
            }
        }
    }

    private var sectionTitle: String {
        if case .setupRequired = viewModel.panelState {
            return "Setup"
        }
        if case .authenticationRequired = viewModel.panelState {
            return "Connection"
        }

        switch viewModel.activeMode {
        case .search:
            switch viewModel.panelState {
            case .results:
                return "Results"
            case .loading:
                return "Searching"
            case .empty:
                return "No Results"
            case .error:
                return "Error"
            default:
                return "Discover"
            }
        case .recent:
            return "Recent"
        case .queue:
            return "Queue"
        }
    }

    private var sectionMetaText: String {
        if case .setupRequired = viewModel.panelState {
            return "First launch"
        }
        if case .authenticationRequired = viewModel.panelState {
            return "Reconnect"
        }

        switch viewModel.activeMode {
        case .search:
            if case .results(let tracks) = viewModel.panelState {
                return "\(tracks.count) live matches"
            }
            return "Top 8"
        case .recent:
            if case .loaded(let items) = viewModel.recentState {
                return "Last \(items.count) tracks"
            }
            return "Last 20"
        case .queue:
            if case .loaded(let items) = viewModel.queueState {
                let upcoming = max(0, items.count - 1)
                return upcoming == 1 ? "Now playing + 1 upcoming" : "Now playing + \(upcoming) upcoming"
            }
            return "Current session"
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

    private var shouldShowModeSwitcher: Bool {
        switch viewModel.panelState {
        case .setupRequired, .authenticationRequired:
            return false
        default:
            return true
        }
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
                    colors: [Color.accentGreen.opacity(0.95), Color.accentCyan.opacity(0.72)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }

    private var nowPlayingBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.cardFill.opacity(0.82))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.085), lineWidth: 1)
            )
    }

    private func compactPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundStyle(Color.white.opacity(0.74))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.065))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
    }

    private func keyboardHint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 7) {
            Text(key)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.78))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.070))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.055), lineWidth: 1)
                )

            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.38))
        }
    }

    private func requestFocus() {
        DispatchQueue.main.async {
            focusedField = isSetupState ? .clientID : .search
        }
    }
}

private struct TrackListRow: View {
    let item: TrackListItem
    let isSelected: Bool

    @State private var isHovered = false

    private var track: SpotifyTrack {
        item.track
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                AsyncImage(url: track.artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.075), Color.white.opacity(0.035)],
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

                if isSelected {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.accentGreen.opacity(0.62), lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.system(size: 17, weight: .black, design: .rounded))
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

                    if let metadata = item.metadata {
                        Text("•")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.30))

                        Text(metadata)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.accentGreen.opacity(0.56))
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 10)

            if let duration = track.durationMs {
                Text(formatDuration(duration))
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.42))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.055))
                    )
            }

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
                                    colors: [Color.accentGreen.opacity(0.95), Color.accentCyan.opacity(0.72)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            } else if isHovered {
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.accentGreen.opacity(0.74))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.accentGreen.opacity(0.10))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.accentGreen.opacity(0.20), lineWidth: 1)
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
                            Color.accentGreen.opacity(0.105),
                            Color.accentCyan.opacity(0.050)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else if isHovered {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.050),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.033),
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
                    ? Color.accentGreen.opacity(0.26)
                    : isHovered
                        ? Color.white.opacity(0.085)
                        : Color.white.opacity(0.052),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(isSelected ? 0.16 : 0.05), radius: isSelected ? 9 : 3, y: 3)
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

private struct PanelGrid: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let step: CGFloat = 42

            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }

            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }

            context.stroke(path, with: .color(Color.white.opacity(0.045)), lineWidth: 0.5)
        }
    }
}

private extension Color {
    static let panelCanvas = Color(nsColor: NSColor(calibratedRed: 0.027, green: 0.043, blue: 0.067, alpha: 1.0))
    static let panelSurface = Color(nsColor: NSColor(calibratedRed: 0.050, green: 0.064, blue: 0.086, alpha: 1.0))
    static let cardFill = Color(nsColor: NSColor(calibratedRed: 0.066, green: 0.082, blue: 0.110, alpha: 1.0))
    static let accentGreen = Color(nsColor: NSColor(calibratedRed: 0.337, green: 0.827, blue: 0.392, alpha: 1.0))
    static let accentCyan = Color(nsColor: NSColor(calibratedRed: 0.392, green: 0.910, blue: 0.980, alpha: 1.0))
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
