"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ChevronRight, BookOpen, ClipboardCheck } from "lucide-react";
import { StrandIcon } from "@/components/shared/StrandIcon";
import { getStrandLightBgClass, getStrandTextClass, getStrandColor } from "@/lib/utils";
import type { StrandDefinition } from "@/types/curriculum";

interface StrandCardProps {
  strand: StrandDefinition;
  levelSlug: string;
  lessonCount: number;
  practiceAvailable: boolean;
  index: number;
}

export function StrandCard({
  strand,
  levelSlug,
  lessonCount,
  practiceAvailable,
  index,
}: StrandCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.08, duration: 0.4 }}
    >
      <Link
        href={`/curriculum/${levelSlug}/${strand.slug}`}
        className="block group"
      >
        <div className="rounded-2xl border border-border bg-surface-raised p-5 hover:shadow-md transition-all duration-300">
          <div className="flex items-center gap-4">
            <div
              className={`flex items-center justify-center w-12 h-12 rounded-xl ${getStrandLightBgClass(strand.slug)} ${getStrandTextClass(strand.slug)}`}
            >
              <StrandIcon strand={strand.slug} size={24} />
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="font-display font-semibold group-hover:text-primary-600 transition-colors">
                {strand.name}
              </h3>
              <p className="text-sm text-muted-foreground line-clamp-1">
                {strand.description}
              </p>
            </div>
            <ChevronRight className="h-5 w-5 text-muted-foreground group-hover:text-primary-600 transition-colors flex-shrink-0" />
          </div>

          <div className="mt-4 flex items-center gap-4 text-xs text-muted-foreground">
            <span className="flex items-center gap-1">
              <BookOpen className="h-3.5 w-3.5" />
              {lessonCount} {lessonCount === 1 ? "lesson" : "lessons"}
            </span>
            {practiceAvailable && (
              <span className="flex items-center gap-1">
                <ClipboardCheck className="h-3.5 w-3.5" />
                Practice test
              </span>
            )}
            {lessonCount === 0 && (
              <span className="text-xs italic">Coming soon</span>
            )}
          </div>

          {/* Strand color accent */}
          <div className="mt-3 h-1 rounded-full bg-muted overflow-hidden">
            <div
              className="h-full rounded-full"
              style={{
                backgroundColor: getStrandColor(strand.slug),
                width: lessonCount > 0 ? "100%" : "0%",
                opacity: 0.5,
              }}
            />
          </div>
        </div>
      </Link>
    </motion.div>
  );
}
