"use client";

import React from "react";
import { motion } from "framer-motion";
import { cn, formatPercentage } from "@/lib/utils";

export interface ProgressBarProps extends React.HTMLAttributes<HTMLDivElement> {
  value: number;
  max?: number;
  color?: string;
  showLabel?: boolean;
  size?: "sm" | "md" | "lg";
  animated?: boolean;
}

const sizeClasses: Record<string, string> = {
  sm: "h-2",
  md: "h-3",
  lg: "h-4",
};

const ProgressBar = React.forwardRef<HTMLDivElement, ProgressBarProps>(
  (
    {
      className,
      value,
      max = 100,
      color = "#3b82f6",
      showLabel = true,
      size = "md",
      animated = true,
      ...props
    },
    ref
  ) => {
    const percentage = Math.min(Math.max((value / max) * 100, 0), 100);

    return (
      <div ref={ref} className={cn("w-full", className)} {...props}>
        {showLabel && (
          <div className="mb-1.5 flex items-center justify-between">
            <span className="text-xs font-medium text-gray-500">Progress</span>
            <span className="text-xs font-bold" style={{ color }}>
              {formatPercentage(percentage)}
            </span>
          </div>
        )}
        <div
          className={cn(
            "w-full overflow-hidden rounded-full bg-gray-100",
            sizeClasses[size]
          )}
        >
          <motion.div
            className="h-full rounded-full"
            style={{ backgroundColor: color }}
            initial={animated ? { width: 0 } : { width: `${percentage}%` }}
            animate={{ width: `${percentage}%` }}
            transition={
              animated
                ? { duration: 0.8, ease: "easeOut" }
                : { duration: 0 }
            }
          />
        </div>
      </div>
    );
  }
);

ProgressBar.displayName = "ProgressBar";

export { ProgressBar };
