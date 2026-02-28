"use client";

import { motion } from "framer-motion";
import { Check, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { MarkdownRenderer } from "@/components/shared/MarkdownRenderer";
import type { MCQOption } from "@/types/practice";

interface MCQOptionsProps {
  options: MCQOption[];
  selectedId?: string;
  showFeedback: boolean;
  onSelect: (optionId: string) => void;
  disabled?: boolean;
}

export function MCQOptions({
  options,
  selectedId,
  showFeedback,
  onSelect,
  disabled = false,
}: MCQOptionsProps) {
  return (
    <div className="space-y-3">
      {options.map((option, index) => {
        const isSelected = selectedId === option.id;
        const isCorrect = showFeedback && option.isCorrect;
        const isWrong = showFeedback && isSelected && !option.isCorrect;

        return (
          <motion.button
            key={option.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.05 }}
            onClick={() => !disabled && onSelect(option.id)}
            disabled={disabled}
            className={cn(
              "w-full flex items-center gap-3 rounded-xl border-2 p-4 text-left transition-all duration-200",
              !showFeedback && !isSelected && "border-border hover:border-primary-300 hover:bg-primary-50/50 dark:hover:bg-primary-900/10",
              !showFeedback && isSelected && "border-primary-500 bg-primary-50 dark:bg-primary-900/20",
              isCorrect && "border-correct bg-correct-light dark:bg-correct-dark/20",
              isWrong && "border-incorrect bg-incorrect-light dark:bg-incorrect-dark/20",
              showFeedback && !isCorrect && !isWrong && "border-border opacity-50"
            )}
          >
            {/* Option label */}
            <span
              className={cn(
                "flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold flex-shrink-0",
                !showFeedback && !isSelected && "bg-muted text-muted-foreground",
                !showFeedback && isSelected && "bg-primary-500 text-white",
                isCorrect && "bg-correct text-white",
                isWrong && "bg-incorrect text-white",
                showFeedback && !isCorrect && !isWrong && "bg-muted text-muted-foreground"
              )}
            >
              {isCorrect ? (
                <Check className="h-4 w-4" />
              ) : isWrong ? (
                <X className="h-4 w-4" />
              ) : (
                String.fromCharCode(65 + index)
              )}
            </span>
            <span className="flex-1 text-sm"><MarkdownRenderer content={option.text} inline /></span>
          </motion.button>
        );
      })}
    </div>
  );
}
