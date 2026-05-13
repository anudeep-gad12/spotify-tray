import { ArrowRight, CirclePlay, Download, Github, Keyboard, Music4, ScanSearch, Sparkles, Terminal } from "lucide-react";
import { useState } from "react";
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
    body: "Bring up Spotify with one hotkey, search tracks live, and hit enter."
  },
  {
    icon: Music4,
    title: "Queue without losing flow",
    body: "Drop songs into queue from the popup while staying inside your current app."
  },
  {
    icon: CirclePlay,
    title: "Now playing at a glance",
    body: "Quick-check what’s currently on without dragging Spotify back into view."
  },
  {
    icon: Keyboard,
    title: "Global controls",
    body: "Play, pause, next, and previous from anywhere on your Mac."
  }
];

const quickInstallSteps = [
  "Download SpotifyTray.app.zip from the latest release, unzip it, and move SpotifyTray.app into ~/Applications.",
  "Right-click SpotifyTray.app and choose Open once to approve the unsigned app.",
  `Create a Spotify developer app and add ${redirectUri} as the redirect URI.`,
  "Paste only your Spotify Client ID, not the secret, sign in once, and use ⌘⇧Space from anywhere."
];

const fallbackInstallSteps = [
  "Download SpotifyTray.app.zip from the latest release, unzip it, and move SpotifyTray.app into ~/Applications.",
  "If macOS blocks it, run the quarantine-removal commands below.",
  `Create a Spotify developer app and add ${redirectUri} as the redirect URI.`,
  "Paste only your Spotify Client ID, not the secret, sign in once, and use ⌘⇧Space from anywhere."
];

