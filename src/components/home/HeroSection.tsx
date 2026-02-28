"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles } from "lucide-react";

const floatingShapes = [
  { x: "10%", y: "20%", size: 60, color: "#f59e0b", delay: 0 },
  { x: "80%", y: "15%", size: 40, color: "#8b5cf6", delay: 0.5 },
  { x: "70%", y: "70%", size: 50, color: "#10b981", delay: 1 },
  { x: "15%", y: "75%", size: 35, color: "#f43f5e", delay: 1.5 },
  { x: "50%", y: "10%", size: 45, color: "#06b6d4", delay: 0.8 },
  { x: "90%", y: "50%", size: 30, color: "#3b82f6", delay: 1.2 },
];

export function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-primary-50 via-blue-50 to-violet-50 dark:from-primary-950/50 dark:via-slate-900 dark:to-violet-950/30 py-20 sm:py-28 lg:py-36">
      {/* Floating shapes */}
      {floatingShapes.map((shape, i) => (
        <motion.div
          key={i}
          className="absolute rounded-full opacity-20 dark:opacity-10"
          style={{
            left: shape.x,
            top: shape.y,
            width: shape.size,
            height: shape.size,
            background: shape.color,
          }}
          animate={{
            y: [0, -15, 0],
            x: [0, 8, 0],
            scale: [1, 1.1, 1],
          }}
          transition={{
            duration: 4,
            repeat: Infinity,
            delay: shape.delay,
            ease: "easeInOut",
          }}
        />
      ))}

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          <div className="inline-flex items-center gap-2 rounded-full bg-primary-100 dark:bg-primary-900/40 px-4 py-2 text-sm font-medium text-primary-700 dark:text-primary-300 mb-6">
            <Sparkles className="h-4 w-4" />
            Victorian Curriculum v2.0 Aligned
          </div>
        </motion.div>

        <motion.h1
          className="font-display text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-foreground mb-6"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
        >
          Master Maths,{" "}
          <span className="bg-gradient-to-r from-primary-600 via-violet-600 to-emerald-600 bg-clip-text text-transparent">
            One Level at a Time
          </span>
        </motion.h1>

        <motion.p
          className="mx-auto max-w-2xl text-lg sm:text-xl text-muted-foreground mb-10"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          Interactive lessons and practice tests for Foundation to Level 10.
          Learn at your own pace with step-by-step explanations, worked examples,
          and instant feedback.
        </motion.p>

        <motion.div
          className="flex flex-col sm:flex-row items-center justify-center gap-4"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
        >
          <Link
            href="/curriculum"
            className="inline-flex items-center gap-2 rounded-xl bg-primary-600 px-8 py-4 text-base font-semibold text-white shadow-lg shadow-primary-500/30 hover:bg-primary-700 hover:shadow-xl transition-all duration-200"
          >
            Start Learning
            <ArrowRight className="h-5 w-5" />
          </Link>
          <Link
            href="/practice"
            className="inline-flex items-center gap-2 rounded-xl border-2 border-border bg-background px-8 py-4 text-base font-semibold text-foreground hover:bg-muted transition-all duration-200"
          >
            Try a Practice Test
          </Link>
        </motion.div>
      </div>
    </section>
  );
}
