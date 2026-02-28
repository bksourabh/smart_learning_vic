"use client";

import { motion } from "framer-motion";
import { useEffect, useState } from "react";

const colors = ["#f59e0b", "#8b5cf6", "#10b981", "#f43f5e", "#06b6d4", "#3b82f6"];

interface Particle {
  id: number;
  x: number;
  color: string;
  size: number;
  delay: number;
}

export function CelebrationAnimation({ show }: { show: boolean }) {
  const [particles, setParticles] = useState<Particle[]>([]);

  useEffect(() => {
    if (show) {
      const newParticles: Particle[] = Array.from({ length: 30 }).map((_, i) => ({
        id: i,
        x: Math.random() * 100,
        color: colors[Math.floor(Math.random() * colors.length)],
        size: Math.random() * 8 + 4,
        delay: Math.random() * 0.5,
      }));
      setParticles(newParticles);
    }
  }, [show]);

  if (!show) return null;

  return (
    <div className="fixed inset-0 pointer-events-none z-50 overflow-hidden">
      {particles.map((p) => (
        <motion.div
          key={p.id}
          className="absolute rounded-full"
          style={{
            left: `${p.x}%`,
            top: -20,
            width: p.size,
            height: p.size,
            backgroundColor: p.color,
          }}
          initial={{ y: -20, opacity: 1, rotate: 0 }}
          animate={{
            y: window.innerHeight + 20,
            opacity: 0,
            rotate: 720,
          }}
          transition={{
            duration: 2 + Math.random(),
            delay: p.delay,
            ease: "easeOut",
          }}
        />
      ))}
    </div>
  );
}
