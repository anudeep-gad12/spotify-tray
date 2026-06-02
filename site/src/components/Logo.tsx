interface LogoProps {
  size?: number;
  showWordmark?: boolean;
  className?: string;
}

export function Logo({ size = 28, showWordmark = true, className = "" }: LogoProps) {
  return (
    <span
      className={`logoLockup ${className}`.trim()}
      style={{ display: "inline-flex", alignItems: "center", gap: showWordmark ? 10 : 0 }}
    >
      <img
        src="/logo-mark.svg"
        alt=""
        width={size}
        height={size}
        aria-hidden
        style={{ borderRadius: "22%", display: "block" }}
      />
      {showWordmark ? <span>SpotifyTray</span> : null}
    </span>
  );
}
