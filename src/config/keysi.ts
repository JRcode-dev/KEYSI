/**
 * KEYSI — Product constants.
 * These values are the authoritative rules from the product specification.
 * The backend (Node.js + Express + PostgreSQL) is the final authority at runtime;
 * the frontend uses these for display, validation hints, and demo data.
 */

// ── Economy ────────────────────────────────────────────────────────────────────

export const COINS_PER_USD = 1_000_000;

/** Receiver of a normal gift gets diamonds equal to 60% of the gift's coin value. */
export const NORMAL_GIFT_DIAMOND_RATE = 0.60;

/** Diamond → Coin conversion: diamonds × 0.95 (5% commission). */
export const DIAMONDS_TO_COINS_RATE = 0.95;

/** Room owner weekly reward: 5% of all coins sent in their room. */
export const ROOM_OWNER_WEEKLY_RATE = 0.05;

/** Weekly settlement closes Sundays at 7:00 PM Colombia time. */
export const WEEKLY_SETTLEMENT_DAY = 0; // Sunday
export const WEEKLY_SETTLEMENT_HOUR = 19; // 7 PM

/** No real-money withdrawal / cash-out exists for users. */
export const HAS_CASHOUT = false;

// ── Levels (Wealth & Charm) ─────────────────────────────────────────────────────

/** Levels are unlimited. There is NO maximum level. */
export const MAX_LEVEL = null;

/** Base XP for level 1. */
export const BASE_XP = 10_000;

/** Increment factor per level from the reference config (1 + 0.15 = 1.15x). */
export const LEVEL_INCREMENT = 1.15;

/**
 * Visual tier boundaries — purely cosmetic. They do NOT cap progression.
 * standard:  1–49
 * premium:  50–99
 * elite:   100–199
 * royal:   200+
 */
export const TIER_BOUNDARIES = {
  standard: { min: 1, max: 49 },
  premium: { min: 50, max: 99 },
  elite: { min: 100, max: 199 },
  royal: { min: 200, max: Infinity },
} as const;

export type LevelTier = keyof typeof TIER_BOUNDARIES;

export function getLevelTier(level: number): LevelTier {
  if (level >= 200) return 'royal';
  if (level >= 100) return 'elite';
  if (level >= 50) return 'premium';
  return 'standard';
}

// ── Lucky Gift ─────────────────────────────────────────────────────────────────

/** No pool in the initial version. */
export const LUCKY_GIFT_HAS_POOL = false;

/** Min and max gift value in Coins. */
export const LUCKY_GIFT_MIN_VALUE = 10;
export const LUCKY_GIFT_MAX_VALUE = 500_000;

/** Recipient receives diamonds equal to 10% of the individual gift value per send. */
export const LUCKY_GIFT_DIAMOND_RATE = 0.10;

/** Available preset quantities. Manual entry is also allowed. */
export const LUCKY_GIFT_QUANTITIES: number[] = [1, 5, 10, 25, 50, 100];

/** Defined multipliers. */
export const LUCKY_GIFT_MULTIPLIERS: number[] = [
  1, 5, 10, 25, 50, 100, 250, 500, 600, 750, 800, 900, 1000,
];

/** Value tiers. */
export const LUCKY_GIFT_TIERS = [
  { tier: 1, min: 10, max: 999 },
  { tier: 2, min: 1_000, max: 9_999 },
  { tier: 3, min: 10_000, max: 49_999 },
  { tier: 4, min: 50_000, max: 99_999 },
  { tier: 5, min: 100_000, max: 499_999 },
  { tier: 6, min: 500_000, max: 500_000 },
] as const;

/** Activity factor range; recalculated every 5 minutes by the backend. */
export const LUCKY_GIFT_ACTIVITY_MIN = 0.7;
export const LUCKY_GIFT_ACTIVITY_MAX = 1.5;
export const LUCKY_GIFT_ACTIVITY_INTERVAL_MS = 5 * 60 * 1000;

// ── Rocket ──────────────────────────────────────────────────────────────────────

export const ROCKET_LEVELS: { level: number; cost: number }[] = [
  { level: 1, cost: 12_000_000 },
  { level: 2, cost: 24_000_000 },
  { level: 3, cost: 42_000_000 },
  { level: 4, cost: 72_000_000 },
  { level: 5, cost: 120_000_000 },
  { level: 6, cost: 210_000_000 },
  { level: 7, cost: 360_000_000 },
];

// ── Room roles ──────────────────────────────────────────────────────────────────

export const ROOM_ROLES = {
  OWNER: 'OWNER',
  ADMIN: 'ADMIN',
  MEMBER: 'MEMBER',
  TOURIST: 'TOURIST',
} as const;

// ── Moments ─────────────────────────────────────────────────────────────────────

export const MAX_MOMENT_SIZE_MB = 3;
export const MAX_MOMENTS_PER_DAY = 1;
export const MAX_MOMENT_CAPTION_LENGTH = 1000;

// ── Room categories ─────────────────────────────────────────────────────────────

export const ROOM_CATEGORIES: { id: string; label: string; emoji: string }[] = [
  { id: 'general', label: 'General', emoji: '🌐' },
  { id: 'music', label: 'Music', emoji: '🎵' },
  { id: 'gaming', label: 'Gaming', emoji: '🎮' },
  { id: 'chat', label: 'Chat', emoji: '💬' },
  { id: 'education', label: 'Education', emoji: '📚' },
  { id: 'entertainment', label: 'Entertainment', emoji: '🎭' },
];
