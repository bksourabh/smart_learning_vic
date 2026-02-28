"use client";

import Link from "next/link";
import { ChevronLeft, ChevronRight, ClipboardCheck } from "lucide-react";
import type { Lesson } from "@/types/lesson";

interface LessonNavigationProps {
  currentLesson: Lesson;
  previousLesson?: Lesson;
  nextLesson?: Lesson;
  practiceAvailable: boolean;
}

export function LessonNavigation({
  currentLesson,
  previousLesson,
  nextLesson,
  practiceAvailable,
}: LessonNavigationProps) {
  const basePath = `/curriculum/${currentLesson.levelSlug}/${currentLesson.strandSlug}`;

  return (
    <div className="mt-12 pt-8 border-t border-border">
      <div className="flex flex-col sm:flex-row items-stretch gap-4">
        {previousLesson ? (
          <Link
            href={`${basePath}/${previousLesson.slug}`}
            className="flex-1 flex items-center gap-3 rounded-xl border border-border p-4 hover:bg-surface transition-colors group"
          >
            <ChevronLeft className="h-5 w-5 text-muted-foreground group-hover:text-primary-600" />
            <div>
              <span className="text-xs text-muted-foreground">Previous</span>
              <p className="font-medium group-hover:text-primary-600 transition-colors">
                {previousLesson.title}
              </p>
            </div>
          </Link>
        ) : (
          <div className="flex-1" />
        )}

        {nextLesson ? (
          <Link
            href={`${basePath}/${nextLesson.slug}`}
            className="flex-1 flex items-center justify-end gap-3 rounded-xl border border-border p-4 hover:bg-surface transition-colors group text-right"
          >
            <div>
              <span className="text-xs text-muted-foreground">Next</span>
              <p className="font-medium group-hover:text-primary-600 transition-colors">
                {nextLesson.title}
              </p>
            </div>
            <ChevronRight className="h-5 w-5 text-muted-foreground group-hover:text-primary-600" />
          </Link>
        ) : practiceAvailable ? (
          <Link
            href={`${basePath}/${currentLesson.slug}/practice`}
            className="flex-1 flex items-center justify-end gap-3 rounded-xl border-2 border-primary-300 dark:border-primary-700 bg-primary-50 dark:bg-primary-900/20 p-4 hover:bg-primary-100 dark:hover:bg-primary-900/30 transition-colors group text-right"
          >
            <div>
              <span className="text-xs text-primary-600">Up Next</span>
              <p className="font-medium text-primary-700 dark:text-primary-400">
                Take Practice Test
              </p>
            </div>
            <ClipboardCheck className="h-5 w-5 text-primary-600" />
          </Link>
        ) : (
          <div className="flex-1" />
        )}
      </div>
    </div>
  );
}
