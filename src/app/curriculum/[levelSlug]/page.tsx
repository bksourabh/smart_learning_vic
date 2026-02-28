import { notFound } from "next/navigation";
import {
  getLevelBySlug,
  getAllStrands,
  getLessonsForStrand,
  getPracticeForStrand,
  generateLevelStaticParams,
} from "@/lib/curriculum";
import { getLevelColor } from "@/lib/utils";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { StrandCard } from "@/components/curriculum/StrandCard";

export async function generateStaticParams() {
  return generateLevelStaticParams();
}

export async function generateMetadata({
  params,
}: {
  params: { levelSlug: string };
}) {
  const level = getLevelBySlug(params.levelSlug);
  if (!level) return {};
  return {
    title: `${level.name} - Mathematics`,
    description: level.description,
  };
}

export default async function LevelPage({
  params,
}: {
  params: { levelSlug: string };
}) {
  const level = getLevelBySlug(params.levelSlug);
  if (!level) notFound();

  const strands = getAllStrands();
  const color = getLevelColor(level.slug);

  // Fetch lesson counts and practice availability for each strand
  const strandData = await Promise.all(
    strands.map(async (strand) => {
      const lessons = await getLessonsForStrand(level.slug, strand.slug);
      const practice = await getPracticeForStrand(level.slug, strand.slug);
      return {
        strand,
        lessonCount: lessons.length,
        practiceAvailable: practice !== null,
      };
    })
  );

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs
        items={[
          { label: "Curriculum", href: "/curriculum" },
          { label: level.name },
        ]}
        className="mb-6"
      />

      {/* Level Header */}
      <div className="rounded-2xl p-8 mb-8 text-white relative overflow-hidden" style={{ backgroundColor: color }}>
        <div className="relative z-10">
          <div className="flex items-center gap-4 mb-4">
            <div className="flex items-center justify-center w-16 h-16 rounded-2xl bg-white/20 text-2xl font-display font-bold">
              {level.shortName}
            </div>
            <div>
              <h1 className="font-display text-3xl font-bold">{level.name}</h1>
              <p className="text-white/80">{level.yearRange}</p>
            </div>
          </div>
          <p className="text-white/90 max-w-2xl">{level.description}</p>
        </div>
        {/* Decorative circles */}
        <div className="absolute top-0 right-0 w-40 h-40 rounded-full bg-white/10 -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-1/2 w-24 h-24 rounded-full bg-white/10 translate-y-1/2" />
      </div>

      {/* Achievement Standard */}
      <div className="rounded-xl border border-border bg-surface-raised p-6 mb-8">
        <h2 className="font-display font-semibold text-lg mb-2">Achievement Standard</h2>
        <p className="text-sm text-muted-foreground leading-relaxed">
          {level.achievementStandard}
        </p>
      </div>

      {/* Strands */}
      <h2 className="font-display font-semibold text-xl mb-4">Mathematics Strands</h2>
      <div className="space-y-3">
        {strandData.map(({ strand, lessonCount, practiceAvailable }, index) => (
          <StrandCard
            key={strand.slug}
            strand={strand}
            levelSlug={level.slug}
            lessonCount={lessonCount}
            practiceAvailable={practiceAvailable}
            index={index}
          />
        ))}
      </div>
    </div>
  );
}
