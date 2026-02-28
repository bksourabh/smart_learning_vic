"use client";

import { motion } from "framer-motion";
import { BookOpen, GraduationCap, BarChart3, Shield } from "lucide-react";

const features = [
  {
    icon: BookOpen,
    title: "Interactive Lessons",
    description:
      "Step-by-step explanations with worked examples. Learn new concepts at your own pace.",
    color: "bg-amber-100 text-amber-600 dark:bg-amber-900/30 dark:text-amber-400",
  },
  {
    icon: GraduationCap,
    title: "Practice Tests",
    description:
      "Test your knowledge with quizzes. Get instant feedback and detailed explanations.",
    color: "bg-violet-100 text-violet-600 dark:bg-violet-900/30 dark:text-violet-400",
  },
  {
    icon: BarChart3,
    title: "Track Progress",
    description:
      "See how far you've come. Track streaks, achievements, and completion across all strands.",
    color: "bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30 dark:text-emerald-400",
  },
  {
    icon: Shield,
    title: "Curriculum Aligned",
    description:
      "All content follows the Victorian Curriculum Version 2.0 for Mathematics.",
    color: "bg-cyan-100 text-cyan-600 dark:bg-cyan-900/30 dark:text-cyan-400",
  },
];

const containerVariants = {
  hidden: {},
  visible: {
    transition: { staggerChildren: 0.1 },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
};

export function FeaturesGrid() {
  return (
    <section className="py-20 bg-background">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="font-display text-3xl font-bold text-foreground mb-4">
            Everything You Need to Succeed
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            A complete learning experience designed to make maths fun and accessible
          </p>
        </div>

        <motion.div
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
        >
          {features.map((feature) => (
            <motion.div
              key={feature.title}
              variants={itemVariants}
              className="group rounded-2xl border border-border bg-surface-raised p-6 hover:shadow-lg transition-shadow duration-300"
            >
              <div
                className={`inline-flex items-center justify-center w-12 h-12 rounded-xl ${feature.color} mb-4`}
              >
                <feature.icon className="h-6 w-6" />
              </div>
              <h3 className="font-display font-semibold text-lg mb-2">{feature.title}</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
