import Link from "next/link";
import { GraduationCap, Heart } from "lucide-react";

export function Footer() {
  return (
    <footer className="border-t border-border bg-surface">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="md:col-span-1">
            <Link href="/" className="flex items-center gap-2 mb-4">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary-600 text-white">
                <GraduationCap className="h-4 w-4" />
              </div>
              <span className="font-display text-lg font-bold">
                Smart<span className="text-primary-600">Learning</span>
              </span>
            </Link>
            <p className="text-sm text-muted-foreground">
              Victorian Curriculum aligned mathematics platform for Foundation to Level 10.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-display font-semibold mb-3 text-sm">Learn</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/curriculum" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  Curriculum
                </Link>
              </li>
              <li>
                <Link href="/practice" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  Practice Tests
                </Link>
              </li>
              <li>
                <Link href="/progress" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  My Progress
                </Link>
              </li>
            </ul>
          </div>

          {/* Levels */}
          <div>
            <h3 className="font-display font-semibold mb-3 text-sm">Levels</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/curriculum/foundation" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  Foundation
                </Link>
              </li>
              <li>
                <Link href="/curriculum/level-1" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  Level 1-3
                </Link>
              </li>
              <li>
                <Link href="/curriculum/level-7" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  Level 7-10
                </Link>
              </li>
            </ul>
          </div>

          {/* About */}
          <div>
            <h3 className="font-display font-semibold mb-3 text-sm">About</h3>
            <ul className="space-y-2">
              <li className="text-sm text-muted-foreground">
                Aligned to Victorian Curriculum v2.0
              </li>
              <li className="text-sm text-muted-foreground">
                Foundation to Level 10
              </li>
              <li className="text-sm text-muted-foreground">
                5 Mathematics Strands
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-8 pt-8 border-t border-border flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-xs text-muted-foreground flex items-center gap-1">
            Made with <Heart className="h-3 w-3 text-red-500 fill-red-500" /> for Victorian students
          </p>
          <p className="text-xs text-muted-foreground">
            {new Date().getFullYear()} Smart Learning. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
