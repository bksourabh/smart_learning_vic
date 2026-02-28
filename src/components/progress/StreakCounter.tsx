"use client";

import { Flame } from "lucide-react";
import { cn } from "@/lib/utils";
import type { StreakData } from "@/types/progress";

interface StreakCounterProps {
  streak: StreakData;
}

const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export function StreakCounter({ streak }: StreakCounterProps) {
  // Get this week's dates
  const today = new Date();
  const monday = new Date(today);
  monday.setDate(today.getDate() - ((today.getDay() + 6) % 7));

  const weekDates = Array.from({ length: 7 }).map((_, i) => {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    return d.toISOString().split("T")[0];
  });

  return (
    <div className="rounded-2xl border border-border bg-surface-raised p-6">
      <div className="flex items-center gap-3 mb-4">
        <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-amber-100 dark:bg-amber-900/30">
          <Flame className="h-5 w-5 text-amber-600" />
        </div>
        <div>
          <h3 className="font-display font-semibold">Streak</h3>
          <p className="text-sm text-muted-foreground">
            {streak.currentStreak} {streak.currentStreak === 1 ? "day" : "days"}
          </p>
        </div>
      </div>

      {/* Weekly calendar */}
      <div className="grid grid-cols-7 gap-2">
        {weekDates.map((date, i) => {
          const isActive = streak.weeklyActivity[date];
          const isToday = date === today.toISOString().split("T")[0];

          return (
            <div key={date} className="text-center">
              <span className="text-[10px] text-muted-foreground">{dayLabels[i]}</span>
              <div
                className={cn(
                  "w-8 h-8 mx-auto mt-1 rounded-full flex items-center justify-center text-xs font-medium",
                  isActive && "bg-amber-500 text-white",
                  !isActive && isToday && "border-2 border-amber-400 text-amber-600",
                  !isActive && !isToday && "bg-muted text-muted-foreground"
                )}
              >
                {new Date(date).getDate()}
              </div>
            </div>
          );
        })}
      </div>

      <div className="mt-4 pt-4 border-t border-border text-center">
        <p className="text-xs text-muted-foreground">
          Longest streak: <strong>{streak.longestStreak} days</strong>
        </p>
      </div>
    </div>
  );
}