export default function App() {
  const [installMode, setInstallMode] = useState<"quick" | "fallback">("quick");

  return (
    <div className="min-h-screen bg-transparent text-text">
      <div className="mx-auto max-w-6xl px-6 pb-24 pt-8 sm:px-8 lg:px-10">
        <header className="mb-12 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-2xl border border-white/10 bg-accent/12 text-accent shadow-glow">
              <Music4 size={18} />
            </div>
            <div>
              <div className="text-lg font-bold tracking-tight">SpotifyTray</div>
              <div className="text-sm text-white/45">macOS utility</div>
            </div>
          </div>

          <div className="hidden items-center gap-3 sm:flex">
            <Button as="a" href={repoUrl} target="_blank" rel="noreferrer" variant="secondary">
              <Github size={16} />
              GitHub
            </Button>
            <Button as="a" href={releaseUrl} target="_blank" rel="noreferrer">
              <Download size={16} />
              Download
            </Button>
          </div>
        </header>

        <main className="space-y-10">
          <section className="grid gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
            <div className="space-y-6">
              <Badge className="bg-accentSoft text-accent">
                <Sparkles size={12} />
                Built for people tired of switching back to Spotify
              </Badge>

              <div className="space-y-4">
                <h1 className="max-w-3xl text-balance text-5xl font-black tracking-tight text-white sm:text-6xl">
                  A Spotlight for Spotify on macOS.
                </h1>
                <p className="max-w-2xl text-lg leading-8 text-white/62">
                  Stop switching spaces, dragging another monitor into focus, and clicking through the Spotify app just to
                  change a song. Press a hotkey, type, hit enter, stay in flow.
                </p>
              </div>

              <div className="flex flex-col gap-3 sm:flex-row">
                <Button as="a" href={releaseUrl} target="_blank" rel="noreferrer">
                  <Download size={16} />
                  Download for macOS
                </Button>
                <Button as="a" href="#install" variant="secondary">
                  See install steps
                  <ArrowRight size={16} />
                </Button>
              </div>

              <div className="flex flex-wrap gap-3 pt-1">
                <Badge>⌘⇧Space popup</Badge>
                <Badge>Search + play + queue</Badge>
                <Badge>Now playing</Badge>
                <Badge>Spotify Premium required</Badge>
              </div>
            </div>

            <Card className="relative overflow-hidden p-5 shadow-hero">
              <div className="absolute inset-0 bg-hero-grid bg-[size:32px_32px] opacity-[0.06]" />
              <div className="relative space-y-4">
                <div className="rounded-[24px] border border-white/10 bg-[#0c1219] p-5 shadow-[0_20px_40px_rgba(0,0,0,0.35)]">
                  <div className="mb-5 flex items-start justify-between">
                    <div>
                      <div className="text-3xl font-black tracking-tight">SpotifyTray</div>
                      <div className="mt-1 max-w-sm text-sm text-white/48">
                        Search, play, queue, and glance at what’s playing without leaving your current task.
                      </div>
                    </div>
                    <Badge>⌘⇧Space</Badge>
                  </div>

                  <div className="mb-4 rounded-[20px] border border-white/10 bg-white/5 px-5 py-4 text-xl font-bold text-white/72">
                    human sadness
                  </div>

                  <Card className="mb-4 flex items-center gap-4 rounded-[22px] bg-white/[0.03] p-4">
                    <div className="h-14 w-14 rounded-2xl bg-gradient-to-br from-accent/35 to-cyanSoft" />
                    <div className="min-w-0 flex-1">
                      <div className="mb-1 text-[11px] font-bold uppercase tracking-[0.18em] text-white/42">Now Playing</div>
                      <div className="truncate text-lg font-bold">Human Sadness</div>
                      <div className="truncate text-sm text-white/55">The Voidz</div>
                    </div>
                    <div className="rounded-full bg-accentSoft px-3 py-1 text-xs font-bold text-accent">Playing</div>
                  </Card>

                  <div className="space-y-3">
                    {["Human Sadness", "Lazy Boy", "Sadeness - Part I"].map((track, index) => (
                      <div
                        key={track}
                        className={`flex items-center gap-4 rounded-[22px] border px-4 py-3 ${
                          index === 0
                            ? "border-accent/30 bg-accent/10 shadow-[0_0_0_1px_rgba(86,211,100,0.12)]"
                            : "border-white/8 bg-white/[0.03]"
                        }`}
                      >
                        <div className="h-12 w-12 rounded-2xl bg-gradient-to-br from-white/15 to-white/5" />
                        <div className="min-w-0">
                          <div className="truncate font-semibold">{track}</div>
                          <div className="truncate text-sm text-white/48">{index === 2 ? "Enigma" : "The Voidz"}</div>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="mt-5 flex flex-wrap gap-3 text-xs text-white/54">
                    <span className="rounded-full bg-white/6 px-3 py-1.5">Enter Play</span>
                    <span className="rounded-full bg-white/6 px-3 py-1.5">⌘↩ Queue</span>
                    <span className="rounded-full bg-white/6 px-3 py-1.5">⌃⌥P Pause</span>
                  </div>
                </div>
              </div>
            </Card>
          </section>

          <section className="space-y-6 pt-6">
            <div className="space-y-2">
              <div className="text-sm font-bold uppercase tracking-[0.18em] text-white/38">Features</div>
              <h2 className="text-3xl font-black tracking-tight">Everything you need, nothing noisy.</h2>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {features.map(({ icon: Icon, title, body }) => (
                <Card key={title} className="p-6 transition duration-200 hover:-translate-y-1 hover:border-white/14 hover:bg-white/[0.055]">
                  <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-2xl bg-accent/10 text-accent">
                    <Icon size={18} />
                  </div>
                  <h3 className="mb-2 text-xl font-bold">{title}</h3>
                  <p className="leading-7 text-white/58">{body}</p>
                </Card>
              ))}
            </div>
          </section>

          <section id="install" className="space-y-6 pt-6">
            <div className="space-y-3">
              <div className="text-sm font-bold uppercase tracking-[0.18em] text-white/38">Install</div>
              <h2 className="text-3xl font-black tracking-tight">Get running in a couple of minutes.</h2>
              <p className="max-w-3xl leading-7 text-white/58">
                Download the app, open it once, then paste your Spotify Client ID. Spotify Premium is required. If macOS blocks the app, use the fallback command path below.
              </p>
              <div className="flex flex-col gap-3 sm:flex-row">
                <Button as="a" href={releaseUrl} target="_blank" rel="noreferrer">
                  <Download size={16} />
                  Download latest release
                </Button>
                <Button as="a" href={repoUrl} target="_blank" rel="noreferrer" variant="secondary">
                  <Github size={16} />
                  View source
                </Button>
              </div>
            </div>

            <Card className="p-6">
              <div className="mb-5 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <div className="font-bold text-white">Open the app</div>
                  <div className="text-sm text-white/48">Start with the simple path. Use the fallback only if macOS blocks launch.</div>
                </div>

                <div className="inline-flex rounded-full border border-white/10 bg-white/[0.04] p-1">
                  <button
                    type="button"
                    onClick={() => setInstallMode("quick")}
                    className={`rounded-full px-4 py-2 text-sm font-semibold transition ${
                      installMode === "quick"
                        ? "bg-accent text-slate-950 shadow-[0_8px_24px_rgba(86,211,100,0.22)]"
                        : "text-white/60 hover:text-white"
                    }`}
                  >
                    Quick Open
                  </button>
                  <button
                    type="button"
                    onClick={() => setInstallMode("fallback")}
                    className={`rounded-full px-4 py-2 text-sm font-semibold transition ${
                      installMode === "fallback"
                        ? "bg-white/12 text-white"
                        : "text-white/60 hover:text-white"
                    }`}
                  >
                    If macOS blocks it
                  </button>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex gap-4 rounded-[22px] border border-white/8 bg-white/[0.03] p-4">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-white/7 text-sm font-black text-white/84">
                    1
                  </div>
                  <p className="leading-7 text-white/68">{quickInstallSteps[0]}</p>
                </div>

                {installMode === "quick" ? (
                  <div className="flex gap-4 rounded-[22px] border border-white/8 bg-white/[0.03] p-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-white/7 text-sm font-black text-white/84">
                      2
                    </div>
                    <p className="leading-7 text-white/68">{quickInstallSteps[1]}</p>
                  </div>
                ) : (
                  <div className="rounded-[22px] border border-white/8 bg-white/[0.03] p-4">
                    <div className="mb-3 flex gap-4">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-white/7 text-sm font-black text-white/84">
                        2
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="leading-7 text-white/68">{fallbackInstallSteps[1]}</p>
                        <div className="mt-3 overflow-hidden rounded-2xl border border-white/10 bg-black/30">
                          <pre className="overflow-x-auto px-4 py-4 text-sm leading-7 text-white/78">
                            <code>{`xattr -dr com.apple.quarantine ~/Applications/SpotifyTray.app
open ~/Applications/SpotifyTray.app`}</code>
                          </pre>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </Card>

            <Card className="p-6">
              <div className="mb-4 text-sm font-bold uppercase tracking-[0.18em] text-white/38">Finish setup</div>
              <div className="grid gap-3 md:grid-cols-2">
                {quickInstallSteps.slice(2).map((step, index) => (
                  <div key={step} className="flex gap-4 rounded-[22px] border border-white/8 bg-white/[0.03] p-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-white/7 text-sm font-black text-white/84">
                      {index + 3}
                    </div>
                    <p className="leading-7 text-white/68">{step}</p>
                  </div>
                ))}
              </div>
              <p className="mt-5 text-sm leading-6 text-white/46">
                Exact redirect URI: <code className="rounded bg-white/8 px-1.5 py-0.5 text-white/70">{redirectUri}</code>. Need the full Spotify setup or troubleshooting?{" "}
                <a
                  href={readmeUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="font-semibold text-white/80 underline decoration-white/20 underline-offset-4 transition hover:text-white"
                >
                  Read the full README
                </a>
                .
              </p>
            </Card>
          </section>
        </main>
      </div>
    </div>
  );
}
