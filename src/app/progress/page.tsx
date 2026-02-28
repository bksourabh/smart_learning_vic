"use client";

import { useProgress } from "@/hooks/useProgress";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ProgressOverview } from "@/components/progress/ProgressOverview";
import { StreakCounter } from "@/components/progress/StreakCounter";
import { RecentActivity } from "@/components/progress/RecentActivity";
import { AchievementGrid } from "@/components/progress/AchievementGrid";

export default function ProgressPage() {
  const { getProgress, getTotalCompletedLessons, getTotalPassedTests } = useProgress();
  const progress = getProgress();

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs items={[{ label: "My Progress" }]} className="mb-6" />

      <div className="mb-8">
        <h1 className="font-display text-3xl font-bold text-foreground mb-2">
          My Progress
        </h1>
        <p className="text-lg text-muted-foreground">
          Track your learning journey and achievements
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main column */}
        <div className="lg:col-span-2 space-y-6">
          <ProgressOverview
            totalLessons={getTotalCompletedLessons()}
            totalTests={getTotalPassedTests()}
            streak={progress.streak.currentStreak}
            totalXp={progress.totalXp}
          />
          <RecentActivity progress={progress} />
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          <StreakCounter streak={progress.streak} />
          <AchievementGrid achievements={progress.achievements} />
        </div>
      </div>
    </div>
  );
}
