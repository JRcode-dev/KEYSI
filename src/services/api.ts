/**
 * KEYSI — HTTP API client stub.
 *
 * NOT CONNECTED. The backend (Node.js + Express + PostgreSQL) is not yet
 * reachable via ngrok. This file defines the interface the frontend will use
 * when the backend URL is provided in EXPO_PUBLIC_API_URL.
 *
 * Do not call these functions expecting real data — they will throw until
 * a verified backend URL is configured.
 */

import type {
  UserProfile, Room, Gift, LuckyGiftResult, LeaderboardEntry, LeaderboardPeriod,
  Moment, AppEvent, Game,
} from '@/src/types';

const API_URL = process.env.EXPO_PUBLIC_API_URL;

if (!API_URL) {
  console.warn('[KEYSI] EXPO_PUBLIC_API_URL is not set. API calls will fail.');
}

type ApiResponse<T> = { success: boolean; data: T; message?: string };

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  if (!API_URL) {
    throw new Error('Backend URL not configured. Set EXPO_PUBLIC_API_URL.');
  }
  const token = ''; // TODO: read from secure storage when auth is implemented
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });
  const body: ApiResponse<T> = await res.json();
  if (!res.ok || !body.success) {
    throw new Error(body.message ?? `Request failed: ${res.status}`);
  }
  return body.data;
}

export const api = {
  // Auth
  login: (email: string, password: string) =>
    request<{ token: string; user: UserProfile }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    }),
  register: (username: string, email: string, password: string) =>
    request<{ token: string; user: UserProfile }>('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ username, email, password }),
    }),
  verifyToken: () => request<{ user: UserProfile }>('/auth/verify'),

  // Rooms
  getRooms: () => request<Room[]>('/rooms'),
  getHotRooms: () => request<Room[]>('/rooms/hot'),
  getRecentRooms: () => request<Room[]>('/rooms/recent'),
  getRoom: (id: number) => request<Room>(`/rooms/${id}`),
  createRoom: (data: { name: string; description: string; isPrivate: boolean; seats: number; password?: string }) =>
    request<Room>('/rooms', { method: 'POST', body: JSON.stringify(data) }),
  deleteRoom: (id: number) => request<{ ok: boolean }>(`/rooms/${id}`, { method: 'DELETE' }),
  getRoomMessages: (id: number) => request<unknown[]>(`/rooms/${id}/messages`),

  // Wallet
  getBalance: () => request<{ coins: number; diamonds: number }>('/wallet/balance'),
  rechargeCoins: (amountUsd: number) =>
    request<{ coins: number }>('/wallet/recharge', { method: 'POST', body: JSON.stringify({ amountUsd }) }),

  // Gifts
  getGifts: () => request<Gift[]>('/gifts'),

  // Leaderboard
  getLeaderboard: (period: LeaderboardPeriod) =>
    request<LeaderboardEntry[]>(`/leaderboard/${period}`),

  // Moments
  getMoments: () => request<Moment[]>('/moments'),

  // Events
  getEvents: () => request<AppEvent[]>('/events'),

  // Games
  getGames: () => request<Game[]>('/games'),
};
