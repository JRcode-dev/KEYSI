/**
 * KEYSI — Demo data hook.
 *
 * ALL data in this file is DEMO/sample data for UI development.
 * None of it represents real user accounts, real balances, or real backend data.
 * When the backend is connected, replace calls to this hook with API calls.
 */

import type {
  Room, Moment, AppEvent, Game, LeaderboardEntry, UserProfile, Gift, RoomSeat, RoomRole,
} from '@/src/types';
import { ROCKET_LEVELS } from '@/src/config/keysi';

// ── Sample images (Pexels stock photos) ───────────────────────────────────────

export const portraitImages = [
  'https://images.pexels.com/photos/14483472/pexels-photo-14483472.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/22605246/pexels-photo-22605246.png?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/14704594/pexels-photo-14704594.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/29238287/pexels-photo-29238287.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
];

const momentImages = [
  'https://images.pexels.com/photos/27177793/pexels-photo-27177793.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/35866246/pexels-photo-35866246.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/1292120/pexels-photo-1292120.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
];

const gameImages = [
  'https://images.pexels.com/photos/35736659/pexels-photo-35736659.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/17370315/pexels-photo-17370315.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/36484265/pexels-photo-36484265.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/5767690/pexels-photo-5767690.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
];

const eventImages = [
  'https://images.pexels.com/photos/13230484/pexels-photo-13230484.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/5193526/pexels-photo-5193526.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
  'https://images.pexels.com/photos/4218027/pexels-photo-4218027.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
];

// ── Demo rooms ────────────────────────────────────────────────────────────────

function makeDemoSeats(maxSeats: number): RoomSeat[] {
  const roles: RoomRole[] = ['OWNER', 'ADMIN', 'MEMBER', 'MEMBER', 'MEMBER'];
  const seats: RoomSeat[] = [];
  for (let i = 0; i < maxSeats; i++) {
    const occupied = i < 3;
    seats.push({
      seatNumber: i + 1,
      userId: occupied ? i + 1 : null,
      username: occupied ? ['Sofia Hossain', 'Arifa Janis', 'Dalia Noor'][i] : null,
      avatarUrl: occupied ? portraitImages[i] : null,
      isMuted: false,
      isLocked: i === 4,
      levelSent: [24, 18, 12, 1, 1][i] ?? 1,
      levelReceived: [18, 14, 8, 1, 1][i] ?? 1,
      role: roles[i] ?? 'MEMBER',
    });
  }
  return seats;
}

export const demoRooms: Room[] = [
  {
    id: 1, name: 'Golden Hour Lounge', description: 'Golden hour vibes',
    coverUrl: portraitImages[0], ownerId: 1, ownerUsername: 'Sofia Hossain',
    ownerAvatar: portraitImages[0], maxSeats: 5, isLive: true, isPrivate: false,
    viewerCount: 2400, totalGiftsReceived: 15_000_000, category: 'music',
    seats: makeDemoSeats(5),
    settings: {
      announcement: 'Welcome to Golden Hour!', welcomeMessage: 'Enjoy the music',
      theme: null, membershipFee: 0, touristCanMic: false, touristCanText: true,
      touristCanPhotos: false, weeklyCoinsSent: 8_500_000,
    },
    createdAt: '2026-10-20T20:00:00Z',
  },
  {
    id: 2, name: 'Midnight Confessions', description: 'Late night talks',
    coverUrl: portraitImages[1], ownerId: 2, ownerUsername: 'Arifa Janis',
    ownerAvatar: portraitImages[1], maxSeats: 5, isLive: true, isPrivate: false,
    viewerCount: 1800, totalGiftsReceived: 8_200_000, category: 'chat',
    seats: makeDemoSeats(5),
    settings: null,
    createdAt: '2026-10-22T22:00:00Z',
  },
  {
    id: 3, name: 'The Inner Circle', description: 'Exclusive conversations',
    coverUrl: portraitImages[2], ownerId: 3, ownerUsername: 'Dalia Noor',
    ownerAvatar: portraitImages[2], maxSeats: 5, isLive: true, isPrivate: false,
    viewerCount: 986, totalGiftsReceived: 3_400_000, category: 'general',
    seats: makeDemoSeats(5),
    settings: null,
    createdAt: '2026-10-23T01:00:00Z',
  },
];

// ── Demo leaderboard ──────────────────────────────────────────────────────────

