import { notFound } from "next/navigation";
import {
  getLevelBySlug,
  getStrandBySlug,
  getLessonsForStrand,
  getLessonBySlug,
  getPracticeForStrand,
  generateLessonStaticParams,
} from "@/lib/curriculum";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { LessonContent } from "@/components/lesson/LessonContent";
import { LessonNavigation } from "@/components/lesson/LessonNavigation";
import { MarkComplete } from "@/components/lesson/MarkComplete";
import { Clock, BookOpen } from "lucide-react";
import { DIFFICULTY_COLORS, DIFFICULTY_LABELS } from "@/lib/constants";
import { cn } from "@/lib/utils";

export async function generateStaticParams() {
  return generateLessonStaticParams();
}

export async function generateMetadata({
  params,
}: {
  params: { levelSlug: string; strandSlug: string; lessonSlug: string };
}) {
  const lesson = await getLessonBySlug(params.levelSlug, params.strandSlug, params.lessonSlug);
  if (!lesson) return {};
  return {
    title: lesson.title,
    description: lesson.description,
  };
}

export default async function LessonPage({
  params,
}: {
  params: { levelSlug: string; strandSlug: string; lessonSlug: string };
}) {
  const level = getLevelBySlug(params.levelSlug);
  const strand = getStrandBySlug(params.strandSlug);
  const lesson = await getLessonBySlug(params.levelSlug, params.strandSlug, params.lessonSlug);

  if (!level || !strand || !lesson) notFound();

  const allLessons = await getLessonsForStrand(params.levelSlug, params.strandSlug);
  const lessonIndex = allLessons.findIndex((l) => l.slug === lesson.slug);
  const previousLesson = lessonIndex > 0 ? allLessons[lessonIndex - 1] : undefined;
  const nextLesson = lessonIndex < allLessons.length - 1 ? allLessons[lessonIndex + 1] : undefined;
  const practice = await getPracticeForStrand(params.levelSlug, params.strandSlug);

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs
        items={[
          { label: "Curriculum", href: "/curriculum" },
          { label: level.name, href: `/curriculum/${level.slug}` },
          { label: strand.name, href: `/curriculum/${level.slug}/${strand.slug}` },
          { label: lesson.title },
        ]}
        className="mb-6"
      />

      {/* Lesson Header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-3">
          <span className={cn("text-xs px-2.5 py-1 rounded-full font-medium", DIFFICULTY_COLORS[lesson.difficulty])}>
            {DIFFICULTY_LABELS[lesson.difficulty]}
          </span>
          <span className="flex items-center gap-1 text-sm text-muted-foreground">
            <Clock className="h-3.5 w-3.5" />
            {lesson.estimatedMinutes} min
          </span>
          <span className="flex items-center gap-1 text-sm text-muted-foreground">
            <BookOpen className="h-3.5 w-3.5" />
            Lesson {lesson.order} of {allLessons.length}
          </span>
        </div>
        <h1 className="font-display text-3xl font-bold mb-2">{lesson.title}</h1>
        <p className="text-lg text-muted-foreground">{lesson.description}</p>
      </div>

      {/* Lesson Content */}
      <LessonContent lesson={lesson} />

      {/* Mark as Complete */}
      <div className="mt-8 flex justify-center">
        <MarkComplete
          lessonSlug={lesson.slug}
          strandSlug={strand.slug}
          levelSlug={level.slug}
        />
      </div>

      {/* Navigation */}
      <LessonNavigation
        currentLesson={lesson}
        previousLesson={previousLesson}
        nextLesson={nextLesson}
        practiceAvailable={practice !== null}
      />
    </div>
  );
}
