"use client";

import { useState } from "react";
import { AnimatePresence } from "framer-motion";
import { Play, ArrowRight, ArrowLeft, CheckCircle2 } from "lucide-react";
import { QuestionCard } from "./QuestionCard";
import { MCQOptions } from "./MCQOptions";
import { ShortAnswerInput } from "./ShortAnswerInput";
import { FeedbackPanel } from "./FeedbackPanel";
import { QuestionProgress } from "./QuestionProgress";
import { ScoreDisplay } from "./ScoreDisplay";
import { CelebrationAnimation } from "./CelebrationAnimation";
import { useProgress } from "@/hooks/useProgress";
import type { PracticeTest, PracticeAnswer, PracticeState, Question } from "@/types/practice";

interface PracticeTestRunnerProps {
  test: PracticeTest;
}

function checkAnswer(question: Question, selectedOptionId?: string, textAnswer?: string): boolean {
  if (question.type === "mcq" && question.options) {
    const correct = question.options.find((o) => o.isCorrect);
    return correct?.id === selectedOptionId;
  }
  if (question.type === "short-answer" && question.correctAnswer) {
    const normalizedAnswer = (textAnswer || "").trim().toLowerCase();
    const normalizedCorrect = question.correctAnswer.trim().toLowerCase();
    if (normalizedAnswer === normalizedCorrect) return true;
    if (question.acceptableAnswers) {
      return question.acceptableAnswers.some(
        (a) => a.trim().toLowerCase() === normalizedAnswer
      );
    }
    // Numeric comparison
    const numAnswer = parseFloat(normalizedAnswer);
    const numCorrect = parseFloat(normalizedCorrect);
    if (!isNaN(numAnswer) && !isNaN(numCorrect)) {
      return Math.abs(numAnswer - numCorrect) < 0.001;
    }
  }
  return false;
}

