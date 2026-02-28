export type QuestionType = "mcq" | "short-answer";

export interface MCQOption {
  id: string;
  text: string;
  isCorrect: boolean;
}

export interface Question {
  id: string;
  type: QuestionType;
  question: string;
  hint?: string;
  difficulty: "easy" | "medium" | "hard";
  /** For MCQ questions */
  options?: MCQOption[];
  /** For short answer questions */
  correctAnswer?: string;
  /** Acceptable alternative answers for short answer */
  acceptableAnswers?: string[];
  /** Shown after answering */
  explanation: string;
  /** Topic tag */
  topic: string;
}

export interface PracticeTest {
  id: string;
  title: string;
  description: string;
  strandSlug: string;
  levelSlug: string;
  questions: Question[];
  passingScore: number;
  timeLimit?: number;
}

export type PracticeState = "not-started" | "in-progress" | "reviewing" | "completed";

export interface PracticeAnswer {
  questionId: string;
  selectedOptionId?: string;
  textAnswer?: string;
  isCorrect: boolean;
  answeredAt: number;
}
