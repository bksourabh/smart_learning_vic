"use client";

import { BookOpen, ClipboardCheck, Award } from "lucide-react";
import type { StudentProgress } from "@/types/progress";

interface RecentActivityProps {
  progress: StudentProgress;
}

interface ActivityItem {
  type: "lesson" | "practice" | "achievement";
  title: string;
  detail: string;
  timestamp: number;
}

export function RecentActivity({ progress }: RecentActivityProps) {
  const activities: ActivityItem[] = [];

  // Lessons
  Object.values(progress.lessons).forEach((lesson) => {
    if (lesson.completed && lesson.completedAt) {
      activities.push({
        type: "lesson",
        title: `Completed lesson`,
        detail: `${lesson.levelSlug} / ${lesson.strandSlug} / ${lesson.lessonSlug}`,
        timestamp: lesson.completedAt,
      });
    }
  });

  // Practice results
  progress.practiceResults.forEach((result) => {
    activities.push({
      type: "practice",
      title: result.passed ? "Passed practice test" : "Attempted practice test",
      detail: `${result.levelSlug} / ${result.strandSlug} — ${Math.round(result.percentage)}%`,
      timestamp: result.completedAt,
    });
  });

  // Achievements
  Object.values(progress.achievements).forEach((achievement) => {
    if (achievement.unlockedAt) {
      activities.push({
        type: "achievement",
        title: "Achievement unlocked",
        detail: achievement.title,
        timestamp: achievement.unlockedAt,
      });
    }
  });

  // Sort by timestamp descending
  activities.sort((a, b) => b.timestamp - a.timestamp);

  const iconMap = {
    lesson: BookOpen,
    practice: ClipboardCheck,
    achievement: Award,
  };

  const colorMap = {
    lesson: "text-primary-600 bg-primary-100 dark:bg-primary-900/30",
    practice: "text-correct bg-correct-light dark:bg-correct-dark/20",
    achievement: "text-amber-600 bg-amber-100 dark:bg-amber-900/30",
  };

  return (
    <div className="rounded-2xl border border-border bg-surface-raised p-6">
      <h3 className="font-display font-semibold text-lg mb-4">Recent Activity</h3>

      {activities.length === 0 ? (
        <p className="text-sm text-muted-foreground py-8 text-center">
          No activity yet. Start learning to see your progress here!
        </p>
      ) : (
        <div className="space-y-3">
          {activities.slice(0, 10).map((activity, i) => {
            const Icon = iconMap[activity.type];
            const color = colorMap[activity.type];
            return (
              <div key={i} className="flex items-center gap-3">
                <div className={`flex items-center justify-center w-8 h-8 rounded-lg ${color} flex-shrink-0`}>
                  <Icon className="h-4 w-4" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{activity.title}</p>
                  <p className="text-xs text-muted-foreground truncate">{activity.detail}</p>
                </div>
                <span className="text-xs text-muted-foreground flex-shrink-0">
                  {new Date(activity.timestamp).toLocaleDateString()}
                </span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
