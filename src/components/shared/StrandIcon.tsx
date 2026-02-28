import {
  Hash,
  Variable,
  Ruler,
  Shapes,
  BarChart3,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";

const iconMap: Record<string, LucideIcon> = {
  number: Hash,
  algebra: Variable,
  measurement: Ruler,
  space: Shapes,
  statistics: BarChart3,
  Hash: Hash,
  Variable: Variable,
  Ruler: Ruler,
  Shapes: Shapes,
  BarChart3: BarChart3,
};

interface StrandIconProps {
  strand: string;
  className?: string;
  size?: number;
}

export function StrandIcon({ strand, className, size = 24 }: StrandIconProps) {
  const Icon = iconMap[strand] || Hash;
  return <Icon className={cn("", className)} size={size} />;
}
