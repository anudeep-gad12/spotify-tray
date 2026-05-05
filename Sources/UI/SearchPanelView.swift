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

                resultsSurface
                footer
            }
            .padding(22)
        }
        .frame(width: 800, height: 680)
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
            LinearGradient(
                colors: [
                    Color(nsColor: NSColor(calibratedRed: 0.05, green: 0.058, blue: 0.074, alpha: 0.99)),
                    Color(nsColor: NSColor(calibratedRed: 0.03, green: 0.037, blue: 0.051, alpha: 0.995))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.03),
                            Color.clear,
                            Color.white.opacity(0.012)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Circle()
                .fill(Color.green.opacity(0.13))
                .blur(radius: 92)
                .frame(width: 260, height: 260)
                .offset(x: -250, y: -215)

            Circle()
                .fill(Color.cyan.opacity(0.075))
                .blur(radius: 120)
                .frame(width: 320, height: 320)
                .offset(x: 260, y: 220)
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
                .foregroundStyle(Color.white.opacity(0.60))

            TextField("Type a track or artist", text: $viewModel.query)
                .textFieldStyle(.plain)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .focused($focusedField, equals: .search)
                .disabled(isSetupState)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white.opacity(0.34))
                }
                .buttonStyle(.plain)
                .disabled(isSetupState)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(isSetupState ? 0.035 : 0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.075), lineWidth: 1)
        )
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
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .textCase(.uppercase)
                    .tracking(1.0)

                Spacer()

                sectionMeta
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.065), lineWidth: 1)
        )
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
            emptyState(
                icon: "waveform.and.magnifyingglass",
                title: "Searching Spotify",
                subtitle: "Pulling the strongest matches from the catalog."
            )
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
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                        SearchResultRow(track: track, isSelected: index == viewModel.selectedIndex)
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
        HStack(spacing: 10) {
            if !isSetupState {
                keyboardHint("Enter", "Play")
                keyboardHint("Cmd+Enter", "Queue")
                keyboardHint("↑ ↓", "Move")
            }

            keyboardHint("Esc", "Close")
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

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: track.artworkURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(Color.white.opacity(0.28))
                    }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(track.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(track.artistLine)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .lineLimit(1)

                Text(track.album.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.42))
                    .lineLimit(1)
            }

            Spacer(minLength: 10)

            if isSelected {
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.82))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.green.opacity(0.95))
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    isSelected
                    ? LinearGradient(
                        colors: [
                            Color.green.opacity(0.16),
                            Color.cyan.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [
                            Color.white.opacity(0.045),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? Color.green.opacity(0.25) : Color.white.opacity(0.045), lineWidth: 1)
        )
    }
}
