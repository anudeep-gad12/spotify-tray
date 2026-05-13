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
        "rounded-[28px] border border-white/8 bg-white/[0.045] backdrop-blur-sm",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
