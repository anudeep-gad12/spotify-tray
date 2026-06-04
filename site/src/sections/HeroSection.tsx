import { useEffect, useRef } from "react";
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

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const play = () => {
      video.defaultMuted = true;
      video.muted = true;
      video.autoplay = true;
      video.loop = true;
      video.playsInline = true;
      void video.play().catch(() => {
        // Browser blocked autoplay; it will still play when the user interacts.
      });
    };

    play();
    video.addEventListener("loadeddata", play);
    video.addEventListener("canplay", play);

    return () => {
      video.removeEventListener("loadeddata", play);
      video.removeEventListener("canplay", play);
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
          ref={videoRef}
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
