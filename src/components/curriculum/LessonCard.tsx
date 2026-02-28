"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { BookOpen, Clock, Lock, CheckCircle2, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { DIFFICULTY_COLORS, DIFFICULTY_LABELS } from "@/lib/constants";
import type { Lesson } from "@/types/lesson";

interface LessonCardProps {
  lesson: Lesson;
  index: number;
  isCompleted?: boolean;
  isLocked?: boolean;
}

export function LessonCard({ lesson, index, isCompleted = false, isLocked = false }: LessonCardProps) {
  const href = `/curriculum/${lesson.levelSlug}/${lesson.strandSlug}/${lesson.slug}`;

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.06, duration: 0.3 }}
    >
      <Link
        href={isLocked ? "#" : href}
        className={cn("block group", isLocked && "pointer-events-none")}
        aria-disabled={isLocked}
      >
        <div
          className={cn(
            "relative flex items-center gap-4 rounded-xl border bg-surface-raised p-4 transition-all duration-200",
            isLocked
              ? "border-border opacity-50"
              : isCompleted
                ? "border-correct/30 bg-correct-light/20 dark:bg-correct-dark/10"
                : "border-border hover:shadow-md hover:border-primary-200 dark:hover:border-primary-800"
          )}
        >
          {/* Order indicator */}
          <div className="flex flex-col items-center gap-1">
            <div
              className={cn(
                "flex items-center justify-center w-10 h-10 rounded-full text-sm font-bold",
                isCompleted
                  ? "bg-correct text-white"
                  : isLocked
                    ? "bg-muted text-muted-foreground"
                    : "bg-primary-100 text-primary-700 dark:bg-primary-900/40 dark:text-primary-400"
              )}
            >
              {isCompleted ? (
                <CheckCircle2 className="h-5 w-5" />
              ) : isLocked ? (
                <Lock className="h-4 w-4" />
              ) : (
                lesson.order
              )}
            </div>
            {/* Connecting line */}
            {index > 0 && (
              <div className="absolute -top-4 left-[2.1rem] w-0.5 h-4 bg-border" />
            )}
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <h3 className="font-semibold group-hover:text-primary-600 transition-colors truncate">
                {lesson.title}
              </h3>
              <span
                className={cn(
                  "text-xs px-2 py-0.5 rounded-full font-medium flex-shrink-0",
                  DIFFICULTY_COLORS[lesson.difficulty]
                )}
              >
                {DIFFICULTY_LABELS[lesson.difficulty]}
              </span>
            </div>
            <p className="text-sm text-muted-foreground line-clamp-1">
              {lesson.description}
            </p>
            <div className="flex items-center gap-3 mt-2 text-xs text-muted-foreground">
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {lesson.estimatedMinutes} min
              </span>
              <span className="flex items-center gap-1">
                <BookOpen className="h-3 w-3" />
                {lesson.sections.length} sections
              </span>
            </div>
          </div>

          {!isLocked && (
            <ChevronRight className="h-5 w-5 text-muted-foreground group-hover:text-primary-600 transition-colors flex-shrink-0" />
          )}
        </div>
      </Link>
    </motion.div>
  );
}
