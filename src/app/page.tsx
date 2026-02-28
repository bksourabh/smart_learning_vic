import { HeroSection } from "@/components/home/HeroSection";
import { FeaturesGrid } from "@/components/home/FeaturesGrid";
import { LevelSelector } from "@/components/home/LevelSelector";
import { StrandShowcase } from "@/components/home/StrandShowcase";
import { CallToAction } from "@/components/home/CallToAction";

export default function HomePage() {
  return (
    <>
      <HeroSection />
      <FeaturesGrid />
      <LevelSelector />
      <StrandShowcase />
      <CallToAction />
    </>
  );
}
