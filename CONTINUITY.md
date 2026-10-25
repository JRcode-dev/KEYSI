# KEYSI — Documento de Continuidad

**Fecha:** 2026-10-25 (tercera pasada de auditoría)
**Estado:** Frontend corregido y auditado. Lucky Gift completado con entrada manual y multiplicadores visibles. Backend NO conectado.

---

## Stack y Estructura

- **Framework:** Expo SDK 58, React Native 0.88, React 19, TypeScript 7
- **Router:** Expo Router (archivo único `app/index.tsx`)
- **Navegación:** Tab-based bottom bar (Home, Discover, [+], Messages, Profile)
- **Estilos:** `StyleSheet.create` inline, sin NativeWind
- **Iconos:** `lucide-react-native`
- **Backend previsto:** Node.js + Express + PostgreSQL + Socket.IO (NO conectado, NO usar Supabase)

### Estructura de archivos creada

```
src/
├── types/index.ts        # Tipos compartidos del dominio KEYSI
├── config/keysi.ts       # Constantes del producto (economía, niveles, lucky gift, rocket)
├── utils/format.ts       # Formateadores de números grandes (coins, XP)
├── services/api.ts       # Stub del cliente HTTP (no conectado)
├── services/socket.ts    # Stub del cliente Socket.IO (no conectado)
└── hooks/useDemoData.ts  # Todos los datos de demostración centralizados
```

---

## Archivos Modificados y Razón

### `app/index.tsx` (refactorizado)
- **Por qué:** Corregir reglas de producto incorrectas y usar tipos compartidos.
- **Cambios:**
  - Importa tipos desde `@/src/types` en lugar de definir tipos inline.
  - Importa datos de demostración desde `@/src/hooks/useDemoData` (claramente etiquetados como DEMO).
  - `LevelPill` ahora usa `getLevelTier()` desde `@/src/config/keysi` — sin nivel máximo.
  - Descripción de niveles actualizada: "Levels are unlimited."
  - Balance etiquetado como "YOUR BALANCE · DEMO" con valores de demostración.
  - `LuckyGiftBar` reconstruida con reglas reales: valor 10–500K (con entrada manual), cantidades x1/x5/x10/x25/x50/x100 más cantidad manual, 13 multiplicadores visibles, selección de destinatarios sin máximo, cálculo de costo total = valor × destinatarios × cantidad, diamonds por destinatario (10%), tiers T1–T6, premio del creador = valor individual × multiplicador (no gasto total), botón "Send (demo)" que no ejecuta transacciones reales.
  - Room Modal ahora usa `ScrollView` para acomodar la barra expandida de Lucky Gift.
  - Room Modal ahora usa `selectedRoom.seats` para contar "on stage" dinámicamente.
  - Room Modal cambió "room rating" por "seats" (máximo de asientos).
  `formatCoins()` y `formatNumber()` desde `@/src/utils/format` para manejar cantidades grandes.

### `src/types/index.ts` (nuevo)
- Tipos: `UserProfile`, `Room`, `RoomSeat`, `RoomSettings`, `RoomRole`, `Gift`, `LuckyGiftResult`, `RocketLevel`, `Moment`, `AppEvent`, `Game`, `LeaderboardEntry`, `UserPreferences`.

### `src/config/keysi.ts` (nuevo)
- `COINS_PER_USD = 1_000_000`
- `NORMAL_GIFT_DIAMOND_RATE = 0.60`
- `DIAMONDS_TO_COINS_RATE = 0.95`
- `ROOM_OWNER_WEEKLY_RATE = 0.05`
- `MAX_LEVEL = null` (niveles ilimitados)
- `TIER_BOUNDARIES`: standard 1–49, premium 50–99, elite 100–199, royal 200+
- `LUCKY_GIFT_MIN_VALUE = 10`, `LUCKY_GIFT_MAX_VALUE = 500_000`
- `LUCKY_GIFT_QUANTITIES = [1, 5, 10, 25, 50, 100]`
- `LUCKY_GIFT_MULTIPLIERS = [1, 5, 10, 25, 50, 100, 250, 500, 600, 750, 800, 900, 1000]`
- `LUCKY_GIFT_TIERS`: T1 (10–999) hasta T6 (500K)
- `ROCKET_LEVELS`: 7 niveles con costos (12M, 24M, 42M, 72M, 120M, 210M, 360M)

### `src/utils/format.ts` (nuevo)
- `formatCoins()`: formatea hasta billones (B, M, K).
- `formatNumber()`: separador de miles con `toLocaleString`.
- `xpForLevel()`: fórmula del documento maestro (base 10000 × 1.15^(level-1)).
- `levelProgress()`: calcula porcentaje y XP restante.

