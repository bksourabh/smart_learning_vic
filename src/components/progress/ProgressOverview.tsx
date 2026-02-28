"use client";

import { motion } from "framer-motion";
import { BookOpen, ClipboardCheck, Flame, Star } from "lucide-react";

interface ProgressOverviewProps {
  totalLessons: number;
  totalTests: number;
  streak: number;
  totalXp: number;
}

const stats = [
  { key: "lessons", label: "Lessons Completed", icon: BookOpen, color: "text-primary-600 bg-primary-100 dark:bg-primary-900/30" },
  { key: "tests", label: "Tests Passed", icon: ClipboardCheck, color: "text-correct bg-correct-light dark:bg-correct-dark/20" },
  { key: "streak", label: "Day Streak", icon: Flame, color: "text-amber-600 bg-amber-100 dark:bg-amber-900/30" },
  { key: "xp", label: "Total XP", icon: Star, color: "text-violet-600 bg-violet-100 dark:bg-violet-900/30" },
];

export function ProgressOverview({ totalLessons, totalTests, streak, totalXp }: ProgressOverviewProps) {
  const values: Record<string, number> = {
    lessons: totalLessons,
    tests: totalTests,
    streak,
    xp: totalXp,
  };

  return (
    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
      {stats.map((stat, i) => (
        <motion.div
          key={stat.key}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: i * 0.1 }}
          className="rounded-2xl border border-border bg-surface-raised p-5 text-center"
        >
          <div className={`inline-flex items-center justify-center w-10 h-10 rounded-xl ${stat.color} mb-3`}>
            <stat.icon className="h-5 w-5" />
          </div>
          <div className="font-display text-2xl font-bold">{values[stat.key]}</div>
          <div className="text-xs text-muted-foreground mt-1">{stat.label}</div>
        </motion.div>
      ))}
    </div>
  );
}
