"use client";

import { MarkdownRenderer } from "@/components/shared/MarkdownRenderer";
import { ExampleBox } from "./ExampleBox";
import { KeyConceptCard } from "./KeyConceptCard";
import { getStrandColor } from "@/lib/utils";
import type { Lesson } from "@/types/lesson";
import type { LessonSection } from "@/types/lesson";

interface LessonContentProps {
  lesson: Lesson;
}

function SectionRenderer({
  section,
  strandColor,
}: {
  section: LessonSection;
  strandColor: string;
}) {
  switch (section.type) {
    case "introduction":
      return (
        <div className="mb-8">
          {section.title && (
            <h2 className="font-display text-xl font-semibold mb-3">{section.title}</h2>
          )}
          <MarkdownRenderer content={section.content} />
        </div>
      );
    case "explanation":
      return (
        <div className="mb-8">
          {section.title && (
            <h2 className="font-display text-xl font-semibold mb-3">{section.title}</h2>
          )}
          <MarkdownRenderer content={section.content} />
        </div>
      );
    case "example":
      return (
        <ExampleBox
          title={section.title || "Example"}
          problem={section.content}
          steps={section.steps || []}
          answer=""
          explanation=""
          strandColor={strandColor}
        />
      );
    case "key-concept":
      return <KeyConceptCard content={section.content} title={section.title} />;
    case "summary":
      return (
        <div className="rounded-xl bg-primary-50 dark:bg-primary-900/20 border border-primary-200 dark:border-primary-800 p-6 my-6">
          <h3 className="font-display font-semibold text-lg mb-3 text-primary-800 dark:text-primary-300">
            {section.title || "Summary"}
          </h3>
          <MarkdownRenderer content={section.content} />
        </div>
      );
    case "practice-prompt":
      return (
        <div className="rounded-xl border-2 border-dashed border-primary-300 dark:border-primary-700 p-6 my-6 text-center">
          <MarkdownRenderer content={section.content} />
        </div>
      );
    default:
      return <MarkdownRenderer content={section.content} />;
  }
}

export function LessonContent({ lesson }: LessonContentProps) {
  const strandColor = getStrandColor(lesson.strandSlug);

  return (
    <div className="max-w-3xl">
      {/* Objectives */}
      {lesson.objectives.length > 0 && (
        <div className="rounded-xl bg-surface border border-border p-6 mb-8">
          <h3 className="font-display font-semibold mb-3">Learning Objectives</h3>
          <ul className="space-y-2">
            {lesson.objectives.map((obj, i) => (
              <li key={i} className="flex items-start gap-2 text-sm text-muted-foreground">
                <span className="text-primary-600 mt-0.5">&#10003;</span>
                {obj}
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Sections */}
      {lesson.sections.map((section, index) => (
        <SectionRenderer key={index} section={section} strandColor={strandColor} />
      ))}

      {/* Worked Examples */}
      {lesson.workedExamples.length > 0 && (
        <div className="mt-8">
          <h2 className="font-display text-xl font-semibold mb-4">Worked Examples</h2>
          {lesson.workedExamples.map((example, index) => (
            <ExampleBox
              key={index}
              title={example.title}
              problem={example.problem}
              steps={example.steps}
              answer={example.answer}
              explanation={example.explanation}
              strandColor={strandColor}
            />
          ))}
        </div>
      )}
    </div>
  );
}