### `src/services/api.ts` (nuevo)
- Stub del cliente HTTP. Lee `EXPO_PUBLIC_API_URL`. **No conectado.**
- Endpoints definidos: auth, rooms, wallet, gifts, leaderboard, moments, events, games.

### `src/services/socket.ts` (nuevo)
- Stub del cliente Socket.IO. Lee `EXPO_PUBLIC_SOCKET_URL`. **No conectado.**
- Eventos definidos: join/leave room, send message, send gift, send lucky gift, voice, WebRTC, seat management, rocket, moderación (kick, ban, mute seat, lock seat).

### `src/hooks/useDemoData.ts` (nuevo)
- Todos los datos mock centralizados: `demoRooms`, `demoLeaderboard`, `demoMoments`, `demoEvents`, `demoGames`, `demoUser`, `demoGifts`.
- Cada export está documentado como DEMO.
- `demoRooms` incluye `seats` con roles OWNER/ADMIN/MEMBER, `settings` con campos de configuración de sala.
- `demoUser` tiene balances de demostración (24.58M coins, 1.24M diamonds).

---

## Reglas de Producto Reflejadas Correctamente

1. **Niveles ilimitados** — `MAX_LEVEL = null`, `getLevelTier()` no tiene tope, LevelPill funciona con cualquier nivel.
2. **Economía** — 1 USD = 1M coins, 60% diamonds en regalos normales, 95% conversión diamonds→coins, 5% recompensa semanal propietario, sin cashout.
3. **Lucky Gift** — valor 10–500K con entrada manual y validación de rango, cantidades x1/x5/x10/x25/x50/x100 más cantidad manual, 13 multiplicadores visibles en la interfaz, 6 tiers T1–T6, 10% diamonds por destinatario, costo total = valor × destinatarios × cantidad, premio del creador = valor individual × multiplicador (no gasto total), botón etiquetado como demo.
4. **Rocket** — 7 niveles con costos correctos (12M–360M coins).
5. **Datos demo etiquetados** — balance marcado "DEMO", nota "Demo only" en lucky gift.

---

## Funciones que Siguen Siendo Mocks

- Todas las salas, momentos, eventos, juegos y leaderboard (`useDemoData.ts`).
- Balance del perfil (24.58M coins, 1.24M diamonds — valores de muestra).
- Niveles del perfil (Wealth 24, Charm 18 — valores de muestra).
- Botones del menú de perfil (Wallet, My gifts, Saved rooms, etc.) — no navegan.
- Create Modal — las 4 opciones cierran el modal sin ejecutar acciones.
- LuckyGiftBar "Send (demo)" — no envía nada al backend.
- Search bar — no funcional.
- Filtros de salas (All rooms, Trending, etc.) — cambian visualmente, no filtran datos.
- Tabs de ranking (Daily/Weekly/Monthly) — no cambian datos.
- Messages screen — mensaje de bienvenida estático, conexiones sugeridas usan datos del leaderboard.

---

## Contrato de Integración (NO verificado — pendiente de confirmar con el backend)

Los stubs en `src/services/` definen la interfaz pero **no están conectados**. No existe URL de backend operativa. Las rutas y eventos siguientes son **propuestas** que deben confirmarse inspeccionando el backend real.

### API endpoints propuestos (`src/services/api.ts`) — pendientes de confirmar
- `POST /auth/login`, `POST /auth/register`, `GET /auth/verify`
- `GET /rooms`, `GET /rooms/hot`, `GET /rooms/recent`, `GET /rooms/:id`, `POST /rooms`, `DELETE /rooms/:id`, `GET /rooms/:id/messages`
- `GET /wallet/balance`, `POST /wallet/recharge`
- `GET /gifts`
- `GET /leaderboard/:period`
- `GET /moments`, `GET /events`, `GET /games`

### Socket.IO events propuestos (`src/services/socket.ts`) — pendientes de confirmar
- Client→Server: authenticate, join_room, leave_room, send_message, send_gift, send_lucky_gift, join_voice, leave_voice, toggle_mute, speaking, webrtc_offer/answer/ice_candidate, add_diamonds_to_rocket, invite_to_seat, lock_seat, unlock_seat, mute_seat, remove_from_seat, kick_user, ban_user, set_seats
- Server→Client: new_message, gift_received, lucky_gift_result, user_joined/left_room, user_joined/left_voice, user_speaking, user_muted, rocket_updated, rocket_launched, seat_updated, user_kicked, user_banned, seats_changed

