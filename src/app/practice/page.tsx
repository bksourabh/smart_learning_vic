"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { StrandIcon } from "@/components/shared/StrandIcon";
import { getStrandLightBgClass, getStrandTextClass } from "@/lib/utils";
import { ClipboardCheck, ArrowRight } from "lucide-react";
import type { PracticeTest } from "@/types/practice";

interface AvailablePractice {
  level: { slug: string; name: string };
  strand: { slug: string; name: string };
  test: PracticeTest;
  firstLessonSlug: string;
}

export default function PracticeBrowserPage() {
  const [practices, setPractices] = useState<AvailablePractice[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadPractices() {
      try {
        const curriculumMod = await import("@/data/curriculum.json");
        const curriculum = curriculumMod.default || curriculumMod;

        const results: AvailablePractice[] = [];

        for (const level of curriculum.levels) {
          for (const strand of curriculum.strands) {
            try {
              const [practiceMod, lessonsMod] = await Promise.all([
                import(`@/data/levels/${level.slug}/${strand.slug}/practice.json`),
                import(`@/data/levels/${level.slug}/${strand.slug}/lessons.json`),
              ]);
              const practice = practiceMod.default || practiceMod;
              const lessons = lessonsMod.default || lessonsMod;

              if (practice?.id && practice?.questions?.length > 0 && lessons?.length > 0) {
                results.push({
                  level,
                  strand,
                  test: practice,
                  firstLessonSlug: lessons[lessons.length - 1].slug,
                });
              }
            } catch {
              // No practice for this combo
            }
          }
        }

        setPractices(results);
      } catch {
        // Curriculum load failed
      } finally {
        setLoading(false);
      }
    }
    loadPractices();
  }, []);

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs items={[{ label: "Practice Tests" }]} className="mb-6" />

      <div className="mb-8">
        <h1 className="font-display text-3xl font-bold text-foreground mb-2">
          Practice Tests
        </h1>
        <p className="text-lg text-muted-foreground">
          Test your knowledge with quizzes across all levels and strands
        </p>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="rounded-2xl border border-border bg-surface-raised p-6 animate-pulse">
              <div className="h-6 bg-muted rounded w-3/4 mb-4" />
              <div className="h-4 bg-muted rounded w-1/2 mb-6" />
              <div className="h-10 bg-muted rounded w-32" />
            </div>
          ))}
        </div>
      ) : practices.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {practices.map(({ level, strand, test, firstLessonSlug }) => (
            <Link
              key={`${level.slug}-${strand.slug}`}
              href={`/curriculum/${level.slug}/${strand.slug}/${firstLessonSlug}/practice`}
              className="group block"
            >
              <div className="rounded-2xl border border-border bg-surface-raised p-6 hover:shadow-lg transition-all duration-300">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className={`flex items-center justify-center w-10 h-10 rounded-lg ${getStrandLightBgClass(strand.slug)} ${getStrandTextClass(strand.slug)}`}>
                      <StrandIcon strand={strand.slug} size={20} />
                    </div>
                    <div>
                      <h3 className="font-display font-semibold group-hover:text-primary-600 transition-colors">
                        {test.title}
                      </h3>
                      <p className="text-sm text-muted-foreground">
                        {level.name} &bull; {strand.name}
                      </p>
                    </div>
                  </div>
                  <ArrowRight className="h-5 w-5 text-muted-foreground group-hover:text-primary-600 transition-colors mt-1" />
                </div>
                <p className="text-sm text-muted-foreground mb-4">{test.description}</p>
                <div className="flex items-center gap-4 text-xs text-muted-foreground">
                  <span className="flex items-center gap-1">
                    <ClipboardCheck className="h-3.5 w-3.5" />
                    {test.questions.length} questions
                  </span>
                  <span>Pass: {test.passingScore}%</span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      ) : (
        <div className="text-center py-20">
          <ClipboardCheck className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
          <h3 className="font-display text-lg font-semibold mb-2">No Practice Tests Yet</h3>
          <p className="text-muted-foreground">
            Practice tests are being developed. Check back soon!
          </p>
        </div>
      )}
    </div>
  );
}
