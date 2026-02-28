import { notFound } from "next/navigation";
import Link from "next/link";
import {
  getLevelBySlug,
  getStrandBySlug,
  getLessonsForStrand,
  getPracticeForStrand,
  generateStrandStaticParams,
} from "@/lib/curriculum";
import { getStrandColor, getStrandLightBgClass, getStrandTextClass } from "@/lib/utils";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { LessonCard } from "@/components/curriculum/LessonCard";
import { StrandIcon } from "@/components/shared/StrandIcon";
import { ClipboardCheck, BookOpen } from "lucide-react";

export async function generateStaticParams() {
  return generateStrandStaticParams();
}

export async function generateMetadata({
  params,
}: {
  params: { levelSlug: string; strandSlug: string };
}) {
  const level = getLevelBySlug(params.levelSlug);
  const strand = getStrandBySlug(params.strandSlug);
  if (!level || !strand) return {};
  return {
    title: `${strand.name} - ${level.name}`,
    description: `${strand.description} for ${level.name}`,
  };
}

export default async function StrandPage({
  params,
}: {
  params: { levelSlug: string; strandSlug: string };
}) {
  const level = getLevelBySlug(params.levelSlug);
  const strand = getStrandBySlug(params.strandSlug);
  if (!level || !strand) notFound();

  const lessons = await getLessonsForStrand(level.slug, strand.slug);
  const practice = await getPracticeForStrand(level.slug, strand.slug);
  const strandColor = getStrandColor(strand.slug);

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs
        items={[
          { label: "Curriculum", href: "/curriculum" },
          { label: level.name, href: `/curriculum/${level.slug}` },
          { label: strand.name },
        ]}
        className="mb-6"
      />

      {/* Strand Header */}
      <div className="rounded-2xl border border-border bg-surface-raised p-8 mb-8">
        <div className="flex items-center gap-4 mb-4">
          <div
            className={`flex items-center justify-center w-14 h-14 rounded-xl ${getStrandLightBgClass(strand.slug)} ${getStrandTextClass(strand.slug)}`}
          >
            <StrandIcon strand={strand.slug} size={28} />
          </div>
          <div>
            <h1 className="font-display text-2xl font-bold">{strand.name}</h1>
            <p className="text-sm text-muted-foreground">
              {level.name} &bull; {strand.fullName}
            </p>
          </div>
        </div>
        <p className="text-muted-foreground">{strand.description}</p>

        <div className="flex items-center gap-6 mt-4 text-sm text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <BookOpen className="h-4 w-4" />
            {lessons.length} {lessons.length === 1 ? "lesson" : "lessons"}
          </span>
          {practice && (
            <span className="flex items-center gap-1.5">
              <ClipboardCheck className="h-4 w-4" />
              Practice test available
            </span>
          )}
        </div>
      </div>

      {/* Learning Path */}
      {lessons.length > 0 ? (
        <div>
          <h2 className="font-display font-semibold text-xl mb-4">Learning Path</h2>
          <div className="space-y-3">
            {lessons.map((lesson, index) => (
              <LessonCard key={lesson.slug} lesson={lesson} index={index} />
            ))}
          </div>

          {/* Practice Test Button */}
          {practice && (
            <div className="mt-8 rounded-2xl border-2 border-dashed p-6 text-center" style={{ borderColor: strandColor }}>
              <ClipboardCheck className="h-8 w-8 mx-auto mb-3" style={{ color: strandColor }} />
              <h3 className="font-display font-semibold text-lg mb-2">
                Ready to Test Your Knowledge?
              </h3>
              <p className="text-sm text-muted-foreground mb-4">
                Take the {strand.name} practice test for {level.name}
              </p>
              <Link
                href={`/curriculum/${level.slug}/${strand.slug}/${lessons[lessons.length - 1]?.slug || "test"}/practice`}
                className="inline-flex items-center gap-2 rounded-xl px-6 py-3 text-white font-semibold shadow-lg transition-transform hover:scale-105"
                style={{ backgroundColor: strandColor }}
              >
                <ClipboardCheck className="h-5 w-5" />
                Start Practice Test
              </Link>
            </div>
          )}
        </div>
      ) : (
        /* Empty state */
        <div className="rounded-2xl border border-dashed border-border p-12 text-center">
          <BookOpen className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
          <h3 className="font-display font-semibold text-lg mb-2">Coming Soon</h3>
          <p className="text-muted-foreground">
            Lessons for {strand.name} at {level.name} are being developed. Check back later!
          </p>
        </div>
      )}
    </div>
  );
}
