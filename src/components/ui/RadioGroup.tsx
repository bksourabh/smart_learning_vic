"use client";

import React from "react";
import { cva } from "class-variance-authority";
import { motion } from "framer-motion";
import { Check, X } from "lucide-react";
import { cn } from "@/lib/utils";

const radioOptionVariants = cva(
  "relative flex w-full cursor-pointer items-center gap-3 rounded-xl border-2 px-4 py-3 text-sm font-medium transition-colors",
  {
    variants: {
      state: {
        default: "border-gray-200 bg-white text-gray-700 hover:border-primary-300 hover:bg-primary-50/50",
        selected: "border-primary-500 bg-primary-50 text-primary-700",
        correct: "border-correct bg-correct-light text-correct-dark",
        incorrect: "border-incorrect bg-incorrect-light text-incorrect-dark",
      },
    },
    defaultVariants: {
      state: "default",
    },
  }
);

export type RadioOptionState = "default" | "selected" | "correct" | "incorrect";

export interface RadioOption {
  value: string;
  label: string;
}

export interface RadioGroupProps {
  name: string;
  options: RadioOption[];
  value?: string;
  onChange?: (value: string) => void;
  optionStates?: Record<string, RadioOptionState>;
  disabled?: boolean;
  className?: string;
}

function RadioGroup({
  name,
  options,
  value,
  onChange,
  optionStates = {},
  disabled = false,
  className,
}: RadioGroupProps) {
  return (
    <div
      role="radiogroup"
      aria-label={name}
      className={cn("flex flex-col gap-3", className)}
    >
      {options.map((option, index) => {
        const state: RadioOptionState =
          optionStates[option.value] ||
          (value === option.value ? "selected" : "default");

        const isSelected = value === option.value;
        const showCheck = state === "correct";
        const showX = state === "incorrect" && isSelected;

        return (
          <motion.label
            key={option.value}
            className={cn(
              radioOptionVariants({ state }),
              disabled && "pointer-events-none opacity-60"
            )}
            whileHover={
              !disabled && state === "default" ? { scale: 1.01 } : undefined
            }
            whileTap={
              !disabled && state === "default" ? { scale: 0.99 } : undefined
            }
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.05 }}
          >
            <input
              type="radio"
              name={name}
              value={option.value}
              checked={isSelected}
              onChange={() => onChange?.(option.value)}
              disabled={disabled}
              className="sr-only"
            />

            {/* Radio indicator */}
            <span
              className={cn(
                "flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2 transition-colors",
                state === "default" && "border-gray-300 bg-white",
                state === "selected" && "border-primary-500 bg-primary-500",
                state === "correct" && "border-correct bg-correct",
                state === "incorrect" && isSelected && "border-incorrect bg-incorrect"
              )}
            >
              {isSelected && state !== "correct" && state !== "incorrect" && (
                <motion.span
                  className="h-2 w-2 rounded-full bg-white"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: "spring", stiffness: 500, damping: 30 }}
                />
              )}
              {showCheck && (
                <Check className="h-3 w-3 text-white" strokeWidth={3} />
              )}
              {showX && (
                <X className="h-3 w-3 text-white" strokeWidth={3} />
              )}
            </span>

            {/* Label */}
            <span className="flex-1">{option.label}</span>

            {/* Feedback icon */}
            {state === "correct" && (
              <motion.span
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", stiffness: 500, damping: 25 }}
              >
                <Check className="h-5 w-5 text-correct" strokeWidth={2.5} />
              </motion.span>
            )}
            {showX && (
              <motion.span
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", stiffness: 500, damping: 25 }}
              >
                <X className="h-5 w-5 text-incorrect" strokeWidth={2.5} />
              </motion.span>
            )}
          </motion.label>
        );
      })}
    </div>
  );
}

RadioGroup.displayName = "RadioGroup";

export { RadioGroup, radioOptionVariants };
