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
  "inline-flex items-center justify-center gap-2 rounded-full px-5 py-3 text-sm font-semibold transition duration-200 focus:outline-none focus:ring-2 focus:ring-accent/40";

const variants = {
  primary:
    "bg-accent text-slate-950 shadow-[0_12px_34px_rgba(86,211,100,0.28)] hover:-translate-y-0.5 hover:brightness-110",
  secondary:
    "border border-white/10 bg-white/5 text-white hover:-translate-y-0.5 hover:border-white/20 hover:bg-white/8"
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
