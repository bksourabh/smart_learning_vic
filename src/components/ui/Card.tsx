"use client";

import React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { motion, type HTMLMotionProps } from "framer-motion";
import { cn } from "@/lib/utils";

const cardVariants = cva(
  "rounded-2xl bg-white border border-gray-100 overflow-hidden",
  {
    variants: {
      variant: {
        default: "shadow-sm",
        raised: "shadow-lg shadow-gray-200/60",
        interactive: "shadow-md cursor-pointer",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
);

export interface CardProps
  extends Omit<HTMLMotionProps<"div">, "children">,
    VariantProps<typeof cardVariants> {
  children: React.ReactNode;
  header?: React.ReactNode;
  footer?: React.ReactNode;
}

const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant, header, footer, children, ...props }, ref) => {
    const isInteractive = variant === "interactive";

    return (
      <motion.div
        ref={ref}
        className={cn(cardVariants({ variant }), className)}
        whileHover={
          isInteractive
            ? { y: -4, boxShadow: "0 20px 40px -12px rgba(0,0,0,0.12)" }
            : undefined
        }
        transition={{ type: "spring", stiffness: 300, damping: 20 }}
        {...props}
      >
        {header && (
          <div className="border-b border-gray-100 px-5 py-4">{header}</div>
        )}
        <div className="px-5 py-4">{children}</div>
        {footer && (
          <div className="border-t border-gray-100 px-5 py-4">{footer}</div>
        )}
      </motion.div>
    );
  }
);

Card.displayName = "Card";

export { Card, cardVariants };
