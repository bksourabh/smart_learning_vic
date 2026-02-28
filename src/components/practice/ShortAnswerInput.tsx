"use client";

import { Check, X } from "lucide-react";
import { cn } from "@/lib/utils";

interface ShortAnswerInputProps {
  value: string;
  onChange: (value: string) => void;
  showFeedback: boolean;
  isCorrect?: boolean;
  correctAnswer?: string;
  disabled?: boolean;
}

export function ShortAnswerInput({
  value,
  onChange,
  showFeedback,
  isCorrect,
  correctAnswer,
  disabled = false,
}: ShortAnswerInputProps) {
  return (
    <div>
      <div className="relative">
        <input
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          placeholder="Type your answer..."
          className={cn(
            "w-full rounded-xl border-2 px-4 py-3 text-lg font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors bg-background",
            !showFeedback && "border-border focus:border-primary-500 focus:ring-primary-500",
            showFeedback && isCorrect && "border-correct bg-correct-light dark:bg-correct-dark/20 focus:ring-correct",
            showFeedback && !isCorrect && "border-incorrect bg-incorrect-light dark:bg-incorrect-dark/20 focus:ring-incorrect"
          )}
        />
        {showFeedback && (
          <span className="absolute right-3 top-1/2 -translate-y-1/2">
            {isCorrect ? (
              <Check className="h-6 w-6 text-correct" />
            ) : (
              <X className="h-6 w-6 text-incorrect" />
            )}
          </span>
        )}
      </div>
      {showFeedback && !isCorrect && correctAnswer && (
        <p className="mt-2 text-sm text-muted-foreground">
          Correct answer: <strong className="text-foreground">{correctAnswer}</strong>
        </p>
      )}
    </div>
  );
}
