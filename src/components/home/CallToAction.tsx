"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowRight, Rocket } from "lucide-react";

export function CallToAction() {
  return (
    <section className="py-20 bg-gradient-to-r from-primary-600 to-violet-600">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
        >
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/20 mb-6">
            <Rocket className="h-8 w-8 text-white" />
          </div>
          <h2 className="font-display text-3xl sm:text-4xl font-bold text-white mb-4">
            Ready to Start Your Maths Journey?
          </h2>
          <p className="text-lg text-white/80 mb-8 max-w-xl mx-auto">
            Join thousands of Victorian students mastering mathematics with interactive
            lessons and practice tests.
          </p>
          <Link
            href="/curriculum"
            className="inline-flex items-center gap-2 rounded-xl bg-white px-8 py-4 text-base font-semibold text-primary-700 shadow-lg hover:bg-gray-50 transition-colors"
          >
            Explore Curriculum
            <ArrowRight className="h-5 w-5" />
          </Link>
        </motion.div>
      </div>
    </section>
  );
}
