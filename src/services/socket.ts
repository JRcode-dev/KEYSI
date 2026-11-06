/**
 * KEYSI — Socket.IO client stub.
 *
 * NOT CONNECTED. The backend Socket.IO server is not yet reachable.
 * This file defines the event interface the frontend will use when the
 * backend URL is provided in EXPO_PUBLIC_SOCKET_URL.
 *
 * Do not call connect() expecting a real connection — it will throw until
 * a verified backend URL is configured.
 */

type SocketEventHandler = (data: unknown) => void;

const SOCKET_URL = process.env.EXPO_PUBLIC_SOCKET_URL;

if (!SOCKET_URL) {
  console.warn('[KEYSI] EXPO_PUBLIC_SOCKET_URL is not set. Socket.IO will not connect.');
}

// ── Event names ────────────────────────────────────────────────────────────────

export const SocketEvents = {
  // Client → Server
  AUTHENTICATE: 'authenticate',
  JOIN_ROOM: 'join_room',
  LEAVE_ROOM: 'leave_room',
  SEND_MESSAGE: 'send_message',
  SEND_GIFT: 'send_gift',
  SEND_LUCKY_GIFT: 'send_lucky_gift',
  JOIN_VOICE: 'join_voice',
  LEAVE_VOICE: 'leave_voice',
  TOGGLE_MUTE: 'toggle_mute',
  SPEAKING: 'speaking',
  WEBRTC_OFFER: 'webrtc_offer',
  WEBRTC_ANSWER: 'webrtc_answer',
  WEBRTC_ICE_CANDIDATE: 'webrtc_ice_candidate',
  ADD_DIAMONDS_TO_ROCKET: 'add_diamonds_to_rocket',
  // Seat management (client → server)
  INVITE_TO_SEAT: 'invite_to_seat',
  LOCK_SEAT: 'lock_seat',
  UNLOCK_SEAT: 'unlock_seat',
  MUTE_SEAT: 'mute_seat',
  UNMUTE_SEAT: 'unmute_seat',
  REMOVE_FROM_SEAT: 'remove_from_seat',
  KICK_USER: 'kick_user',
  BAN_USER: 'ban_user',
  SET_SEATS: 'set_seats',

  // Server → Client
  NEW_MESSAGE: 'new_message',
  GIFT_RECEIVED: 'gift_received',
  LUCKY_GIFT_RESULT: 'lucky_gift_result',
  USER_JOINED_ROOM: 'user_joined_room',
  USER_LEFT_ROOM: 'user_left_room',
  USER_JOINED_VOICE: 'user_joined_voice',
  USER_LEFT_VOICE: 'user_left_voice',
  USER_SPEAKING: 'user_speaking',
  USER_MUTED: 'user_muted',
  ROCKET_UPDATED: 'rocket_updated',
  ROCKET_LAUNCHED: 'rocket_launched',
  SEAT_UPDATED: 'seat_updated',
  USER_KICKED: 'user_kicked',
  USER_BANNED: 'user_banned',
  SEATS_CHANGED: 'seats_changed',
} as const;

// ── Client interface ───────────────────────────────────────────────────────────

interface SocketClient {
  connect: (token: string) => void;
  disconnect: () => void;
  emit: (event: string, data: unknown) => void;
  on: (event: string, handler: SocketEventHandler) => void;
  off: (event: string) => void;
  isConnected: () => boolean;
}

// ── Stub implementation (not connected) ────────────────────────────────────────

const stubClient: SocketClient = {
  connect: () => {
    throw new Error('Socket.IO not configured. Set EXPO_PUBLIC_SOCKET_URL.');
  },
  disconnect: () => {},
  emit: () => {
    console.warn('[KEYSI] Socket not connected. Event not sent.');
  },
  on: () => {
    console.warn('[KEYSI] Socket not connected. Listener will not fire.');
  },
  off: () => {},
  isConnected: () => false,
};

export const socket: SocketClient = stubClient;

// ── Typed emit helpers ─────────────────────────────────────────────────────────

export const socketEmit = {
  joinRoom: (roomId: number) => socket.emit(SocketEvents.JOIN_ROOM, roomId),
  leaveRoom: () => socket.emit(SocketEvents.LEAVE_ROOM, {}),
  sendMessage: (content: string, mentionedUserId?: number) =>
    socket.emit(SocketEvents.SEND_MESSAGE, { content, mentionedUserId }),
  sendGift: (receiverId: number, roomId: number, amount: number) =>
    socket.emit(SocketEvents.SEND_GIFT, { receiverId, roomId, amount }),
  sendLuckyGift: (receiverIds: number[], roomId: number, giftValue: number, quantity: number) =>
    socket.emit(SocketEvents.SEND_LUCKY_GIFT, { receiverIds, roomId, giftValue, quantity }),
  joinVoice: (roomId: number) => socket.emit(SocketEvents.JOIN_VOICE, { roomId }),
  leaveVoice: (roomId: number) => socket.emit(SocketEvents.LEAVE_VOICE, { roomId }),
  toggleMute: (roomId: number, isMuted: boolean) =>
    socket.emit(SocketEvents.TOGGLE_MUTE, { roomId, isMuted }),
  inviteToSeat: (roomId: number, userId: number, seatNumber: number) =>
    socket.emit(SocketEvents.INVITE_TO_SEAT, { roomId, userId, seatNumber }),
  lockSeat: (roomId: number, seatNumber: number) =>
    socket.emit(SocketEvents.LOCK_SEAT, { roomId, seatNumber }),
  unlockSeat: (roomId: number, seatNumber: number) =>
    socket.emit(SocketEvents.UNLOCK_SEAT, { roomId, seatNumber }),
  muteSeat: (roomId: number, seatNumber: number) =>
    socket.emit(SocketEvents.MUTE_SEAT, { roomId, seatNumber }),
  removeFromSeat: (roomId: number, seatNumber: number) =>
    socket.emit(SocketEvents.REMOVE_FROM_SEAT, { roomId, seatNumber }),
  kickUser: (roomId: number, userId: number, durationMinutes: number) =>
    socket.emit(SocketEvents.KICK_USER, { roomId, userId, durationMinutes }),
  banUser: (roomId: number, userId: number) =>
    socket.emit(SocketEvents.BAN_USER, { roomId, userId }),
  setSeats: (roomId: number, seatCount: number) =>
    socket.emit(SocketEvents.SET_SEATS, { roomId, seatCount }),
  addDiamondsToRocket: (roomId: number, diamonds: number) =>
    socket.emit(SocketEvents.ADD_DIAMONDS_TO_ROCKET, { roomId, diamonds }),
};