### Datos que no se pueden determinar sin inspeccionar el backend
- Estructura exacta de respuestas JSON (campos, nombres, tipos).
- Eventos Socket.IO reales y sus payloads.
- Esquema de la base de datos PostgreSQL (tablas, columnas, relaciones).
- Sistema de autenticación (JWT, sesiones, formato del token).
- Reglas de validación de transacciones (idempotencia, atomicidad).
- Configuración versionada de probabilidades de Lucky Gift.
- Límites de emisión globales y por usuario.
- Formato de los registros de acciones de moderación.

---

## Pendientes de Backend

1. **Autenticación** — login/register/verify + persistencia de token (secure storage).
2. **Salas reales** — CRUD completo, listado, join/leave via Socket.IO.
3. **Room Screen completa** — stage con asientos, chat en vivo, voz WebRTC, moderación.
4. **Wallet real** — balance, recarga, conversión diamonds→coins.
5. **Lucky Gift real** — envío via Socket.IO, recepción de resultado del backend.
6. **Gifts normales** — lista de regalos desde API, envío via Socket.IO.
7. **Momentos** — CRUD, upload de fotos, like/comment.
8. **Eventos** — CRUD, participar, guardar.
9. **Juegos** — integración con minijuegos reales.
10. **Mensajería privada** — lista de conversaciones + chat 1-a-1.
11. **Notificaciones** — pantalla y push.
12. **Búsqueda** — search real de salas, usuarios, eventos.
13. **Perfil edit** — avatar, bio, username.
14. **Preferencias** — toggle de efectos de regalos, rocket, entrada.

---

## Reglas de Salas, Roles y Permisos

**Roles:** OWNER, ADMIN, MEMBER, TOURIST (definidos en `src/types/index.ts` y `src/config/keysi.ts`).

**Asientos** (eventos Socket.IO definidos en `src/services/socket.ts`):
- Propietario puede cambiar el número de asientos (`set_seats`).
- Si se reducen asientos, los usuarios afectados permanecen en la sala pero sin asiento.
- Propietario o admin puede invitar a un usuario presente a un asiento (`invite_to_seat`); el invitado puede aceptar o rechazar.
- Propietario o admin puede bloquear/desbloquear asientos (`lock_seat` / `unlock_seat`).
- Propietario o admin puede silenciar un asiento (`mute_seat`); el usuario silenciado no puede reactivar su micrófono.
- Propietario o admin puede retirar a un usuario de su asiento sin expulsarlo (`remove_from_seat`).

**Moderación:**
- Expulsión temporal de 10 minutos (`kick_user` con `durationMinutes: 10`).
- Bloqueo permanente de entrada (`ban_user`).
- Los administradores no pueden actuar contra el propietario ni contra otros administradores (validación del backend).
- El propietario es el único que puede modificar configuración, cambiar asientos, asignar/retirar admins y consultar registros.

**Configuración de sala** (tipo `RoomSettings` en `src/types/index.ts`):
- `announcement`, `welcomeMessage`, `theme`, `membershipFee`.
- `touristCanMic`, `touristCanText`, `touristCanPhotos`.
- `weeklyCoinsSent`.

**Preferencias del usuario** (tipo `UserPreferences`):
- `showGiftEffects`, `showRocketEffects`, `showEntryEffects`.

> **Nota:** Estas reglas están tipadas y los eventos Socket.IO están definidos, pero las validaciones reales de permisos deben ejecutarse en el backend. El frontend solo refleja estados visuales.

---

## Decisiones de Producto Abiertas

- **Probabilidades de multiplicadores de Lucky Gift:** pendiente de validar y simular. El frontend no las define; deben ser configuración versionada en la base de datos.
- **Límites globales de Lucky Gift (diario/mensual/por usuario):** el frontend puede reflejar multiplicadores indisponibles, pero el backend decide.
- **Factor de actividad (0.7–1.5):** se recalcula cada 5 min en el backend. El frontend no lo calcula.
- **Cantidad manual en Lucky Gift:** implementada — hay un campo de entrada manual además de los presets x1/x5/x10/x25/x50/x100.
- **Valor manual en Lucky Gift:** implementado — el usuario puede introducir un valor entre 10 y 500.000 Coins, con validación de rango.
- **Multiplicadores visibles:** los 13 multiplicadores (x1–x1000) se muestran en la interfaz, pero su disponibilidad real depende del backend (límites diarios/mensuales/por usuario).
- **Saldo visible:** se muestra un único saldo de Coins. La separación compradas/promocionales es interna.
- **Fórmula de XP:** base 10000 × 1.15^(level-1), tomada del documento maestro. No se modificó.

