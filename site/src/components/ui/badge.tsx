import type { HTMLAttributes, ReactNode } from "react";
import { cn } from "../../lib/utils";

export function Badge({
  className,
  children,
  ...props
}: HTMLAttributes<HTMLDivElement> & { children: ReactNode }) {
  return (
    <div
      className={cn(
        "inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.045] px-4 py-2 text-xs font-black uppercase tracking-[0.18em] text-white/58",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
