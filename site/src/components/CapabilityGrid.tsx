import {
  CirclePlay,
  Disc3,
  History,
  Keyboard,
  ListMusic,
  Menu,
  Music4,
  ScanSearch,
  Shield,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

type Capability = {
  icon: LucideIcon;
  title: string;
  description: string;
};

const CAPABILITIES: Capability[] = [
  {
    icon: ScanSearch,
    title: "Instant popup search",
    description: "Summon a polished search window with one hotkey and find tracks without touching Spotify.",
  },
  {
    icon: Music4,
    title: "Play or queue",
    description: "Hit Enter to play now, or Cmd+Enter to queue the next track while staying in your current app.",
  },
  {
    icon: CirclePlay,
    title: "Now playing glance",
    description: "Keep the current song, artist, device, and playback state visible inside the popup.",
  },
  {
    icon: Keyboard,
    title: "Global controls",
    description: "Play, pause, next, and previous from anywhere on your Mac with compact shortcuts.",
  },
  {
    icon: Disc3,
    title: "Album art in results",
    description: "Live search results show artwork so you pick the right track at a glance.",
  },
  {
    icon: History,
    title: "Recent searches",
    description: "Jump back to tracks you looked up recently without retyping.",
  },
  {
    icon: ListMusic,
    title: "Queue tab",
    description: "See what is up next and manage the queue from the same popup.",
  },
  {
    icon: Menu,
    title: "Menu bar app",
    description: "Lives in the menu bar — no Dock icon clutter, always one hotkey away.",
  },
  {
    icon: Shield,
    title: "MIT open source",
    description: "Fork and change what you want. Your Spotify Client ID stays on your Mac.",
  },
];

export function CapabilityGrid() {
  return (
    <section id="capabilities" className="capabilitySection container" aria-labelledby="capabilities-heading">
      <header className="capabilityHeader">
        <h2 id="capabilities-heading">Built for focus on your Mac</h2>
        <p>Search, play, queue, and glance at now playing — without leaving the app you are in.</p>
      </header>
      <ul className="capabilityGrid">
        {CAPABILITIES.map((item) => {
          const Icon = item.icon;
          return (
            <li key={item.title} className="capabilityItem">
              <Icon className="capabilityIcon" size={20} aria-hidden />
              <div className="capabilityText">
                <h3>{item.title}</h3>
                <p>{item.description}</p>
              </div>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
