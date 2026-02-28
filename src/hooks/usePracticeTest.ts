"use client";

import { useCallback, useMemo, useState } from "react";
import type {
  PracticeAnswer,
  PracticeState,
  PracticeTest,
  Question,
} from "@/types/practice";

interface UsePracticeTestReturn {
  /** Current phase of the test */
  state: PracticeState;
  /** Index of the question being displayed */
  currentQuestionIndex: number;
  /** The current question object (or undefined before start / after finish) */
  currentQuestion: Question | undefined;
  /** All answers recorded so far */
  answers: PracticeAnswer[];
  /** Number of correct answers */
  score: number;
  /** Total questions in the test */
  totalQuestions: number;
  /** Score as a percentage (0-100) */
  percentage: number;
  /** Whether the student passed (score >= passingScore) */
  passed: boolean;

  // Actions
  startTest: () => void;
  answerQuestion: (answer: Omit<PracticeAnswer, "answeredAt">) => void;
  nextQuestion: () => void;
  previousQuestion: () => void;
  finishTest: () => void;
  resetTest: () => void;
}

export function usePracticeTest(test: PracticeTest): UsePracticeTestReturn {
  const [state, setState] = useState<PracticeState>("not-started");
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState<PracticeAnswer[]>([]);

  const totalQuestions = test.questions.length;

  const currentQuestion: Question | undefined =
    test.questions[currentQuestionIndex];

  // ── Derived values ────────────────────────────────────────────────────

  const score = useMemo(
    () => answers.filter((a) => a.isCorrect).length,
    [answers]
  );

  const percentage = useMemo(
    () => (totalQuestions > 0 ? Math.round((score / totalQuestions) * 100) : 0),
    [score, totalQuestions]
  );

  const passed = useMemo(
    () => percentage >= test.passingScore,
    [percentage, test.passingScore]
  );

  // ── Actions ───────────────────────────────────────────────────────────

  const startTest = useCallback(() => {
    setState("in-progress");
    setCurrentQuestionIndex(0);
    setAnswers([]);
  }, []);

  const answerQuestion = useCallback(
    (answer: Omit<PracticeAnswer, "answeredAt">) => {
      setAnswers((prev) => {
        // Replace answer if the student revisits a question, otherwise append
        const existing = prev.findIndex(
          (a) => a.questionId === answer.questionId
        );
        const fullAnswer: PracticeAnswer = {
          ...answer,
          answeredAt: Date.now(),
        };
        if (existing !== -1) {
          const updated = [...prev];
          updated[existing] = fullAnswer;
          return updated;
        }
        return [...prev, fullAnswer];
      });
    },
    []
  );

  const nextQuestion = useCallback(() => {
    setCurrentQuestionIndex((prev) =>
      prev < totalQuestions - 1 ? prev + 1 : prev
    );
  }, [totalQuestions]);

  const previousQuestion = useCallback(() => {
    setCurrentQuestionIndex((prev) => (prev > 0 ? prev - 1 : prev));
  }, []);

  const finishTest = useCallback(() => {
    setState("reviewing");
  }, []);

  const resetTest = useCallback(() => {
    setState("not-started");
    setCurrentQuestionIndex(0);
    setAnswers([]);
  }, []);

  return {
    state,
    currentQuestionIndex,
    currentQuestion,
    answers,
    score,
    totalQuestions,
    percentage,
    passed,
    startTest,
    answerQuestion,
    nextQuestion,
    previousQuestion,
    finishTest,
    resetTest,
  };
}
