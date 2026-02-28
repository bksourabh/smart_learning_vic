"use client";

import { motion } from "framer-motion";
import { Trophy, Target, RotateCcw } from "lucide-react";


interface ScoreDisplayProps {
  score: number;
  total: number;
  percentage: number;
  passed: boolean;
  passingScore: number;
  onRetry: () => void;
  onViewAnswers: () => void;
}

export function ScoreDisplay({
  score,
  total,
  percentage,
  passed,
  passingScore,
  onRetry,
  onViewAnswers,
}: ScoreDisplayProps) {
  const circumference = 2 * Math.PI * 60;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  return (
    <div className="text-center py-8">
      {/* Animated Score Circle */}
      <div className="relative inline-flex items-center justify-center mb-8">
        <svg width="160" height="160" className="-rotate-90">
          <circle
            cx="80"
            cy="80"
            r="60"
            fill="none"
            stroke="currentColor"
            strokeWidth="8"
            className="text-muted"
          />
          <motion.circle
            cx="80"
            cy="80"
            r="60"
            fill="none"
            stroke={passed ? "#22c55e" : "#ef4444"}
            strokeWidth="8"
            strokeLinecap="round"
            strokeDasharray={circumference}
            initial={{ strokeDashoffset: circumference }}
            animate={{ strokeDashoffset }}
            transition={{ duration: 1.5, ease: "easeOut" }}
          />
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <motion.span
            className="text-3xl font-display font-bold"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.5, type: "spring" }}
          >
            {Math.round(percentage)}%
          </motion.span>
          <span className="text-xs text-muted-foreground">
            {score}/{total}
          </span>
        </div>
      </div>

      {/* Result Message */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
      >
        {passed ? (
          <div className="mb-6">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-correct-light dark:bg-correct-dark/20 mb-3">
              <Trophy className="h-6 w-6 text-correct" />
            </div>
            <h2 className="font-display text-2xl font-bold text-correct-dark dark:text-correct mb-2">
              Great Job!
            </h2>
            <p className="text-muted-foreground">
              You passed! You got {score} out of {total} correct.
            </p>
          </div>
        ) : (
          <div className="mb-6">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-amber-100 dark:bg-amber-900/20 mb-3">
              <Target className="h-6 w-6 text-amber-600" />
            </div>
            <h2 className="font-display text-2xl font-bold mb-2">Keep Practising!</h2>
            <p className="text-muted-foreground">
              You got {score} out of {total}. You need {passingScore}% to pass. Try again!
            </p>
          </div>
        )}

        <div className="flex items-center justify-center gap-4">
          <button
            onClick={onViewAnswers}
            className="inline-flex items-center gap-2 rounded-xl border border-border px-6 py-3 font-medium hover:bg-muted transition-colors"
          >
            View Answers
          </button>
          <button
            onClick={onRetry}
            className="inline-flex items-center gap-2 rounded-xl bg-primary-600 px-6 py-3 text-white font-medium hover:bg-primary-700 transition-colors"
          >
            <RotateCcw className="h-4 w-4" />
            Try Again
          </button>
        </div>
      </motion.div>
    </div>
  );
}
