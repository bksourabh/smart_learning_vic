"use client";

import { ThemeProvider } from "@/providers/ThemeProvider";
import { ProgressProvider } from "@/providers/ProgressProvider";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider>
      <ProgressProvider>{children}</ProgressProvider>
    </ThemeProvider>
  );
}
