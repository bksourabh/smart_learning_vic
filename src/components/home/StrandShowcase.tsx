"use client";

import { motion } from "framer-motion";
import { getAllStrands } from "@/lib/curriculum";
import { StrandIcon } from "@/components/shared/StrandIcon";
import { getStrandLightBgClass, getStrandTextClass } from "@/lib/utils";

const strands = getAllStrands();

const containerVariants = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1 } },
};

const itemVariants = {
  hidden: { opacity: 0, x: -20 },
  visible: { opacity: 1, x: 0, transition: { duration: 0.4 } },
};

export function StrandShowcase() {
  return (
    <section className="py-20 bg-background">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="font-display text-3xl font-bold text-foreground mb-4">
            Five Strands of Mathematics
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Master all five strands of the Victorian Curriculum Mathematics
          </p>
        </div>

        <motion.div
          className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-50px" }}
        >
          {strands.map((strand) => (
            <motion.div
              key={strand.slug}
              variants={itemVariants}
              className="rounded-2xl border border-border bg-surface-raised p-5 text-center hover:shadow-md transition-shadow"
            >
              <div
                className={`inline-flex items-center justify-center w-14 h-14 rounded-xl ${getStrandLightBgClass(strand.slug)} ${getStrandTextClass(strand.slug)} mb-3`}
              >
                <StrandIcon strand={strand.slug} size={28} />
              </div>
              <h3 className="font-display font-semibold mb-1">{strand.name}</h3>
              <p className="text-xs text-muted-foreground leading-relaxed">
                {strand.description}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
