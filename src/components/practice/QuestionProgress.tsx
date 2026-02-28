"use client";

import { cn } from "@/lib/utils";
import type { PracticeAnswer } from "@/types/practice";

interface QuestionProgressProps {
  totalQuestions: number;
  currentIndex: number;
  answers: PracticeAnswer[];
  onSelectQuestion?: (index: number) => void;
}

export function QuestionProgress({
  totalQuestions,
  currentIndex,
  answers,
  onSelectQuestion,
}: QuestionProgressProps) {
  return (
    <div className="flex items-center gap-2 flex-wrap">
      {Array.from({ length: totalQuestions }).map((_, i) => {
        const isCurrent = i === currentIndex;
        const isAnswered = i < answers.length;

        return (
          <button
            key={i}
            onClick={() => onSelectQuestion?.(i)}
            className={cn(
              "w-8 h-8 rounded-full text-xs font-bold transition-all duration-200 flex items-center justify-center",
              isCurrent && "ring-2 ring-primary-500 ring-offset-2 ring-offset-background",
              !isAnswered && !isCurrent && "bg-muted text-muted-foreground",
              isAnswered && "bg-primary-500 text-white",
            )}
          >
            {i + 1}
          </button>
        );
      })}
    </div>
  );
}
