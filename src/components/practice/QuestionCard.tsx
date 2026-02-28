"use client";

import { motion } from "framer-motion";
import { MarkdownRenderer } from "@/components/shared/MarkdownRenderer";
import type { Question } from "@/types/practice";

interface QuestionCardProps {
  question: Question;
  questionNumber: number;
  totalQuestions: number;
  children: React.ReactNode;
}

export function QuestionCard({
  question,
  questionNumber,
  totalQuestions,
  children,
}: QuestionCardProps) {
  return (
    <motion.div
      key={question.id}
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      transition={{ duration: 0.3 }}
      className="rounded-2xl border border-border bg-surface-raised p-6 sm:p-8"
    >
      <div className="flex items-center justify-between mb-6">
        <span className="text-sm font-medium text-muted-foreground">
          Question {questionNumber} of {totalQuestions}
        </span>
        <span className="text-xs px-2 py-1 rounded-full bg-muted font-medium capitalize">
          {question.difficulty}
        </span>
      </div>

      <div className="mb-6">
        <MarkdownRenderer content={question.question} className="text-lg" />
      </div>

      {children}

      {question.hint && (
        <p className="mt-4 text-sm text-muted-foreground italic">
          Hint: {question.hint}
        </p>
      )}
    </motion.div>
  );
}
