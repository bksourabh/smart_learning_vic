export const SITE_NAME = "Smart Learning";
export const SITE_DESCRIPTION = "Master Maths, One Level at a Time — Victorian Curriculum Aligned";

export const STRAND_ICONS: Record<string, string> = {
  number: "Hash",
  algebra: "Variable",
  measurement: "Ruler",
  space: "Shapes",
  statistics: "BarChart3",
};

export const DIFFICULTY_LABELS: Record<string, string> = {
  easy: "Beginner",
  medium: "Intermediate",
  hard: "Advanced",
};

export const DIFFICULTY_COLORS: Record<string, string> = {
  easy: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400",
  medium: "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400",
  hard: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400",
};

export const XP_PER_LESSON = 10;
export const XP_PER_PRACTICE = 25;
export const XP_BONUS_PERFECT = 50;
