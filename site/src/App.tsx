import {
  ArrowRight,
  Check,
  CirclePlay,
  Command,
  Copy,
  Download,
  Github,
  Keyboard,
  Music4,
  ScanSearch,
  Sparkles,
} from "lucide-react";
import { useEffect, useState } from "react";
import { Badge } from "./components/ui/badge";
import { Button } from "./components/ui/button";
import { Card } from "./components/ui/card";

const releaseUrl = "https://github.com/anudeep-gad12/spotify-tray/releases/latest";
const repoUrl = "https://github.com/anudeep-gad12/spotify-tray";
const readmeUrl = "https://github.com/anudeep-gad12/spotify-tray#readme";
const redirectUri = "http://127.0.0.1:43821/callback";
const brewCommand = "brew install --cask anudeep-gad12/tap/spotify-tray";

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

function HomebrewInstall({ compact = false }: { compact?: boolean }) {
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!copied) return;
    const timeout = window.setTimeout(() => setCopied(false), 1400);
    return () => window.clearTimeout(timeout);
  }, [copied]);

  const copyCommand = () => {
    void navigator.clipboard?.writeText(brewCommand);
    setCopied(true);
  };

  return (
    <div className={`flex flex-col items-center justify-center gap-3 text-white/40 ${compact ? "mt-6" : "mt-7"} sm:flex-row`}>
      <span className="text-base font-bold sm:text-lg">or install with Homebrew</span>
      <button
        type="button"
        onClick={copyCommand}
        className="group inline-flex max-w-full cursor-pointer items-center gap-3 rounded-full border border-white/10 bg-white/[0.035] px-5 py-3 font-mono text-sm font-bold text-white/76 shadow-[inset_0_1px_0_rgba(255,255,255,0.04)] transition hover:border-white/18 hover:bg-white/[0.055] sm:text-base"
        aria-label="Copy Homebrew install command"
      >
        <span className="truncate">{brewCommand}</span>
        {copied ? (
          <Check size={18} className="shrink-0 text-accent transition" />
        ) : (
          <Copy size={18} className="shrink-0 text-white/42 transition group-hover:text-white/75" />
        )}
      </button>
    </div>
  );
}

