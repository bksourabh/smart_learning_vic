"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { CheckCircle2, Circle } from "lucide-react";
import { useProgress } from "@/hooks/useProgress";

interface MarkCompleteProps {
  lessonSlug: string;
  strandSlug: string;
  levelSlug: string;
}

export function MarkComplete({ lessonSlug, strandSlug, levelSlug }: MarkCompleteProps) {
  const { getLessonProgress, markLessonCompleted, markLessonStarted } = useProgress();
  const progress = getLessonProgress(lessonSlug);
  const [justCompleted, setJustCompleted] = useState(false);

  const isCompleted = progress?.completed || justCompleted;

  const handleMarkComplete = () => {
    if (!progress?.started) {
      markLessonStarted(lessonSlug, strandSlug, levelSlug);
    }
    markLessonCompleted(lessonSlug, strandSlug, levelSlug);
    setJustCompleted(true);
  };

  if (isCompleted) {
    return (
      <motion.div
        initial={{ scale: 0.8 }}
        animate={{ scale: 1 }}
        className="inline-flex items-center gap-2 rounded-xl bg-correct-light dark:bg-correct-dark/20 px-5 py-3 text-correct-dark dark:text-correct font-medium"
      >
        <CheckCircle2 className="h-5 w-5" />
        Lesson Complete
      </motion.div>
    );
  }

  return (
    <button
      onClick={handleMarkComplete}
      className="inline-flex items-center gap-2 rounded-xl bg-primary-600 px-5 py-3 text-white font-medium hover:bg-primary-700 transition-colors"
    >
      <Circle className="h-5 w-5" />
      Mark as Complete
    </button>
  );
}
