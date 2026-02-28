"use client";

import React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { motion, type HTMLMotionProps } from "framer-motion";
import { Loader2 } from "lucide-react";
import { cn, getStrandColor } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 rounded-xl font-semibold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-400 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        primary:
          "bg-primary-500 text-white hover:bg-primary-600 shadow-md shadow-primary-500/25",
        secondary:
          "bg-primary-100 text-primary-700 hover:bg-primary-200",
        outline:
          "border-2 border-primary-300 text-primary-600 hover:bg-primary-50 hover:border-primary-400",
        ghost:
          "text-primary-600 hover:bg-primary-50",
        strand: "",
      },
      size: {
        sm: "h-8 px-3 text-sm rounded-lg",
        md: "h-10 px-5 text-sm",
        lg: "h-12 px-7 text-base",
      },
    },
    defaultVariants: {
      variant: "primary",
      size: "md",
    },
  }
);

export interface ButtonProps
  extends Omit<HTMLMotionProps<"button">, "children">,
    VariantProps<typeof buttonVariants> {
  children: React.ReactNode;
  loading?: boolean;
  strandSlug?: string;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant,
      size,
      loading = false,
      disabled,
      strandSlug,
      children,
      ...props
    },
    ref
  ) => {
    const isDisabled = disabled || loading;

    const strandStyle: React.CSSProperties =
      variant === "strand" && strandSlug
        ? {
            backgroundColor: getStrandColor(strandSlug),
            color: "#fff",
          }
        : {};

    return (
      <motion.button
        ref={ref}
        className={cn(buttonVariants({ variant, size }), className)}
        style={strandStyle}
        disabled={isDisabled}
        whileHover={{ scale: isDisabled ? 1 : 1.03 }}
        whileTap={{ scale: isDisabled ? 1 : 0.97 }}
        transition={{ type: "spring", stiffness: 400, damping: 17 }}
        {...props}
      >
        {loading && <Loader2 className="h-4 w-4 animate-spin" />}
        {children}
      </motion.button>
    );
  }
);

Button.displayName = "Button";

export { Button, buttonVariants };
