"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ChevronRight } from "lucide-react";
import { getLevelColor } from "@/lib/utils";
import type { LevelMeta } from "@/types/curriculum";

interface LevelCardProps {
  level: LevelMeta;
  index: number;
  completedLessons?: number;
  totalLessons?: number;
}

export function LevelCard({ level, index, completedLessons = 0, totalLessons = 0 }: LevelCardProps) {
  const color = getLevelColor(level.slug);
  const progress = totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05, duration: 0.3 }}
    >
      <Link href={`/curriculum/${level.slug}`} className="block group">
        <div className="relative rounded-2xl border border-border bg-surface-raised p-6 hover:shadow-lg transition-all duration-300 overflow-hidden">
          {/* Color accent bar */}
          <div
            className="absolute top-0 left-0 right-0 h-1"
            style={{ backgroundColor: color }}
          />

          <div className="flex items-start justify-between">
            <div className="flex items-center gap-4">
              <div
                className="flex items-center justify-center w-12 h-12 rounded-xl text-white font-display font-bold text-lg"
                style={{ backgroundColor: color }}
              >
                {level.shortName}
              </div>
              <div>
                <h3 className="font-display font-semibold text-lg group-hover:text-primary-600 transition-colors">
                  {level.name}
                </h3>
                <p className="text-sm text-muted-foreground">{level.yearRange}</p>
              </div>
            </div>
            <ChevronRight className="h-5 w-5 text-muted-foreground group-hover:text-primary-600 transition-colors mt-1" />
          </div>

          <p className="mt-3 text-sm text-muted-foreground line-clamp-2">
            {level.description}
          </p>

          {/* Progress bar */}
          {totalLessons > 0 && (
            <div className="mt-4">
              <div className="flex justify-between text-xs text-muted-foreground mb-1">
                <span>{completedLessons} of {totalLessons} lessons</span>
                <span>{Math.round(progress)}%</span>
              </div>
              <div className="h-2 rounded-full bg-muted overflow-hidden">
                <motion.div
                  className="h-full rounded-full"
                  style={{ backgroundColor: color }}
                  initial={{ width: 0 }}
                  animate={{ width: `${progress}%` }}
                  transition={{ duration: 0.8, ease: "easeOut" }}
                />
              </div>
            </div>
          )}
        </div>
      </Link>
    </motion.div>
  );
}
