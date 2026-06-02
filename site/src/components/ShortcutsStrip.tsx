const SHORTCUTS = [
  { key: "⌘⇧Space", action: "Open popup" },
  { key: "Enter", action: "Play" },
  { key: "⌘Enter", action: "Queue" },
  { key: "⌃⌥P", action: "Play / pause" },
  { key: "⌃⌥N", action: "Next" },
  { key: "⌃⌥B", action: "Previous" },
] as const;

export function ShortcutsStrip() {
  return (
    <section className="shortcutsStrip container" aria-labelledby="shortcuts-heading">
      <header className="shortcutsStripHeader">
        <h2 id="shortcuts-heading">Control Spotify without leaving your app.</h2>
        <p className="shortcutsStripLead">
          Global shortcuts summon the popup, play tracks, and skip — no Cmd+Tab to the Spotify window.
        </p>
      </header>
      <ul className="shortcutsGrid">
        {SHORTCUTS.map((shortcut) => (
          <li key={shortcut.key} className="shortcutCard">
            <strong>{shortcut.action}</strong>
            <span>{shortcut.key}</span>
          </li>
        ))}
      </ul>
      <ul className="shortcutsFacts">
        <li>Global hotkeys</li>
        <li>Menu bar native</li>
        <li>No Cmd+Tab</li>
      </ul>
    </section>
  );
}
