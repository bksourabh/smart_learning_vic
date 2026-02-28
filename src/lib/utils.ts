import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatPercentage(value: number): string {
  return `${Math.round(value)}%`;
}

export function getStrandColor(strandSlug: string): string {
  const colors: Record<string, string> = {
    number: "#f59e0b",
    algebra: "#8b5cf6",
    measurement: "#10b981",
    space: "#f43f5e",
    statistics: "#06b6d4",
  };
  return colors[strandSlug] || "#3b82f6";
}

export function getStrandBgClass(strandSlug: string): string {
  const classes: Record<string, string> = {
    number: "bg-strand-number",
    algebra: "bg-strand-algebra",
    measurement: "bg-strand-measurement",
    space: "bg-strand-space",
    statistics: "bg-strand-statistics",
  };
  return classes[strandSlug] || "bg-primary-500";
}

export function getStrandLightBgClass(strandSlug: string): string {
  const classes: Record<string, string> = {
    number: "bg-strand-number-light",
    algebra: "bg-strand-algebra-light",
    measurement: "bg-strand-measurement-light",
    space: "bg-strand-space-light",
    statistics: "bg-strand-statistics-light",
  };
  return classes[strandSlug] || "bg-primary-50";
}

export function getStrandTextClass(strandSlug: string): string {
  const classes: Record<string, string> = {
    number: "text-strand-number-dark",
    algebra: "text-strand-algebra-dark",
    measurement: "text-strand-measurement-dark",
    space: "text-strand-space-dark",
    statistics: "text-strand-statistics-dark",
  };
  return classes[strandSlug] || "text-primary-700";
}

export function getLevelColor(levelSlug: string): string {
  const colors: Record<string, string> = {
    foundation: "#f59e0b",
    "level-1": "#ef4444",
    "level-2": "#f97316",
    "level-3": "#84cc16",
    "level-4": "#22c55e",
    "level-5": "#14b8a6",
    "level-6": "#06b6d4",
    "level-7": "#3b82f6",
    "level-8": "#6366f1",
    "level-9": "#8b5cf6",
    "level-10": "#a855f7",
  };
  return colors[levelSlug] || "#3b82f6";
}

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

export function getTodayDateString(): string {
  return new Date().toISOString().split("T")[0];
}