export function PracticeTestRunner({ test }: PracticeTestRunnerProps) {
  const [state, setState] = useState<PracticeState>("not-started");
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<PracticeAnswer[]>([]);
  const [selectedOptionId, setSelectedOptionId] = useState<string | undefined>();
  const [textAnswer, setTextAnswer] = useState("");
  const [showFeedback, setShowFeedback] = useState(false);
  const [showCelebration, setShowCelebration] = useState(false);

  const { savePracticeResult, updateStreak } = useProgress();

  const currentQuestion = test.questions[currentIndex];
  const currentAnswer = answers[currentIndex];

  const score = answers.filter((a) => a.isCorrect).length;
  const percentage = test.questions.length > 0 ? (score / test.questions.length) * 100 : 0;
  const passed = percentage >= test.passingScore;

  const startTest = () => {
    setState("in-progress");
    setCurrentIndex(0);
    setAnswers([]);
    setSelectedOptionId(undefined);
    setTextAnswer("");
    setShowFeedback(false);
  };

  const submitAnswer = () => {
    if (!currentQuestion) return;

    const isCorrect = checkAnswer(currentQuestion, selectedOptionId, textAnswer);
    const answer: PracticeAnswer = {
      questionId: currentQuestion.id,
      selectedOptionId,
      textAnswer: currentQuestion.type === "short-answer" ? textAnswer : undefined,
      isCorrect,
      answeredAt: Date.now(),
    };

    const newAnswers = [...answers];
    newAnswers[currentIndex] = answer;
    setAnswers(newAnswers);
    setShowFeedback(true);
  };

  const nextQuestion = () => {
    setShowFeedback(false);
    setSelectedOptionId(undefined);
    setTextAnswer("");

    if (currentIndex < test.questions.length - 1) {
      setCurrentIndex(currentIndex + 1);
      // Restore answer if already answered
      const existing = answers[currentIndex + 1];
      if (existing) {
        setSelectedOptionId(existing.selectedOptionId);
        setTextAnswer(existing.textAnswer || "");
      }
    }
  };

  const previousQuestion = () => {
    if (currentIndex > 0) {
      setShowFeedback(false);
      setCurrentIndex(currentIndex - 1);
      const existing = answers[currentIndex - 1];
      if (existing) {
        setSelectedOptionId(existing.selectedOptionId);
        setTextAnswer(existing.textAnswer || "");
        setShowFeedback(true);
      } else {
        setSelectedOptionId(undefined);
        setTextAnswer("");
      }
    }
  };

  const finishTest = () => {
    setState("completed");
    // Save results
    savePracticeResult({
      practiceId: test.id,
      strandSlug: test.strandSlug,
      levelSlug: test.levelSlug,
      score,
      totalQuestions: test.questions.length,
      percentage,
      passed,
      completedAt: Date.now(),
      answers: answers.map((a) => ({
        questionId: a.questionId,
        isCorrect: a.isCorrect,
      })),
    });
    updateStreak();

    if (passed) {
      setShowCelebration(true);
      setTimeout(() => setShowCelebration(false), 3000);
    }
  };

  const reviewAnswers = () => {
    setState("reviewing");
    setCurrentIndex(0);
    const existing = answers[0];
    if (existing) {
      setSelectedOptionId(existing.selectedOptionId);
      setTextAnswer(existing.textAnswer || "");
      setShowFeedback(true);
    }
  };

  // Not started screen
  if (state === "not-started") {
    return (
      <div className="max-w-2xl mx-auto text-center py-12">
        <div className="rounded-2xl border border-border bg-surface-raised p-8">
          <h2 className="font-display text-2xl font-bold mb-3">{test.title}</h2>
          <p className="text-muted-foreground mb-6">{test.description}</p>
          <div className="flex items-center justify-center gap-6 text-sm text-muted-foreground mb-8">
            <span>{test.questions.length} questions</span>
            <span>Pass: {test.passingScore}%</span>
          </div>
          <button
            onClick={startTest}
            className="inline-flex items-center gap-2 rounded-xl bg-primary-600 px-8 py-4 text-white font-semibold hover:bg-primary-700 transition-colors"
          >
            <Play className="h-5 w-5" />
            Start Test
          </button>
        </div>
      </div>
    );
  }

  // Completed screen
  if (state === "completed") {
    return (
      <div className="max-w-2xl mx-auto">
        <CelebrationAnimation show={showCelebration} />
        <ScoreDisplay
          score={score}
          total={test.questions.length}
          percentage={percentage}
          passed={passed}
          passingScore={test.passingScore}
          onRetry={startTest}
          onViewAnswers={reviewAnswers}
        />
      </div>
    );
  }

  // In progress or reviewing
  const isReviewing = state === "reviewing";
  const isLastQuestion = currentIndex === test.questions.length - 1;
  const hasAnswer = selectedOptionId !== undefined || textAnswer.trim() !== "";

  return (
    <div className="max-w-2xl mx-auto">
      {/* Progress */}
      <div className="mb-6">
        <QuestionProgress
          totalQuestions={test.questions.length}
          currentIndex={currentIndex}
          answers={answers}
        />
      </div>

      {/* Question */}
      <AnimatePresence mode="wait">
        <QuestionCard
          key={currentQuestion.id}
          question={currentQuestion}
          questionNumber={currentIndex + 1}
          totalQuestions={test.questions.length}
        >
          {/* Answer area */}
          {currentQuestion.type === "mcq" && currentQuestion.options ? (
            <MCQOptions
              options={currentQuestion.options}
              selectedId={selectedOptionId}
              showFeedback={showFeedback}
              onSelect={(id) => {
                if (!showFeedback) setSelectedOptionId(id);
              }}
              disabled={showFeedback || isReviewing}
            />
          ) : (
            <ShortAnswerInput
              value={textAnswer}
              onChange={(v) => {
                if (!showFeedback) setTextAnswer(v);
              }}
              showFeedback={showFeedback}
              isCorrect={currentAnswer?.isCorrect}
              correctAnswer={currentQuestion.correctAnswer}
              disabled={showFeedback || isReviewing}
            />
          )}

          {/* Feedback */}
          <FeedbackPanel
            isCorrect={currentAnswer?.isCorrect ?? false}
            explanation={currentQuestion.explanation}
            show={showFeedback}
          />
        </QuestionCard>
      </AnimatePresence>

      {/* Navigation */}
      <div className="flex items-center justify-between mt-6">
        <button
          onClick={previousQuestion}
          disabled={currentIndex === 0}
          className="inline-flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium border border-border hover:bg-muted transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <ArrowLeft className="h-4 w-4" />
          Previous
        </button>

        <div className="flex gap-3">
          {!showFeedback && !isReviewing && (
            <button
              onClick={submitAnswer}
              disabled={!hasAnswer}
              className="inline-flex items-center gap-2 rounded-lg bg-primary-600 px-6 py-2 text-sm font-medium text-white hover:bg-primary-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Check Answer
            </button>
          )}

          {showFeedback && !isLastQuestion && (
            <button
              onClick={nextQuestion}
              className="inline-flex items-center gap-2 rounded-lg bg-primary-600 px-6 py-2 text-sm font-medium text-white hover:bg-primary-700 transition-colors"
            >
              Next
              <ArrowRight className="h-4 w-4" />
            </button>
          )}

          {showFeedback && isLastQuestion && !isReviewing && (
            <button
              onClick={finishTest}
              className="inline-flex items-center gap-2 rounded-lg bg-correct px-6 py-2 text-sm font-medium text-white hover:bg-correct-dark transition-colors"
            >
              <CheckCircle2 className="h-4 w-4" />
              Finish Test
            </button>
          )}

          {isReviewing && !isLastQuestion && (
            <button
              onClick={nextQuestion}
              className="inline-flex items-center gap-2 rounded-lg bg-primary-600 px-6 py-2 text-sm font-medium text-white hover:bg-primary-700 transition-colors"
            >
              Next
              <ArrowRight className="h-4 w-4" />
            </button>
          )}

          {isReviewing && isLastQuestion && (
            <button
              onClick={startTest}
              className="inline-flex items-center gap-2 rounded-lg bg-primary-600 px-6 py-2 text-sm font-medium text-white hover:bg-primary-700 transition-colors"
            >
              Try Again
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
