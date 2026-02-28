"use client";

import { motion, AnimatePresence } from "framer-motion";
import { CheckCircle2, XCircle } from "lucide-react";
import { MarkdownRenderer } from "@/components/shared/MarkdownRenderer";

interface FeedbackPanelProps {
  isCorrect: boolean;
  explanation: string;
  show: boolean;
}

export function FeedbackPanel({ isCorrect, explanation, show }: FeedbackPanelProps) {
  return (
    <AnimatePresence>
      {show && (
        <motion.div
          initial={{ opacity: 0, height: 0, marginTop: 0 }}
          animate={{ opacity: 1, height: "auto", marginTop: 16 }}
          exit={{ opacity: 0, height: 0, marginTop: 0 }}
          transition={{ duration: 0.3 }}
          className="overflow-hidden"
        >
          <div
            className={`rounded-xl p-5 ${
              isCorrect
                ? "bg-correct-light dark:bg-correct-dark/20 border border-correct/30"
                : "bg-incorrect-light dark:bg-incorrect-dark/20 border border-incorrect/30"
            }`}
          >
            <div className="flex items-center gap-2 mb-3">
              {isCorrect ? (
                <>
                  <CheckCircle2 className="h-5 w-5 text-correct" />
                  <span className="font-semibold text-correct-dark dark:text-correct">
                    Correct!
                  </span>
                </>
              ) : (
                <>
                  <XCircle className="h-5 w-5 text-incorrect" />
                  <span className="font-semibold text-incorrect-dark dark:text-incorrect">
                    Not quite right
                  </span>
                </>
              )}
            </div>
            <MarkdownRenderer content={explanation} />
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
