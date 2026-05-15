import type { HTMLAttributes, ReactNode } from "react";
import { cn } from "../../lib/utils";

export function Card({
  className,
  children,
  ...props
}: HTMLAttributes<HTMLDivElement> & { children: ReactNode }) {
  return (
    <div
      className={cn(
        "rounded-[34px] border border-white/10 bg-white/[0.035] shadow-[inset_0_1px_0_rgba(255,255,255,0.04)] backdrop-blur-sm",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
