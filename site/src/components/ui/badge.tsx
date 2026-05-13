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
        "inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/6 px-3 py-1.5 text-xs font-semibold text-white/78",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
