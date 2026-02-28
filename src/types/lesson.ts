export type SectionType =
  | "introduction"
  | "explanation"
  | "example"
  | "key-concept"
  | "practice-prompt"
  | "summary";

export interface LessonSection {
  type: SectionType;
  title?: string;
  content: string;
  steps?: string[];
  hint?: string;
}

export interface WorkedExample {
  title: string;
  problem: string;
  steps: string[];
  answer: string;
  explanation: string;
}

export interface Lesson {
  slug: string;
  title: string;
  description: string;
  strandSlug: string;
  levelSlug: string;
  order: number;
  difficulty: "easy" | "medium" | "hard";
  estimatedMinutes: number;
  sections: LessonSection[];
  workedExamples: WorkedExample[];
  prerequisites: string[];
  objectives: string[];
}
