import React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const skeletonVariants = cva(
  "animate-shimmer bg-gradient-to-r from-gray-200 via-gray-100 to-gray-200 bg-[length:200%_100%]",
  {
    variants: {
      variant: {
        text: "h-4 w-full rounded-md",
        card: "h-40 w-full rounded-2xl",
        circle: "rounded-full",
      },
    },
    defaultVariants: {
      variant: "text",
    },
  }
);

export interface SkeletonProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof skeletonVariants> {
  width?: string | number;
  height?: string | number;
}

const Skeleton = React.forwardRef<HTMLDivElement, SkeletonProps>(
  ({ className, variant, width, height, style, ...props }, ref) => {
    const sizeStyle: React.CSSProperties = {
      ...style,
      ...(width != null ? { width } : {}),
      ...(height != null ? { height } : {}),
    };

    // For circle variant, default to square dimensions if only one is provided
    if (variant === "circle") {
      if (width && !height) sizeStyle.height = width;
      if (height && !width) sizeStyle.width = height;
      if (!width && !height) {
        sizeStyle.width = "3rem";
        sizeStyle.height = "3rem";
      }
    }

    return (
      <div
        ref={ref}
        className={cn(skeletonVariants({ variant }), className)}
        style={sizeStyle}
        aria-hidden="true"
        {...props}
      />
    );
  }
);

Skeleton.displayName = "Skeleton";

export { Skeleton, skeletonVariants };