function ProductMock() {
  const results = [
    ["Chances", "The Strokes", "3:36", "active"],
    ["80's Comedown Machine", "The Strokes", "4:58", ""],
    ["Ode To The Mets", "The Strokes", "5:51", ""],
    ["Reptilia", "The Strokes", "3:39", ""],
    ["Someday", "The Strokes", "3:07", "fade"],
  ];

  return (
    <Card className="relative mx-auto max-w-5xl overflow-hidden rounded-[30px] border-white/12 bg-[#050506] p-0 shadow-hero">
      <div className="absolute inset-0 bg-hero-grid bg-[size:42px_42px] opacity-[0.08]" />
      <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(255,255,255,0.035),transparent_36%,rgba(0,0,0,0.22))]" />
      <div className="relative p-8 sm:p-10">
        <div className="mb-12 flex items-start justify-between gap-5">
          <div>
            <div className="text-2xl font-semibold tracking-[-0.035em] text-[#eee9dc]">SpotifyTray</div>
            <div className="mt-1 text-sm font-medium text-[#8f8b80]">Search and queue without switching apps.</div>
          </div>
          <div className="flex items-center gap-3 font-mono text-xs font-medium text-[#8f8b80]">
            <span>Cmd+Shift+Space</span>
            <span className="h-1.5 w-1.5 rounded-full bg-accent" />
            <span>ready</span>
          </div>
        </div>

        <div className="mb-8">
          <div className="mb-2 text-sm font-medium text-[#6f6b63]">what do you want to hear?</div>
          <div className="truncate text-5xl font-semibold tracking-[-0.06em] text-[#eee9dc]">chances_</div>
          <div className="mt-4 h-px bg-white/10" />
        </div>

        <div className="mb-8 flex gap-9 text-sm font-medium lowercase">
          <span className="text-[#eee9dc]">search</span>
          <span className="text-[#6f6b63]">recent</span>
          <span className="text-[#6f6b63]">queue</span>
        </div>

        <div className="mb-4 flex items-center justify-between border-b border-white/10 pb-3 font-mono text-xs lowercase text-[#6f6b63]">
          <span>results</span>
          <span>8 live matches</span>
        </div>

        <div className="mb-7">
          {results.map(([track, artist, time, state], index) => (
            <div
              key={track}
              className={`grid grid-cols-[2.5rem_2.5rem_minmax(0,1fr)_10rem_3rem] items-center gap-4 border-b border-white/[0.055] px-2 py-3 ${
                state === "active" ? "rounded-xl bg-white/[0.055]" : state === "fade" ? "opacity-45" : ""
              }`}
            >
              <span className={`font-mono text-xs ${state === "active" ? "text-[#eee9dc]" : "text-[#6f6b63]"}`}>
                {String(index + 1).padStart(2, "0")}
              </span>
              <span className={`h-10 w-10 rounded-[9px] ${index < 2 ? "bg-gradient-to-br from-red-500 to-red-900" : "bg-[conic-gradient(from_90deg,#67e8f9,#facc15,#f472b6,#67e8f9)]"}`} />
              <span className="truncate text-base font-medium text-[#eee9dc]">{track}</span>
              <span className="truncate text-sm text-[#8f8b80]">{artist}</span>
              <span className="text-right font-mono text-xs text-[#6f6b63]">{time}</span>
            </div>
          ))}
        </div>

        <div className="mb-6 flex items-center gap-4">
          <div className="h-[72px] w-[72px] shrink-0 rounded-[14px] bg-[conic-gradient(from_90deg,#67e8f9,#f472b6,#fef08a,#67e8f9)] p-1">
            <div className="h-full w-full rounded-[11px] bg-[repeating-linear-gradient(45deg,#111_0_3px,#fff_3px_5px)] opacity-80" />
          </div>
          <div className="min-w-0 flex-1">
            <div className="mb-1 flex items-center gap-2 font-mono text-[11px] text-[#6f6b63]">
              <span>now playing</span>
              <span className="h-1.5 w-1.5 rounded-full bg-accent" />
              <span>playing</span>
            </div>
            <div className="truncate text-lg font-semibold text-[#eee9dc]">Under Cover of Darkness</div>
            <div className="truncate text-sm text-[#8f8b80]">The Strokes</div>
            <div className="mt-3 h-0.5 bg-white/10">
              <div className="h-full w-[42%] bg-[#aaa599]" />
            </div>
          </div>
          <div className="hidden text-right text-xs text-[#6f6b63] sm:block">
            <div className="font-mono">device</div>
            <div className="mt-1 text-[#8f8b80]">Invincible</div>
          </div>
        </div>

        <div className="flex flex-wrap gap-x-6 gap-y-2 font-mono text-xs text-[#6f6b63]">
          <span>enter play</span>
          <span>cmd enter queue</span>
          <span>tab switch</span>
          <span>esc close</span>
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
            <div className="mb-8 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.035] px-5 py-2.5 text-sm font-black tracking-tight text-white/62 shadow-[inset_0_1px_0_rgba(255,255,255,0.04)] sm:text-base">
              <Sparkles size={14} className="text-cyan-200" />
              No more Cmd+Tab just to change a song.
            </div>
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
            <HomebrewInstall />
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
              <div className="flex justify-start">
                <HomebrewInstall compact />
              </div>

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
            <HomebrewInstall compact />
          </section>
        </main>

        <footer className="mx-auto flex max-w-6xl flex-col gap-5 border-t border-white/[0.06] py-8 text-sm font-semibold text-white/36 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-3">
            <LogoMark />
            <div className="space-y-1">
              <div>© 2026 SpotifyTray · MIT</div>
              <div>
                Built by{" "}
                <a href="https://anudeep.cc" target="_blank" rel="noreferrer" className="text-white/55 underline decoration-white/15 underline-offset-4 transition hover:text-white">
                  Anudeep
                </a>{" "}
                for people who Cmd+Tab too much.
              </div>
            </div>
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
