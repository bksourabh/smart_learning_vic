import { getAllLevels } from "@/lib/curriculum";
import { LevelCard } from "@/components/curriculum/LevelCard";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";

export const metadata = {
  title: "Curriculum Browser",
  description: "Explore all 11 levels of the Victorian Curriculum Mathematics",
};

export default function CurriculumPage() {
  const levels = getAllLevels();

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs items={[{ label: "Curriculum" }]} className="mb-6" />

      <div className="mb-8">
        <h1 className="font-display text-3xl font-bold text-foreground mb-2">
          Curriculum Browser
        </h1>
        <p className="text-lg text-muted-foreground">
          Choose a level to start your learning journey
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {levels.map((level, index) => (
          <LevelCard key={level.slug} level={level} index={index} />
        ))}
      </div>
    </div>
  );
}
