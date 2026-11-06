/**
 * KEYSI — Shared domain types.
 * These mirror the backend models (Node.js + Express + PostgreSQL).
 * The frontend uses them to type all data, whether from the API or from demo data.
 */

// ── User ──────────────────────────────────────────────────────────────────────

export type RoomRole = 'OWNER' | 'ADMIN' | 'MEMBER' | 'TOURIST';

export interface UserProfile {
  id: number;
  username: string;
  email: string;
  avatarUrl: string | null;
  bio: string | null;
  coins: number;
  diamonds: number;
  xpSent: number;
  xpReceived: number;
  levelSent: number;   // Wealth level — unbounded
  levelReceived: number; // Charm level — unbounded
  role: RoomRole;
  following: number;
  followers: number;
  friends: number;
  createdAt: string;
}

// ── Room ──────────────────────────────────────────────────────────────────────

export type RoomCategory = 'general' | 'music' | 'gaming' | 'chat' | 'education' | 'entertainment';

export interface RoomSeat {
  seatNumber: number;
  userId: number | null;
  username: string | null;
  avatarUrl: string | null;
  isMuted: boolean;
  isLocked: boolean;
  levelSent: number;
  levelReceived: number;
  role: RoomRole;
}

export interface RoomSettings {
  announcement: string | null;
  welcomeMessage: string | null;
  theme: string | null;
  membershipFee: number;
  touristCanMic: boolean;
  touristCanText: boolean;
  touristCanPhotos: boolean;
  weeklyCoinsSent: number;
}

export interface Room {
  id: number;
  name: string;
  description: string | null;
  coverUrl: string | null;
  ownerId: number;
  ownerUsername: string;
  ownerAvatar: string | null;
  maxSeats: number;
  isLive: boolean;
  isPrivate: boolean;
  viewerCount: number;
  totalGiftsReceived: number;
  category: RoomCategory;
  seats: RoomSeat[];
  settings: RoomSettings | null;
  createdAt: string;
}

// ── Gifts ─────────────────────────────────────────────────────────────────────

export type GiftType = 'normal' | 'lucky' | 'custom';

export interface Gift {
  id: number;
  name: string;
  imageUrl: string | null;
  animationUrl: string | null;
  price: number; // in Coins
  hasAnimation: boolean;
  animationDuration: number;
  isActive: boolean;
  type: GiftType;
}

// ── Lucky Gift ────────────────────────────────────────────────────────────────

export type LuckyGiftQuantity = 1 | 5 | 10 | 25 | 50 | 100;

export interface LuckyGiftMultiplier {
  value: number;
  label: string;
  available: boolean; // false when disabled by system limits
}

export interface LuckyGiftTier {
  tier: number;
  min: number;
  max: number;
}

export interface LuckyGiftResult {
  id: number;
  giftId: number;
  giftName: string;
  betAmount: number;     // individual gift value
  multiplier: number;
  winAmount: number;     // betAmount * multiplier
  createdAt: string;
}

// ── Rocket ────────────────────────────────────────────────────────────────────

export interface RocketLevel {
  level: number;
  cost: number; // in Coins
}

// ── Moments ───────────────────────────────────────────────────────────────────

export interface Moment {
  id: string;
  author: string;
  authorId: number;
  avatar: string;
  image: string;
  caption: string;
  likes: number;
  comments: number;
  createdAt: string;
}

// ── Events ────────────────────────────────────────────────────────────────────

export interface AppEvent {
  id: string;
  title: string;
  date: string;
  description: string;
  image: string;
  attendees: number;
}

// ── Games ─────────────────────────────────────────────────────────────────────

export interface Game {
  id: string;
  title: string;
  desc: string;
  jackpot: string;
  players: string;
  image: string;
  hot: boolean;
}

// ── Leaderboard ───────────────────────────────────────────────────────────────

export type LeaderboardPeriod = 'daily' | 'weekly' | 'monthly';

export interface LeaderboardEntry {
  userId: number;
  name: string;
  country: string;
  value: string;
  image: string;
  rank: number;
}

// ── Preferences ───────────────────────────────────────────────────────────────

export interface UserPreferences {
  showGiftEffects: boolean;
  showRocketEffects: boolean;
  showEntryEffects: boolean;
}
