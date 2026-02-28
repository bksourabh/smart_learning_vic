import { generateLessonStaticParams } from "@/lib/curriculum";
import PracticePageClient from "./PracticePageClient";

export async function generateStaticParams() {
  return generateLessonStaticParams();
}

export default function PracticePage({
  params,
}: {
  params: { levelSlug: string; strandSlug: string; lessonSlug: string };
}) {
  return (
    <PracticePageClient
      levelSlug={params.levelSlug}
      strandSlug={params.strandSlug}
    />
  );
}
