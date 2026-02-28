"use client";

import { motion } from "framer-motion";
import {
  Footprints,
  BookOpen,
  Star,
  Flame,
  Trophy,
  Award,
  GraduationCap,
  Crown,
  Lock,
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { Achievement } from "@/types/progress";

const iconMap: Record<string, React.ElementType> = {
  Footprints,
  BookOpen,
  Star,
  Flame,
  Trophy,
  Award,
  GraduationCap,
  Crown,
};

const defaultAchievements = [
  { id: "first-lesson", title: "First Steps", icon: "Footprints" },
  { id: "lesson-master-5", title: "Lesson Master", icon: "BookOpen" },
  { id: "perfect-score", title: "Perfect Score", icon: "Star" },
  { id: "streak-3", title: "On a Roll", icon: "Flame" },
  { id: "streak-7", title: "Week Warrior", icon: "Trophy" },
  { id: "strand-complete", title: "Strand Scholar", icon: "Award" },
  { id: "lesson-master-10", title: "Dedicated Learner", icon: "GraduationCap" },
  { id: "lesson-master-25", title: "Maths Champion", icon: "Crown" },
];

interface AchievementGridProps {
  achievements: Record<string, Achievement>;
}

export function AchievementGrid({ achievements }: AchievementGridProps) {
  return (
    <div className="rounded-2xl border border-border bg-surface-raised p-6">
      <h3 className="font-display font-semibold text-lg mb-4">Achievements</h3>

      <div className="grid grid-cols-4 gap-3">
        {defaultAchievements.map((def) => {
          const unlocked = achievements[def.id]?.unlockedAt;
          const Icon = iconMap[def.icon] || Award;

          return (
            <motion.div
              key={def.id}
              whileHover={{ scale: 1.05 }}
              className="text-center"
            >
              <div
                className={cn(
                  "w-12 h-12 mx-auto rounded-xl flex items-center justify-center mb-1 transition-colors",
                  unlocked
                    ? "bg-amber-100 dark:bg-amber-900/30 text-amber-600"
                    : "bg-muted text-muted-foreground opacity-40"
                )}
              >
                {unlocked ? <Icon className="h-6 w-6" /> : <Lock className="h-4 w-4" />}
              </div>
              <span className={cn("text-[10px] leading-tight", !unlocked && "text-muted-foreground")}>
                {def.title}
              </span>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}
