import { useCallback, useEffect, useRef } from "react";
import { Download } from "lucide-react";
import { InstallCommand } from "../components/InstallCommand";
import {
  APP_DEMO_VIDEO_HEIGHT,
  APP_DEMO_VIDEO_MP4,
  APP_DEMO_VIDEO_WIDTH,
  BREW_COMMAND,
  DOCS_URL,
  DOWNLOAD_URL,
  GITHUB_URL,
} from "../constants";

export function HeroSection() {
  const videoRef = useRef<HTMLVideoElement | null>(null);

  // Callback ref: Safari decides whether to allow autoplay when the element is
  // first created, and React only sets the `muted` *property* (not the DOM
  // attribute Safari inspects) — by the time useEffect runs, Safari has already
  // blocked it. Setting muted here, during commit before first paint, gives the
  // best shot at genuine autoplay without any user interaction.
  const setVideoRef = useCallback((node: HTMLVideoElement | null) => {
    videoRef.current = node;
    if (!node) return;
    node.defaultMuted = true;
    node.muted = true;
    void node.play().catch(() => {
      // Still blocked (e.g. Low Power Mode); the effect below sets up fallbacks.
    });
  }, []);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    // Keep muted asserted in case React re-applied props after the ref ran.
    video.defaultMuted = true;
    video.muted = true;

    const tryPlay = () => {
      void video.play().catch(() => {
        // Autoplay blocked; falls back to starting on first interaction below.
      });
    };

    tryPlay();
    video.addEventListener("loadeddata", tryPlay);
    video.addEventListener("canplay", tryPlay);

    // Fallback for browsers that block muted autoplay (e.g. Low Power Mode):
    // start playback on the user's first interaction anywhere on the page, so
    // they never have to find and click the video's own play button.
    const onFirstInteraction = () => {
      tryPlay();
      window.removeEventListener("pointerdown", onFirstInteraction);
      window.removeEventListener("keydown", onFirstInteraction);
      window.removeEventListener("scroll", onFirstInteraction);
    };
    window.addEventListener("pointerdown", onFirstInteraction, { passive: true });
    window.addEventListener("keydown", onFirstInteraction);
    window.addEventListener("scroll", onFirstInteraction, { passive: true });

    return () => {
      video.removeEventListener("loadeddata", tryPlay);
      video.removeEventListener("canplay", tryPlay);
      window.removeEventListener("pointerdown", onFirstInteraction);
      window.removeEventListener("keydown", onFirstInteraction);
      window.removeEventListener("scroll", onFirstInteraction);
    };
  }, []);

  return (
    <section id="top" className="hero">
      <div className="heroInner container">
        <h1 id="hero-heading" className="heroTitle">
          A Spotlight for Spotify on macOS.
        </h1>
        <p className="heroLead">
          Search, play, queue, and control Spotify from a fast menu bar popup without switching spaces or touching the
          Spotify window.
        </p>
        <div className="heroActions">
          <a className="btn btnPrimary btnPrimary--hero" href={DOWNLOAD_URL} download="SpotifyTray.dmg">
            <Download size={18} aria-hidden />
            Download for macOS
          </a>
        </div>
        <div className="heroFoot">
          <InstallCommand command={BREW_COMMAND} className="installCmd--hero" label="Or install with Homebrew" />
          <p className="heroNote">
            MIT open source ·{" "}
            <a href={DOWNLOAD_URL} download="SpotifyTray.dmg">
              DMG
            </a>
            {" · "}
            <a href={DOCS_URL} target="_blank" rel="noreferrer">
              README
            </a>
            {" · "}
            <a href={GITHUB_URL} target="_blank" rel="noreferrer">
              GitHub
            </a>
          </p>
        </div>
      </div>
      <figure className="heroShot container">
        <video
          ref={setVideoRef}
          className="heroMedia"
          width={APP_DEMO_VIDEO_WIDTH}
          height={APP_DEMO_VIDEO_HEIGHT}
          preload="auto"
          autoPlay
          muted
          loop
          playsInline
          disablePictureInPicture
          aria-label="SpotifyTray product demo"
        >
          <source src={APP_DEMO_VIDEO_MP4} type="video/mp4" />
        </video>
      </figure>
    </section>
  );
}
