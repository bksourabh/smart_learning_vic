"use client";

import { useEffect, useState } from "react";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { PracticeTestRunner } from "@/components/practice/PracticeTestRunner";
import { Skeleton } from "@/components/ui/Skeleton";
import type { PracticeTest } from "@/types/practice";

interface PracticePageClientProps {
  levelSlug: string;
  strandSlug: string;
}

export default function PracticePageClient({
  levelSlug,
  strandSlug,
}: PracticePageClientProps) {
  const [test, setTest] = useState<PracticeTest | null>(null);
  const [level, setLevel] = useState<{ slug: string; name: string } | null>(null);
  const [strand, setStrand] = useState<{ slug: string; name: string } | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [curriculumMod, practiceMod] = await Promise.all([
          import("@/data/curriculum.json"),
          import(`@/data/levels/${levelSlug}/${strandSlug}/practice.json`),
        ]);

        const curriculum = curriculumMod.default || curriculumMod;
        const practice = practiceMod.default || practiceMod;

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const foundLevel = curriculum.levels.find((l: any) => l.slug === levelSlug);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const foundStrand = curriculum.strands.find((s: any) => s.slug === strandSlug);

        setLevel(foundLevel || null);
        setStrand(foundStrand || null);

        if (practice && practice.id && practice.questions?.length > 0) {
          setTest(practice);
        }
      } catch {
        // No practice test available
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [levelSlug, strandSlug]);

  if (loading) {
    return (
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
        <Skeleton variant="text" className="w-64 h-4 mb-6" />
        <Skeleton variant="card" className="max-w-2xl mx-auto" />
      </div>
    );
  }

  if (!test) {
    return (
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
        <div className="text-center py-20">
          <h2 className="font-display text-2xl font-bold mb-3">No Practice Test Available</h2>
          <p className="text-muted-foreground">
            A practice test for this strand is coming soon.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <Breadcrumbs
        items={[
          { label: "Curriculum", href: "/curriculum" },
          ...(level ? [{ label: level.name, href: `/curriculum/${level.slug}` }] : []),
          ...(strand && level
            ? [{ label: strand.name, href: `/curriculum/${level.slug}/${strand.slug}` }]
            : []),
          { label: "Practice Test" },
        ]}
        className="mb-6"
      />

      <PracticeTestRunner test={test} />
    </div>
  );
}
