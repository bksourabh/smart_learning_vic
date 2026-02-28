import { Lightbulb } from "lucide-react";
import { MarkdownRenderer } from "@/components/shared/MarkdownRenderer";

interface KeyConceptCardProps {
  content: string;
  title?: string;
}

export function KeyConceptCard({ content, title }: KeyConceptCardProps) {
  return (
    <div className="rounded-xl bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 p-6 my-6">
      <div className="flex items-center gap-2 mb-3">
        <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-amber-100 dark:bg-amber-900/40">
          <Lightbulb className="h-5 w-5 text-amber-600" />
        </div>
        <h4 className="font-display font-semibold text-amber-800 dark:text-amber-300">
          {title || "Key Concept"}
        </h4>
      </div>
      <MarkdownRenderer content={content} className="text-amber-900 dark:text-amber-100" />
    </div>
  );
}