---

## Validaciones Ejecutadas

### Primera pasada (2026-10-25)
- **TypeScript (`tsc --noEmit`):** PASS — 0 errores después de corregir conflicto de nombre `Gift` (lucide icon vs tipo).

### Segunda pasada (2026-10-25) — auditoría de reglas
- **TypeScript (`tsc --noEmit`):** PASS — 0 errores.
- **Búsqueda de precios antiguos de Rocket (200K–6M):** Sin coincidencias.
- **Búsqueda de `coinsPerUsd = 25000`:** Sin coincidencias.
- **Búsqueda de `maxLevel = 125`:** Sin coincidencias.
- **Búsqueda de `diamondsToCoinsRate = 0.50`:** Sin coincidencias.
- **Verificación de los 7 costos de Rocket:** correctos.
- **Verificación de multiplicadores y tiers Lucky Gift:** correctos.

### Tercera pasada (2026-10-25) — auditoría de Lucky Gift, salas e integración
- **TypeScript (`tsc --noEmit`):** PASS — 0 errores después de añadir entrada manual de valor, cantidad manual, y visualización de los 13 multiplicadores.
- **Auditoría Lucky Gift:** valor 10–500K con entrada manual ✓, cantidades preset + manual ✓, destinatarios sin máximo ✓, costo total = valor × destinatarios × cantidad ✓, diamonds por destinatario = 10% ✓, premio del creador = valor individual × multiplicador ✓, 13 multiplicadores visibles ✓, 6 tiers T1–T6 ✓.
- **Auditoría salas/roles:** tipos `RoomRole` (OWNER/ADMIN/MEMBER/TOURIST) ✓, `RoomSeat` con `isMuted`/`isLocked`/`role` ✓, `RoomSettings` con `touristCanMic`/`touristCanText`/`touristCanPhotos`/`membershipFee`/`announcement`/`welcomeMessage`/`theme`/`weeklyCoinsSent` ✓, eventos Socket.IO para `set_seats`/`invite_to_seat`/`lock_seat`/`mute_seat`/`remove_from_seat`/`kick_user` (10 min)/`ban_user` ✓.
- **Contrato de integración:** API y Socket.IO definidos como stubs, no conectados.
- **Build web y lint:** No ejecutados (limitación de entorno Bolt).

---

## Pasos para la Próxima Fase de Integración

1. **Proporcionar URL de ngrok** — configurar `EXPO_PUBLIC_API_URL` y `EXPO_PUBLIC_SOCKET_URL` en `.env`.
2. **Implementar auth** — crear pantallas de login/register, usar `api.login()` / `api.register()`, guardar token en secure storage.
3. **Reemplazar datos demo** — cambiar `useDemoData` por llamadas reales a `api.getRooms()`, `api.getBalance()`, etc.
4. **Conectar Socket.IO** — implementar `socket.connect(token)` al hacer login, escuchar eventos en Room Screen.
5. **Construir Room Screen completa** — stage, chat, voz, moderación con roles OWNER/ADMIN/MEMBER/TOURIST.
6. **Lucky Gift real** — enviar via `socketEmit.sendLuckyGift()`, escuchar `lucky_gift_result`.
7. **Wallet** — conectar `api.getBalance()` y `api.rechargeCoins()`.

---

## Información del Backend que Necesitamos Revisar

Antes de conectar el backend, necesitamos inspeccionar o recibir del propietario:

1. **Rutas HTTP reales** — confirmar los endpoints definidos en `src/services/api.ts` o proporcionar las rutas correctas.
2. **Eventos Socket.IO reales** — confirmar los nombres de eventos y sus payloads en `src/services/socket.ts`.
3. **Esquema de la base de datos** — tablas de usuarios, salas, asientos, regalos, transacciones, rockets, momentos, eventos, leaderboard.
4. **Sistema de autenticación** — formato del token JWT, duración de sesión, refresh tokens.
5. **Configuración de Lucky Gift** — probabilidades versionadas, límites diarios/mensuales/por usuario, factor de actividad.
6. **Reglas de validación** — idempotencia de transacciones, atomicidad, validación de saldos.
7. **WebRTC/voz** — signaling, STUN/TURN, formato de offers/answers.
8. **Upload de archivos** — momentos (fotos), avatares, covers de salas (storage, límites, URLs).
