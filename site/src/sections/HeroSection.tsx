import { Download } from "lucide-react";
import { InstallCommand } from "../components/InstallCommand";
import { BREW_COMMAND, DOCS_URL, DOWNLOAD_URL, GITHUB_URL } from "../constants";

export function HeroSection() {
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
      <div className="heroVisual">
        <figure className="heroVisualFrame">
          <picture>
            <source srcSet="/images/spotifytray-hero.webp" type="image/webp" />
            <img
              src="/images/spotifytray-hero.png"
              alt="SpotifyTray search popup on macOS"
              width={1568}
              height={1426}
              sizes="800px"
              loading="eager"
              decoding="async"
              fetchPriority="high"
            />
          </picture>
        </figure>
      </div>
    </section>
  );
}
