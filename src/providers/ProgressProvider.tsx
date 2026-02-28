"use client";

import React, {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from "react";
import type {
  LessonProgress,
  PracticeResult,
  StudentProgress,
} from "@/types/progress";

// ── Context value shape ─────────────────────────────────────────────────────

interface ProgressContextValue {
  progress: StudentProgress;

  // Mutations
  markLessonStarted: (
    lessonSlug: string,
    strandSlug: string,
    levelSlug: string
  ) => void;
  markLessonCompleted: (
    lessonSlug: string,
    strandSlug: string,
    levelSlug: string
  ) => void;
  savePracticeResult: (result: PracticeResult) => void;
  updateStreak: () => void;
  unlockAchievement: (achievementId: string) => void;

  // Queries
  getProgress: () => StudentProgress;
  getLessonProgress: (lessonSlug: string) => LessonProgress | undefined;
  getPracticeResults: (
    strandSlug: string,
    levelSlug: string
  ) => PracticeResult[];
  getTotalCompletedLessons: () => number;
  getTotalPassedTests: () => number;
}

export const ProgressContext = createContext<ProgressContextValue | undefined>(
  undefined
);

// ── Defaults ────────────────────────────────────────────────────────────────

const STORAGE_KEY = "smart-learning-progress";

const defaultProgress: StudentProgress = {
  lessons: {},
  practiceResults: [],
  streak: {
    currentStreak: 0,
    longestStreak: 0,
    lastActivityDate: "",
    weeklyActivity: {},
  },
  achievements: {},
  totalXp: 0,
};

// ── Helpers ─────────────────────────────────────────────────────────────────

function loadProgress(): StudentProgress {
  if (typeof window === "undefined") return defaultProgress;
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      return JSON.parse(raw) as StudentProgress;
    }
  } catch {
    // corrupt data – start fresh
  }
  return defaultProgress;
}

function persistProgress(progress: StudentProgress) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
  } catch {
    // localStorage unavailable
  }
}

function todayDateString(): string {
  return new Date().toISOString().slice(0, 10); // "YYYY-MM-DD"
}

// ── Provider ────────────────────────────────────────────────────────────────

export function ProgressProvider({ children }: { children: React.ReactNode }) {
  // SSR-safe: start with defaults, hydrate in useEffect
  const [progress, setProgress] = useState<StudentProgress>(defaultProgress);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setProgress(loadProgress());
    setHydrated(true);
  }, []);

  // Persist on every change (after initial hydration)
  useEffect(() => {
    if (!hydrated) return;
    persistProgress(progress);
  }, [progress, hydrated]);

  // ── Mutations ───────────────────────────────────────────────────────────

  const markLessonStarted = useCallback(
    (lessonSlug: string, strandSlug: string, levelSlug: string) => {
      setProgress((prev) => {
        const existing = prev.lessons[lessonSlug];
        if (existing?.started) return prev; // already started
        return {
          ...prev,
          lessons: {
            ...prev.lessons,
            [lessonSlug]: {
              lessonSlug,
              strandSlug,
              levelSlug,
              started: true,
              completed: existing?.completed ?? false,
              startedAt: Date.now(),
              completedAt: existing?.completedAt,
            },
          },
        };
      });
    },
    []
  );

  const markLessonCompleted = useCallback(
    (lessonSlug: string, strandSlug: string, levelSlug: string) => {
      setProgress((prev) => {
        const existing = prev.lessons[lessonSlug];
        return {
          ...prev,
          lessons: {
            ...prev.lessons,
            [lessonSlug]: {
              lessonSlug,
              strandSlug,
              levelSlug,
              started: true,
              completed: true,
              startedAt: existing?.startedAt ?? Date.now(),
              completedAt: Date.now(),
            },
          },
          totalXp: prev.totalXp + 10,
        };
      });
    },
    []
  );

  const savePracticeResult = useCallback((result: PracticeResult) => {
    setProgress((prev) => ({
      ...prev,
      practiceResults: [...prev.practiceResults, result],
      totalXp: prev.totalXp + (result.passed ? 25 : 5),
    }));
  }, []);

  const updateStreak = useCallback(() => {
    setProgress((prev) => {
      const today = todayDateString();
      const { lastActivityDate, currentStreak, longestStreak, weeklyActivity } =
        prev.streak;

      if (lastActivityDate === today) {
        // Already recorded activity today
        return prev;
      }

      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().slice(0, 10);

      const newStreak =
        lastActivityDate === yesterdayStr ? currentStreak + 1 : 1;
      const newLongest = Math.max(longestStreak, newStreak);

      return {
        ...prev,
        streak: {
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastActivityDate: today,
          weeklyActivity: {
            ...weeklyActivity,
            [today]: true,
          },
        },
      };
    });
  }, []);

  const unlockAchievement = useCallback((achievementId: string) => {
    setProgress((prev) => {
      if (prev.achievements[achievementId]?.unlockedAt) return prev; // already unlocked
      return {
        ...prev,
        achievements: {
          ...prev.achievements,
          [achievementId]: {
            ...prev.achievements[achievementId],
            id: achievementId,
            title: prev.achievements[achievementId]?.title ?? achievementId,
            description: prev.achievements[achievementId]?.description ?? "",
            icon: prev.achievements[achievementId]?.icon ?? "",
            condition: prev.achievements[achievementId]?.condition ?? {
              type: "first_lesson",
              value: 1,
            },
            unlockedAt: Date.now(),
          },
        },
        totalXp: prev.totalXp + 50,
      };
    });
  }, []);

  // ── Queries ─────────────────────────────────────────────────────────────

  const getProgress = useCallback((): StudentProgress => {
    return progress;
  }, [progress]);

  const getLessonProgress = useCallback(
    (lessonSlug: string): LessonProgress | undefined => {
      return progress.lessons[lessonSlug];
    },
    [progress]
  );

  const getPracticeResults = useCallback(
    (strandSlug: string, levelSlug: string): PracticeResult[] => {
      return progress.practiceResults.filter(
        (r) => r.strandSlug === strandSlug && r.levelSlug === levelSlug
      );
    },
    [progress]
  );

  const getTotalCompletedLessons = useCallback((): number => {
    return Object.values(progress.lessons).filter((l) => l.completed).length;
  }, [progress]);

  const getTotalPassedTests = useCallback((): number => {
    return progress.practiceResults.filter((r) => r.passed).length;
  }, [progress]);

  // ── Memoised context value ──────────────────────────────────────────────

  const value = useMemo<ProgressContextValue>(
    () => ({
      progress,
      markLessonStarted,
      markLessonCompleted,
      savePracticeResult,
      updateStreak,
      unlockAchievement,
      getProgress,
      getLessonProgress,
      getPracticeResults,
      getTotalCompletedLessons,
      getTotalPassedTests,
    }),
    [
      progress,
      markLessonStarted,
      markLessonCompleted,
      savePracticeResult,
      updateStreak,
      unlockAchievement,
      getProgress,
      getLessonProgress,
      getPracticeResults,
      getTotalCompletedLessons,
      getTotalPassedTests,
    ]
  );

  return (
    <ProgressContext.Provider value={value}>
      {children}
    </ProgressContext.Provider>
  );
}
