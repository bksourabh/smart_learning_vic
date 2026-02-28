"use client";

import { useContext } from "react";
import { ProgressContext } from "@/providers/ProgressProvider";

export function useProgress() {
  const context = useContext(ProgressContext);
  if (context === undefined) {
    throw new Error("useProgress must be used within a ProgressProvider");
  }
  return context;
}
