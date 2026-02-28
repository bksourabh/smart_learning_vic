import React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn, getStrandColor } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center justify-center rounded-full font-semibold whitespace-nowrap",
  {
    variants: {
      variant: {
        default: "bg-primary-100 text-primary-700",
        strand: "",
        difficulty: "bg-amber-100 text-amber-800",
        success: "bg-correct-light text-correct-dark",
        error: "bg-incorrect-light text-incorrect-dark",
      },
      size: {
        sm: "px-2 py-0.5 text-xs",
        md: "px-3 py-1 text-sm",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "md",
    },
  }
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {
  strandSlug?: string;
}

const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
  ({ className, variant, size, strandSlug, children, ...props }, ref) => {
    const strandStyle: React.CSSProperties =
      variant === "strand" && strandSlug
        ? {
            backgroundColor: `${getStrandColor(strandSlug)}20`,
            color: getStrandColor(strandSlug),
          }
        : {};

    return (
      <span
        ref={ref}
        className={cn(badgeVariants({ variant, size }), className)}
        style={strandStyle}
        {...props}
      >
        {children}
      </span>
    );
  }
);

Badge.displayName = "Badge";

export { Badge, badgeVariants };
