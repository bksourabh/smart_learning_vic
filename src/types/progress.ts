export interface LessonProgress {
  lessonSlug: string;
  strandSlug: string;
  levelSlug: string;
  started: boolean;
  completed: boolean;
  startedAt?: number;
  completedAt?: number;
}

export interface PracticeResult {
  practiceId: string;
  strandSlug: string;
  levelSlug: string;
  score: number;
  totalQuestions: number;
  percentage: number;
  passed: boolean;
  completedAt: number;
  answers: {
    questionId: string;
    isCorrect: boolean;
  }[];
}

export interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  unlockedAt?: number;
  condition: AchievementCondition;
}

export interface AchievementCondition {
  type: "lessons_completed" | "perfect_score" | "streak" | "strand_completed" | "first_lesson";
  value: number;
  strandSlug?: string;
  levelSlug?: string;
}

export interface StreakData {
  currentStreak: number;
  longestStreak: number;
  lastActivityDate: string;
  weeklyActivity: Record<string, boolean>;
}

export interface StudentProgress {
  lessons: Record<string, LessonProgress>;
  practiceResults: PracticeResult[];
  streak: StreakData;
  achievements: Record<string, Achievement>;
  totalXp: number;
}
