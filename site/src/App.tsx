import {
  ArrowRight,
  Check,
  CirclePlay,
  Command,
  Download,
  Github,
  Keyboard,
  Music4,
  ScanSearch,
  Search,
  Sparkles,
} from "lucide-react";
import { Badge } from "./components/ui/badge";
import { Button } from "./components/ui/button";
import { Card } from "./components/ui/card";

const releaseUrl = "https://github.com/anudeep-gad12/spotify-tray/releases/latest";
const repoUrl = "https://github.com/anudeep-gad12/spotify-tray";
const readmeUrl = "https://github.com/anudeep-gad12/spotify-tray#readme";
const redirectUri = "http://127.0.0.1:43821/callback";

const features = [
  {
    icon: ScanSearch,
    title: "Instant popup search",
    body: "Summon a polished search window with one hotkey and find tracks without touching Spotify.",
  },
  {
    icon: Music4,
    title: "Play or queue",
    body: "Hit Enter to play now, or Cmd+Enter to queue the next track while staying in your current app.",
  },
  {
    icon: CirclePlay,
    title: "Now playing glance",
    body: "Keep the current song, artist, device, and playback state visible inside the popup.",
  },
  {
    icon: Keyboard,
    title: "Global controls",
    body: "Play, pause, next, and previous from anywhere on your Mac with compact shortcuts.",
  },
];

const installSteps = [
  "Download SpotifyTray.app.zip from the latest release.",
  "Unzip it and move SpotifyTray.app into ~/Applications.",
  "Create a Spotify Developer app and add the exact redirect URI.",
  "Paste only the Client ID, sign in once, and press ⌘⇧Space.",
];

const shortcuts = [
  ["⌘⇧Space", "Open popup"],
  ["Enter", "Play"],
  ["⌘Enter", "Queue"],
  ["⌃⌥P", "Pause"],
  ["⌃⌥N", "Next"],
  ["⌃⌥B", "Previous"],
];

function LogoMark() {
  return (
    <div className="flex h-9 w-9 items-center justify-center rounded-xl border border-white/10 bg-white/[0.055] text-accent shadow-glow">
      <Music4 size={17} />
    </div>
  );
}

