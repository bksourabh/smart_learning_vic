import curriculumData from "@/data/curriculum.json";
import type { CurriculumData, LevelMeta, StrandDefinition } from "@/types/curriculum";
import type { Lesson } from "@/types/lesson";
import type { PracticeTest } from "@/types/practice";

const curriculum = curriculumData as CurriculumData;

export function getAllLevels(): LevelMeta[] {
  return curriculum.levels;
}

export function getAllStrands(): StrandDefinition[] {
  return curriculum.strands;
}

export function getLevelBySlug(slug: string): LevelMeta | undefined {
  return curriculum.levels.find((l) => l.slug === slug);
}

export function getStrandBySlug(slug: string): StrandDefinition | undefined {
  return curriculum.strands.find((s) => s.slug === slug);
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function normalizeLesson(raw: any): Lesson {
  return {
    ...raw,
    slug: raw.slug || raw.id,
  };
}

export async function getLessonsForStrand(
  levelSlug: string,
  strandSlug: string
): Promise<Lesson[]> {
  try {
    const lessons = await import(
      `@/data/levels/${levelSlug}/${strandSlug}/lessons.json`
    );
    const data = lessons.default || lessons;
    if (!Array.isArray(data)) return [];
    return data.map(normalizeLesson);
  } catch {
    return [];
  }
}

export async function getPracticeForStrand(
  levelSlug: string,
  strandSlug: string
): Promise<PracticeTest | null> {
  try {
    const practice = await import(
      `@/data/levels/${levelSlug}/${strandSlug}/practice.json`
    );
    const data = practice.default || practice;
    if (!data.id || !data.questions || data.questions.length === 0) {
      return null;
    }
    return data;
  } catch {
    return null;
  }
}

export async function getLessonBySlug(
  levelSlug: string,
  strandSlug: string,
  lessonSlug: string
): Promise<Lesson | undefined> {
  const lessons = await getLessonsForStrand(levelSlug, strandSlug);
  return lessons.find((l) => l.slug === lessonSlug);
}

export function generateLevelStaticParams() {
  return curriculum.levels.map((level) => ({
    levelSlug: level.slug,
  }));
}

export function generateStrandStaticParams() {
  const params: { levelSlug: string; strandSlug: string }[] = [];
  for (const level of curriculum.levels) {
    for (const strand of curriculum.strands) {
      params.push({
        levelSlug: level.slug,
        strandSlug: strand.slug,
      });
    }
  }
  return params;
}

export async function generateLessonStaticParams() {
  const params: { levelSlug: string; strandSlug: string; lessonSlug: string }[] = [];
  for (const level of curriculum.levels) {
    for (const strand of curriculum.strands) {
      const lessons = await getLessonsForStrand(level.slug, strand.slug);
      for (const lesson of lessons) {
        params.push({
          levelSlug: level.slug,
          strandSlug: strand.slug,
          lessonSlug: lesson.slug,
        });
      }
    }
  }
  return params;
}

export function getStrandsForLevel(levelSlug: string) {
  return curriculum.strands.map((strand) => ({
    ...strand,
    levelSlug,
  }));
}