export const demoLeaderboard: LeaderboardEntry[] = [
  { userId: 4, name: 'Asma Mosad', country: 'Egypt', value: '2.84M', image: portraitImages[3], rank: 1 },
  { userId: 5, name: 'Omnia Alaa', country: 'Jordan', value: '2.12M', image: portraitImages[1], rank: 2 },
  { userId: 6, name: 'Hussen Allam', country: 'UAE', value: '1.86M', image: portraitImages[2], rank: 3 },
];

// ── Demo moments ──────────────────────────────────────────────────────────────

export const demoMoments: Moment[] = [
  { id: 'm1', author: 'Sofia Hossain', authorId: 1, avatar: portraitImages[0], image: momentImages[0], caption: 'Golden hour with my favorite people — the energy in this room was unreal tonight.', likes: 3200, comments: 184, createdAt: '2026-10-23T18:00:00Z' },
  { id: 'm2', author: 'Arifa Janis', authorId: 2, avatar: portraitImages[1], image: momentImages[1], caption: 'When the room hits different and everyone just gets it.', likes: 1800, comments: 92, createdAt: '2026-10-23T16:00:00Z' },
  { id: 'm3', author: 'Dalia Noor', authorId: 3, avatar: portraitImages[2], image: momentImages[2], caption: 'Some nights are meant to be remembered. Thank you KEYSI for bringing us together.', likes: 2100, comments: 67, createdAt: '2026-10-23T14:00:00Z' },
];

// ── Demo events ───────────────────────────────────────────────────────────────

export const demoEvents: AppEvent[] = [
  { id: 'e1', title: 'KEYSI Live Festival', date: 'Oct 28 · 8PM GMT', description: 'A night of music, rooms, and massive giveaways. Join 10K+ members live.', image: eventImages[0], attendees: 8400 },
  { id: 'e2', title: 'Creators Meetup', date: 'Nov 2 · 6PM GMT', description: 'Connect with top hosts, share tips, and grow your community.', image: eventImages[2], attendees: 1200 },
];

// ── Demo games ────────────────────────────────────────────────────────────────

export const demoGames: Game[] = [
  { id: 'g1', title: 'Lucky Spin', desc: 'Spin and win · You decide how much to spend', jackpot: '50K', players: '2.4K', image: gameImages[0], hot: true },
  { id: 'g2', title: 'Coin Flip Duel', desc: 'Challenge a friend · Tip what you want', jackpot: '100K', players: '890', image: gameImages[1], hot: false },
  { id: 'g3', title: 'Treasure Hunt', desc: 'Find the treasure · Spend at your own pace', jackpot: '75K', players: '1.2K', image: gameImages[2], hot: true },
  { id: 'g4', title: 'Mystery Box', desc: 'Open boxes · Choose your amount', jackpot: '25K', players: '3.1K', image: gameImages[3], hot: false },
];

// ── Demo user profile ─────────────────────────────────────────────────────────
// DEMO ONLY — not a real account. Balance and levels are sample values.

export const demoUser: UserProfile = {
  id: 1,
  username: 'Sofia Hossain',
  email: 'demo@keysi.app',
  avatarUrl: portraitImages[0],
  bio: 'Music lover | Room host | Golden hour specialist',
  coins: 24_580_000,       // DEMO: sample coin balance
  diamonds: 1_240_000,     // DEMO: sample diamond balance
  xpSent: 12_400_000,      // DEMO: sample XP for Wealth
  xpReceived: 4_100_000,   // DEMO: sample XP for Charm
  levelSent: 24,           // Wealth level (unbounded)
  levelReceived: 18,       // Charm level (unbounded)
  role: 'OWNER',
  following: 184,
  followers: 92,
  friends: 36,
  createdAt: '2026-09-01T12:00:00Z',
};

// ── Demo gifts ────────────────────────────────────────────────────────────────
// DEMO gifts for the LuckyGiftBar. Real gifts will come from GET /api/gifts.

export const demoGifts: Gift[] = [
  { id: 1, name: 'Rose', imageUrl: null, animationUrl: null, price: 100, hasAnimation: true, animationDuration: 2, isActive: true, type: 'lucky' },
  { id: 2, name: 'Crown', imageUrl: null, animationUrl: null, price: 5_000, hasAnimation: true, animationDuration: 3, isActive: true, type: 'lucky' },
  { id: 3, name: 'Rocket', imageUrl: null, animationUrl: null, price: 50_000, hasAnimation: true, animationDuration: 5, isActive: true, type: 'lucky' },
  { id: 4, name: 'Diamond', imageUrl: null, animationUrl: null, price: 500_000, hasAnimation: true, animationDuration: 5, isActive: true, type: 'lucky' },
];

// ── Export rocket config for convenience ──────────────────────────────────────

export { ROCKET_LEVELS };