function ProductMock() {
  return (
    <Card className="relative mx-auto max-w-5xl overflow-hidden rounded-[34px] p-4 shadow-hero sm:p-6">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_0%,rgba(86,211,100,0.12),transparent_42%)]" />
      <div className="absolute inset-4 rounded-[28px] border border-dashed border-white/10" />
      <div className="relative overflow-hidden rounded-[28px] border border-white/10 bg-[#0b0f14]/95 shadow-[0_28px_90px_rgba(0,0,0,0.55)]">
        <div className="flex items-center justify-between border-b border-white/8 px-5 py-4">
          <div className="flex items-center gap-2">
            <span className="h-3 w-3 rounded-full bg-[#ff6b6b]" />
            <span className="h-3 w-3 rounded-full bg-[#ffd166]" />
            <span className="h-3 w-3 rounded-full bg-[#8ce99a]" />
          </div>
          <div className="font-mono text-xs text-white/35">~/SpotifyTray</div>
          <Badge className="hidden bg-white/[0.07] text-white/70 sm:inline-flex">⌘⇧Space</Badge>
        </div>

        <div className="grid gap-0 lg:grid-cols-[0.34fr_0.66fr]">
          <aside className="border-b border-white/8 bg-white/[0.025] p-5 lg:border-b-0 lg:border-r">
            <div className="mb-5 flex items-center gap-3">
              <LogoMark />
              <div>
                <div className="font-black text-white">SpotifyTray</div>
                <div className="text-xs text-white/42">Searching</div>
              </div>
            </div>
            <div className="rounded-2xl border border-white/10 bg-black/25 px-4 py-3 text-sm text-white/45">
              Search workspace
            </div>
            <div className="mt-8 space-y-4 text-sm">
              {["now-playing", "search-results", "queue-track"].map((item, index) => (
                <div key={item} className="flex items-center gap-3">
                  <span className={`h-2.5 w-2.5 rounded-full ${index === 0 ? "bg-accent" : index === 1 ? "bg-cyanSoft" : "bg-violet-300"}`} />
                  <div>
                    <div className="font-semibold text-white/80">{item}</div>
                    <div className="text-white/36">{index === 0 ? "Playing" : index === 1 ? "Working" : "Ready"}</div>
                  </div>
                </div>
              ))}
            </div>
          </aside>

          <div className="p-5 sm:p-7">
            <div className="mb-5 flex items-center justify-between">
              <div>
                <div className="text-sm font-semibold text-white/45">Popup search</div>
                <div className="mt-1 text-2xl font-black tracking-tight text-white">Find music without leaving flow.</div>
              </div>
              <Badge className="bg-accent text-black">Live</Badge>
            </div>

            <div className="mb-4 flex items-center gap-3 rounded-[22px] border border-accent/25 bg-accent/10 px-5 py-4 shadow-[0_0_50px_rgba(86,211,100,0.08)]">
              <Search className="text-accent" size={19} />
              <span className="text-xl font-black text-white">comedown machine</span>
              <span className="h-6 w-px animate-pulse bg-accent" />
            </div>

            <Card className="mb-4 flex items-center gap-4 rounded-[24px] bg-white/[0.035] p-4">
              <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-red-500 to-red-900 text-xs font-black text-white/80">RCA</div>
              <div className="min-w-0 flex-1">
                <div className="mb-1 text-[11px] font-black uppercase tracking-[0.2em] text-white/38">Now playing · <span className="text-accent">Playing</span></div>
                <div className="truncate text-lg font-black text-white">Partners In Crime</div>
                <div className="truncate text-sm text-white/52">The Strokes</div>
              </div>
              <div className="hidden text-right text-xs font-semibold uppercase tracking-[0.18em] text-white/38 sm:block">
                Device<br /><span className="normal-case tracking-normal text-white/62">Invincible</span>
              </div>
            </Card>

            <div className="rounded-[24px] border border-white/8 bg-white/[0.025] p-4">
              <div className="mb-4 flex items-center justify-between text-xs font-black uppercase tracking-[0.18em] text-white/36">
                <span>Top matches</span>
                <span>8 results</span>
              </div>
              <div className="space-y-2">
                {["Welcome To Japan", "Call It Fate, Call It Karma", "One Way Trigger"].map((track, index) => (
                  <div key={track} className={`flex items-center gap-3 rounded-2xl border px-3 py-3 ${index === 0 ? "border-accent/25 bg-accent/8" : "border-white/8 bg-black/10"}`}>
                    <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-white/16 to-white/5" />
                    <div className="min-w-0 flex-1">
                      <div className="truncate font-bold text-white/86">{track}</div>
                      <div className="truncate text-xs text-white/42">The Strokes</div>
                    </div>
                    <span className="rounded-full bg-white/8 px-3 py-1 text-xs font-bold text-white/55">{index === 0 ? "Enter" : "⌘↩"}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </Card>
  );
}

function HotkeyPanel() {
  return (
    <Card className="relative overflow-hidden p-6 sm:p-8">
      <div className="absolute inset-6 rounded-[28px] border border-dashed border-white/10 bg-[linear-gradient(135deg,rgba(255,255,255,0.04),transparent_38%)]" />
      <div className="relative space-y-3">
        {shortcuts.map(([key, label]) => (
          <div key={key} className="flex items-center justify-between rounded-2xl border border-white/8 bg-black/25 px-4 py-3">
            <div className="flex items-center gap-3 text-white/72">
              <Command size={15} className="text-accent" />
              <span className="font-semibold">{label}</span>
            </div>
            <kbd className="rounded-full border border-white/10 bg-white/8 px-3 py-1 font-mono text-xs font-bold text-white/72">{key}</kbd>
          </div>
        ))}
      </div>
    </Card>
  );
}

function TerminalCard() {
  return (
    <Card className="overflow-hidden p-0">
      <div className="flex items-center justify-between border-b border-white/8 px-5 py-4">
        <div className="flex items-center gap-2">
          <span className="h-3 w-3 rounded-full bg-[#ff6b6b]" />
          <span className="h-3 w-3 rounded-full bg-[#ffd166]" />
          <span className="h-3 w-3 rounded-full bg-[#8ce99a]" />
        </div>
        <div className="font-mono text-xs text-white/35">~/Applications</div>
      </div>
      <pre className="overflow-x-auto px-5 py-5 text-sm leading-8 text-white/76 sm:text-base">
        <code>{`$ unzip SpotifyTray.app.zip
$ mv SpotifyTray.app ~/Applications/
$ xattr -dr com.apple.quarantine ~/Applications/SpotifyTray.app
$ open ~/Applications/SpotifyTray.app
✓ Spotify setup: ${redirectUri}`}</code>
      </pre>
    </Card>
  );
}

export default function App() {
  return (
    <div className="min-h-screen overflow-hidden bg-canvas text-text">
      <div className="fixed inset-0 -z-10 bg-page-grid bg-[size:72px_72px]" />
      <div className="fixed inset-0 -z-10 bg-[radial-gradient(circle_at_50%_0%,rgba(86,211,100,0.10),transparent_26%),radial-gradient(circle_at_78%_62%,rgba(56,189,248,0.08),transparent_22%),linear-gradient(180deg,rgba(7,11,17,0),#070b11_78%)]" />

      <div className="mx-auto max-w-7xl px-5 sm:px-8 lg:px-10">
        <header className="sticky top-0 z-20 mx-auto flex max-w-6xl items-center justify-between border-b border-white/[0.06] bg-canvas/70 py-4 backdrop-blur-xl">
          <a href="#top" className="flex items-center gap-3">
            <LogoMark />
            <span className="font-black tracking-tight text-white">SpotifyTray</span>
          </a>
          <nav className="hidden items-center gap-8 text-sm font-bold text-white/48 md:flex">
            <a href="#features" className="transition hover:text-white">Features</a>
            <a href="#install" className="transition hover:text-white">Install</a>
            <a href={repoUrl} target="_blank" rel="noreferrer" className="transition hover:text-white">GitHub</a>
            <a href={releaseUrl} target="_blank" rel="noreferrer" className="rounded-full bg-white px-5 py-2.5 text-black transition hover:scale-105">Download</a>
          </nav>
          <a href={releaseUrl} target="_blank" rel="noreferrer" className="rounded-full bg-white px-4 py-2 text-sm font-black text-black md:hidden">Download</a>
        </header>

        <main id="top">
          <section className="mx-auto flex max-w-5xl flex-col items-center pb-16 pt-24 text-center sm:pt-32 lg:pb-24">
            <Badge className="mb-8 bg-cyanSoft/35 text-cyan-200">
              <Sparkles size={13} />
              SPOTIFY-TRAY
            </Badge>
            <h1 className="max-w-5xl text-balance text-[clamp(4rem,12vw,9.5rem)] font-black leading-[0.84] tracking-[-0.09em] text-white">
              A Spotlight for Spotify on macOS.
            </h1>
            <p className="mt-8 max-w-3xl text-balance text-lg font-semibold leading-8 text-white/52 sm:text-xl">
              Search, play, queue, and control Spotify from a fast menu bar popup without switching spaces or touching the Spotify window.
            </p>
            <div className="mt-10 flex flex-col gap-3 sm:flex-row">
              <Button as="a" href={releaseUrl} target="_blank" rel="noreferrer">
                <Download size={17} />
                Download for macOS
              </Button>
              <Button as="a" href={repoUrl} target="_blank" rel="noreferrer" variant="secondary">
                <Github size={17} />
                Star on GitHub
              </Button>
            </div>
          </section>

          <ProductMock />

          <section id="features" className="mx-auto grid max-w-6xl gap-4 py-24 md:grid-cols-2 lg:grid-cols-4">
            {features.map(({ icon: Icon, title, body }) => (
              <Card key={title} className="min-h-64 p-7 transition duration-200 hover:-translate-y-1 hover:border-white/16 hover:bg-white/[0.055]">
                <Icon className="mb-12 text-cyan-200" size={22} />
                <h3 className="mb-4 text-xl font-black tracking-tight text-white">{title}</h3>
                <p className="text-base font-semibold leading-7 text-white/46">{body}</p>
              </Card>
            ))}
          </section>

          <section className="mx-auto grid max-w-6xl items-center gap-10 py-12 lg:grid-cols-[0.9fr_1.1fr] lg:py-24">
            <div>
              <Badge className="mb-6">FLOW CONTROL</Badge>
              <h2 className="max-w-xl text-balance text-[clamp(3.25rem,7vw,6.5rem)] font-black leading-[0.88] tracking-[-0.08em] text-white">
                Stay in your app. Change the song.
              </h2>
              <p className="mt-8 max-w-xl text-lg font-semibold leading-8 text-white/50">
                SpotifyTray is built for the moment you know the track you want but do not want to break focus. The shortcuts are tiny, predictable, and global.
              </p>
              <div className="mt-8 space-y-4">
                {["Popup search from anywhere", "Queue tracks without changing windows", "Now playing visible at a glance"].map((item) => (
                  <div key={item} className="flex items-center gap-3 font-semibold text-white/70">
                    <Check size={18} className="text-accent" />
                    {item}
                  </div>
                ))}
              </div>
            </div>
            <HotkeyPanel />
          </section>

          <section id="install" className="mx-auto grid max-w-6xl items-center gap-10 py-16 lg:grid-cols-[0.95fr_1.05fr] lg:py-24">
            <TerminalCard />
            <div>
              <Badge className="mb-6">INSTALL</Badge>
              <h2 className="max-w-xl text-balance text-[clamp(3.25rem,7vw,6.5rem)] font-black leading-[0.88] tracking-[-0.08em] text-white">
                Download, clear quarantine, open.
              </h2>
              <p className="mt-8 max-w-xl text-lg font-semibold leading-8 text-white/50">
                SpotifyTray is unsigned for now. The setup is simple: install the app, approve macOS once, add your Spotify Client ID, and keep credentials local.
              </p>

              <Badge className="mt-8 bg-white/[0.055] text-white/62">If macOS blocks it</Badge>

              <div className="mt-8 grid gap-3">
                {installSteps.map((step, index) => (
                  <div key={step} className="flex gap-4 rounded-2xl border border-white/8 bg-white/[0.025] p-4">
                    <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-white/8 text-sm font-black text-white/75">{index + 1}</div>
                    <p className="font-semibold leading-7 text-white/58">{step}</p>
                  </div>
                ))}
              </div>

              <p className="mt-6 text-sm leading-6 text-white/42">
                Exact redirect URI: <code className="rounded bg-white/8 px-2 py-1 font-mono text-white/70">{redirectUri}</code>. Need the full Spotify setup?{" "}
                <a href={readmeUrl} target="_blank" rel="noreferrer" className="font-bold text-white/75 underline decoration-white/20 underline-offset-4 hover:text-white">
                  Read the README
                </a>
                .
              </p>
            </div>
          </section>

          <section className="mx-auto max-w-4xl py-24 text-center">
            <h2 className="text-balance text-[clamp(3rem,7vw,6rem)] font-black leading-[0.88] tracking-[-0.08em] text-white">
              Give Spotify a command bar.
            </h2>
            <p className="mx-auto mt-6 max-w-2xl text-lg font-semibold leading-8 text-white/48">
              Install SpotifyTray, paste your Client ID, and search your music without breaking focus.
            </p>
            <div className="mt-9 flex flex-col justify-center gap-3 sm:flex-row">
              <Button as="a" href={releaseUrl} target="_blank" rel="noreferrer">
                <Download size={17} />
                Download for macOS
              </Button>
              <Button as="a" href={repoUrl} target="_blank" rel="noreferrer" variant="secondary">
                View source
                <ArrowRight size={17} />
              </Button>
            </div>
          </section>
        </main>

        <footer className="mx-auto flex max-w-6xl flex-col gap-5 border-t border-white/[0.06] py-8 text-sm font-semibold text-white/36 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-3">
            <LogoMark />
            <span>© 2026 SpotifyTray · MIT</span>
          </div>
          <div className="flex gap-6">
            <a href={repoUrl} target="_blank" rel="noreferrer" className="hover:text-white">GitHub</a>
            <a href={releaseUrl} target="_blank" rel="noreferrer" className="hover:text-white">Download</a>
          </div>
        </footer>
      </div>
    </div>
  );
}
