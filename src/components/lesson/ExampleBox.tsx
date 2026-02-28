"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronRight, Lightbulb } from "lucide-react";
import { MarkdownRenderer } from "@/components/shared/MarkdownRenderer";
import { cn } from "@/lib/utils";

interface ExampleBoxProps {
  title: string;
  problem: string;
  steps: string[];
  answer: string;
  explanation: string;
  strandColor?: string;
}

export function ExampleBox({
  title,
  problem,
  steps,
  answer,
  explanation,
  strandColor = "#3b82f6",
}: ExampleBoxProps) {
  const [revealedSteps, setRevealedSteps] = useState(0);
  const allRevealed = revealedSteps >= steps.length;

  return (
    <div
      className="rounded-xl border-l-4 bg-surface-raised p-6 my-6"
      style={{ borderLeftColor: strandColor }}
    >
      <h4 className="font-display font-semibold text-lg mb-3 flex items-center gap-2">
        <Lightbulb className="h-5 w-5" style={{ color: strandColor }} />
        {title}
      </h4>

      <div className="mb-4">
        <MarkdownRenderer content={problem} />
      </div>

      <div className="space-y-2">
        <AnimatePresence>
          {steps.slice(0, revealedSteps).map((step, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              transition={{ duration: 0.3 }}
              className="flex gap-3 items-start"
            >
              <span
                className="flex items-center justify-center w-6 h-6 rounded-full text-xs font-bold text-white flex-shrink-0 mt-0.5"
                style={{ backgroundColor: strandColor }}
              >
                {i + 1}
              </span>
              <div className="flex-1">
                <MarkdownRenderer content={step} />
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      {!allRevealed ? (
        <button
          onClick={() => setRevealedSteps((prev) => prev + 1)}
          className={cn(
            "mt-4 inline-flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium text-white transition-transform hover:scale-105"
          )}
          style={{ backgroundColor: strandColor }}
        >
          Next Step
          <ChevronRight className="h-4 w-4" />
        </button>
      ) : (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="mt-4 rounded-lg bg-correct-light dark:bg-correct-dark/20 p-4"
        >
          <p className="font-semibold text-correct-dark dark:text-correct mb-2">Answer: {answer}</p>
          <MarkdownRenderer content={explanation} />
        </motion.div>
      )}
    </div>
  );
}
