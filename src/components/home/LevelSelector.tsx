"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { getAllLevels } from "@/lib/curriculum";
import { getLevelColor } from "@/lib/utils";

const levels = getAllLevels();

export function LevelSelector() {
  return (
    <section className="py-20 bg-surface">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="font-display text-3xl font-bold text-foreground mb-4">
            Choose Your Level
          </h2>
          <p className="text-lg text-muted-foreground">
            Foundation through Level 10 — find your starting point
          </p>
        </div>

        <div className="flex flex-wrap justify-center gap-4 sm:gap-6">
          {levels.map((level, index) => (
            <motion.div
              key={level.slug}
              initial={{ opacity: 0, scale: 0.5 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.05, duration: 0.3 }}
            >
              <Link
                href={`/curriculum/${level.slug}`}
                className="group flex flex-col items-center gap-2"
              >
                <div
                  className="flex items-center justify-center w-16 h-16 sm:w-20 sm:h-20 rounded-full text-white font-display font-bold text-lg sm:text-xl shadow-lg transition-transform group-hover:scale-110"
                  style={{ backgroundColor: getLevelColor(level.slug) }}
                >
                  {level.shortName}
                </div>
                <span className="text-xs sm:text-sm font-medium text-muted-foreground group-hover:text-foreground transition-colors">
                  {level.name}
                </span>
              </Link>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
