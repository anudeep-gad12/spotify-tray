import { Download } from "lucide-react";
import { DOWNLOAD_URL } from "../constants";

export function FinalCta() {
  return (
    <section className="finalCta">
      <div className="container finalCtaInner">
        <h2>Give Spotify a command bar.</h2>
        <p>Install SpotifyTray, paste your Client ID, and search your music without breaking focus.</p>
        <a className="btn btnPrimary btnPrimary--hero" href={DOWNLOAD_URL} download="SpotifyTray.dmg">
          <Download size={18} aria-hidden />
          Download for macOS
        </a>
      </div>
    </section>
  );
}
