import type { AnchorHTMLAttributes, ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "../../lib/utils";

type ButtonProps =
  | ({
      as?: "button";
      variant?: "primary" | "secondary";
      children: ReactNode;
    } & ButtonHTMLAttributes<HTMLButtonElement>)
  | ({
      as: "a";
      variant?: "primary" | "secondary";
      children: ReactNode;
    } & AnchorHTMLAttributes<HTMLAnchorElement>);

const base =
  "inline-flex items-center justify-center gap-2 rounded-[18px] px-7 py-4 text-base font-black tracking-[-0.02em] transition duration-200 focus:outline-none focus:ring-2 focus:ring-accent/40";

const variants = {
  primary:
    "bg-white text-black shadow-[0_22px_70px_rgba(255,255,255,0.16)] hover:-translate-y-0.5 hover:bg-white/90",
  secondary:
    "border border-white/12 bg-white/[0.035] text-white hover:-translate-y-0.5 hover:border-white/24 hover:bg-white/[0.07]",
};

export function Button(props: ButtonProps) {
  const variant = props.variant ?? "primary";

  if (props.as === "a") {
    const { className, children, ...rest } = props;
    return (
      <a className={cn(base, variants[variant], className)} {...rest}>
        {children}
      </a>
    );
  }

  const { className, children, ...rest } = props;
  return (
    <button className={cn(base, variants[variant], className)} {...rest}>
      {children}
    </button>
  );
}
