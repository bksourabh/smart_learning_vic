export type StrandSlug = "number" | "algebra" | "measurement" | "space" | "statistics";

export interface StrandColors {
  primary: string;
  secondary: string;
  bg: string;
  bgDark: string;
  text: string;
  border: string;
}

export interface StrandDefinition {
  slug: StrandSlug;
  name: string;
  fullName: string;
  description: string;
  icon: string;
  colors: StrandColors;
}

export interface LevelMeta {
  slug: string;
  name: string;
  shortName: string;
  yearRange: string;
  description: string;
  color: string;
  order: number;
  achievementStandard: string;
}

export interface CurriculumData {
  strands: StrandDefinition[];
  levels: LevelMeta[];
}

export interface StrandOverview {
  strandSlug: StrandSlug;
  levelSlug: string;
  lessonCount: number;
  practiceAvailable: boolean;
  description: string;
}
