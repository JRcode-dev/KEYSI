import { useState } from 'react';
import { Image, Modal, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  Bell, Bookmark, Calendar, ChevronRight, Crown, Dice5, Flame, Gamepad2, Gem, Gift as GiftIcon,
  Home, MessageCircle, Mic2, Plus, Radio, Search, Sparkles,
  Trophy, UserRound, Users, X, Zap,
} from 'lucide-react-native';

import type {
  Room, Moment, AppEvent, Game, LeaderboardEntry, UserProfile, Gift,
} from '@/src/types';
import {
  getLevelTier, LevelTier,
  LUCKY_GIFT_MIN_VALUE, LUCKY_GIFT_MAX_VALUE, LUCKY_GIFT_QUANTITIES,
  LUCKY_GIFT_MULTIPLIERS, LUCKY_GIFT_DIAMOND_RATE, LUCKY_GIFT_TIERS,
} from '@/src/config/keysi';
import { formatCoins, formatNumber } from '@/src/utils/format';
import {
  demoRooms, demoLeaderboard, demoMoments, demoEvents, demoGames,
  demoUser, demoGifts, portraitImages,
} from '@/src/hooks/useDemoData';

// ── Types for local component state ───────────────────────────────────────────

type TabKey = 'home' | 'discover' | 'messages' | 'profile';
type DiscoverFilter = 'rooms' | 'moments' | 'events' | 'games';

// ── Main Screen ───────────────────────────────────────────────────────────────

export default function HomeScreen() {
  const [activeTab, setActiveTab] = useState<TabKey>('home');
  const [activeFilter, setActiveFilter] = useState('All rooms');
  const [selectedRoom, setSelectedRoom] = useState<Room | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [discoverFilter, setDiscoverFilter] = useState<DiscoverFilter>('rooms');
  const [savedItems, setSavedItems] = useState<Set<string>>(new Set());
  const [joinedItems, setJoinedItems] = useState<Set<string>>(new Set());

  const toggleSaved = (id: string) => {
    setSavedItems((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  };

  const toggleJoined = (id: string) => {
    setJoinedItems((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  };

  return (
    <SafeAreaView style={styles.safeArea} edges={['top']}>
      <View style={styles.page}>
        {activeTab === 'home' ? (
          <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
            <View style={styles.header}>
              <View>
                <Text style={styles.eyebrow}>WELCOME BACK</Text>
                <Text style={styles.brand}>KEYSI</Text>
              </View>
              <View style={styles.headerActions}>
                <Pressable style={styles.iconButton} accessibilityLabel="Search">
                  <Search color="#E7D8BB" size={19} strokeWidth={1.8} />
                </Pressable>
                <Pressable style={styles.iconButton} accessibilityLabel="Notifications">
                  <Bell color="#E7D8BB" size={19} strokeWidth={1.8} />
                  <View style={styles.notificationDot} />
                </Pressable>
              </View>
            </View>

            <View style={styles.sectionHeader}>
              <View>
                <Text style={styles.sectionEyebrow}>YOUR NIGHT, YOUR PEOPLE</Text>
                <Text style={styles.sectionTitle}>Live rooms</Text>
              </View>
              <Pressable style={styles.seeAll}>
                <Text style={styles.seeAllText}>See all</Text>
                <ChevronRight color="#CDA65A" size={16} />
              </Pressable>
            </View>

            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filterRow}>
              {['All rooms', 'Trending', 'Following', 'New voices'].map((filter) => (
                <Pressable key={filter} onPress={() => setActiveFilter(filter)} style={[styles.filterPill, activeFilter === filter && styles.filterPillActive]}>
                  <Text style={[styles.filterText, activeFilter === filter && styles.filterTextActive]}>{filter}</Text>
                </Pressable>
              ))}
            </ScrollView>

            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.roomRail}>
              {demoRooms.map((room) => (
                <Pressable key={room.id} onPress={() => setSelectedRoom(room)} style={styles.roomCard}>
                  <Image source={{ uri: room.coverUrl ?? portraitImages[0] }} style={styles.roomImage} />
                  <LinearGradient colors={['transparent', 'rgba(20,12,15,0.96)']} style={styles.roomShade} />
                  <View style={styles.liveBadge}><View style={styles.liveDot} /><Text style={styles.liveText}>LIVE</Text></View>
                  <View style={styles.roomCardBottom}>
                    <Text style={styles.roomTitle} numberOfLines={1}>{room.name}</Text>
                    <View style={styles.roomMeta}><Text style={styles.roomHost}>{room.ownerUsername}</Text><View style={styles.metaDivider} /><Users color="#E5D5B6" size={12} /><Text style={styles.viewerText}>{formatCoins(room.viewerCount)}</Text></View>
                  </View>
                </Pressable>
              ))}
            </ScrollView>

            <LinearGradient colors={['#241A1D', '#151116']} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.spotlightCard}>
              <View style={styles.spotlightCopy}>
                <View style={styles.spotlightTag}><Sparkles color="#F1CF76" size={13} /><Text style={styles.spotlightTagText}>FEATURED EVENT</Text></View>
                <Text style={styles.spotlightTitle}>Tonight's{`\n`}Golden Hour</Text>
                <Text style={styles.spotlightSub}>Double rewards for every gift sent before midnight.</Text>
                <Pressable style={styles.primaryButton} onPress={() => setSelectedRoom(demoRooms[0])}><Text style={styles.primaryButtonText}>Join the room</Text><ChevronRight color="#271917" size={15} /></Pressable>
              </View>
              <View style={styles.spotlightArt}><Crown color="#D8AD52" size={43} strokeWidth={1.1} /><View style={styles.artRing} /><View style={styles.artRingSmall} /></View>
            </LinearGradient>

            <View style={styles.sectionHeader}>
              <View><Text style={styles.sectionEyebrow}>POWER & PRESTIGE</Text><Text style={styles.sectionTitle}>Top supporters</Text></View>
              <Pressable style={styles.seeAll}><Text style={styles.seeAllText}>View ranking</Text><ChevronRight color="#CDA65A" size={16} /></Pressable>
            </View>

            <View style={styles.rankingCard}>
              <View style={styles.rankingTabs}><Text style={styles.rankingTabActive}>Daily</Text><Text style={styles.rankingTab}>Weekly</Text><Text style={styles.rankingTab}>Monthly</Text><View style={styles.rankingPeriod}><Text style={styles.rankingPeriodText}>Today</Text><ChevronRight color="#9E8A7B" size={13} /></View></View>
              {demoLeaderboard.map((person) => (
                <View key={person.userId} style={styles.rankingRow}>
                  <View style={[styles.rankNumber, person.rank === 1 && styles.rankNumberFirst]}><Text style={styles.rankText}>{person.rank}</Text></View>
                  <Image source={{ uri: person.image }} style={styles.avatar} />
                  <View style={styles.personCopy}><Text style={styles.personName}>{person.name}</Text><Text style={styles.personCountry}>{person.country}</Text></View>
                  <View style={styles.powerValue}><Trophy color="#E3BC5A" size={13} /><Text style={styles.powerText}>{person.value}</Text></View>
                </View>
              ))}
            </View>
          </ScrollView>
        ) : activeTab === 'discover' ? (
          <DiscoverScreen
            filter={discoverFilter}
            setFilter={setDiscoverFilter}
            savedItems={savedItems}
            joinedItems={joinedItems}
            toggleSaved={toggleSaved}
            toggleJoined={toggleJoined}
            onOpenRoom={() => setSelectedRoom(demoRooms[0])}
          />
        ) : (
          <SecondaryScreen tab={activeTab} onOpenRoom={() => setSelectedRoom(demoRooms[0])} />
        )}

        <View style={styles.bottomBar}>
          <NavItem icon={Home} label="Home" active={activeTab === 'home'} onPress={() => setActiveTab('home')} accent="#E3BC5A" />
          <NavItem icon={Radio} label="Discover" active={activeTab === 'discover'} onPress={() => setActiveTab('discover')} accent="#5BC8A9" />
          <Pressable style={styles.createButton} onPress={() => setCreateOpen(true)}><LinearGradient colors={['#E4C56D', '#A87032']} style={styles.createButtonGradient}><Plus color="#271A17" size={24} strokeWidth={2.2} /></LinearGradient></Pressable>
          <NavItem icon={MessageCircle} label="Messages" active={activeTab === 'messages'} onPress={() => setActiveTab('messages')} accent="#E07B95" />
          <NavItem icon={UserRound} label="Profile" active={activeTab === 'profile'} onPress={() => setActiveTab('profile')} accent="#E3BC5A" />
        </View>
      </View>

      <Modal visible={selectedRoom !== null} transparent animationType="slide" onRequestClose={() => setSelectedRoom(null)}>
        <View style={styles.modalBackdrop}><View style={styles.roomModal}>
          <Pressable style={styles.closeButton} onPress={() => setSelectedRoom(null)}><X color="#E8D9C0" size={19} /></Pressable>
          {selectedRoom && <>
            <Image source={{ uri: selectedRoom.coverUrl ?? portraitImages[0] }} style={styles.modalImage} />
            <View style={styles.modalImageShade} />
            <ScrollView style={styles.modalContent} contentContainerStyle={{ paddingBottom: 30 }}>
              <View style={styles.liveBadge}><View style={styles.liveDot} /><Text style={styles.liveText}>LIVE NOW</Text></View>
              <Text style={styles.modalTitle}>{selectedRoom.name}</Text>
              <Text style={styles.modalHost}>Hosted by {selectedRoom.ownerUsername}</Text>
              <View style={styles.modalStats}><View><Text style={styles.modalStatValue}>{formatCoins(selectedRoom.viewerCount)}</Text><Text style={styles.modalStatLabel}>listeners</Text></View><View><Text style={styles.modalStatValue}>{selectedRoom.seats.filter((s) => s.userId !== null).length}</Text><Text style={styles.modalStatLabel}>on stage</Text></View><View><Text style={styles.modalStatValue}>{selectedRoom.maxSeats}</Text><Text style={styles.modalStatLabel}>seats</Text></View></View>
              <Pressable style={styles.joinButton} onPress={() => setSelectedRoom(null)}><Mic2 color="#251815" size={17} /><Text style={styles.joinButtonText}>Enter room</Text></Pressable>
              <LuckyGiftBar gifts={demoGifts} />
            </ScrollView>
          </>}
        </View></View>
      </Modal>

      <CreateModal visible={createOpen} onClose={() => setCreateOpen(false)} />
    </SafeAreaView>
  );
}

function NavItem({ icon: Icon, label, active, onPress, accent }: { icon: typeof Home; label: string; active: boolean; onPress: () => void; accent: string }) {
  return <Pressable onPress={onPress} style={styles.navItem}><Icon color={active ? accent : '#7D706A'} size={20} strokeWidth={active ? 2.2 : 1.7} /><Text style={[styles.navLabel, active && { color: accent, fontWeight: '700' }]}>{label}</Text></Pressable>;
}

const discoverFilters: { key: DiscoverFilter; label: string; icon: typeof Sparkles; color: string }[] = [
  { key: 'rooms', label: 'Live rooms', icon: Radio, color: '#5BC8A9' },
  { key: 'moments', label: 'Moments', icon: Sparkles, color: '#5BC8A9' },
  { key: 'events', label: 'Events', icon: Calendar, color: '#9D7BE0' },
  { key: 'games', label: 'Games', icon: Gamepad2, color: '#5BC8A9' },
];

function DiscoverScreen({
  filter, setFilter, savedItems, joinedItems, toggleSaved, toggleJoined, onOpenRoom,
}: {
  filter: DiscoverFilter;
  setFilter: (f: DiscoverFilter) => void;
  savedItems: Set<string>;
  joinedItems: Set<string>;
  toggleSaved: (id: string) => void;
  toggleJoined: (id: string) => void;
  onOpenRoom: () => void;
}) {
  return (
    <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.secondaryContent}>
      <View style={styles.secondaryHeader}>
        <View>
          <Text style={styles.eyebrow}>EXPLORE KEYSI</Text>
          <Text style={styles.secondaryTitle}>Discover</Text>
          <Text style={styles.secondarySubtitle}>Moments, events, games and more.</Text>
        </View>
        <View style={styles.secondaryIcon}><Sparkles color="#5BC8A9" size={23} /></View>
      </View>

      <View style={styles.searchBar}><Search color="#8F7C72" size={17} /><Text style={styles.searchPlaceholder}>Search everything in KEYSI</Text></View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.discoverFilterRow}>
        {discoverFilters.map((f) => {
          const Icon = f.icon;
          const isActive = filter === f.key;
          return (
            <Pressable key={f.key} onPress={() => setFilter(f.key)} style={[styles.discoverFilterPill, isActive && { backgroundColor: f.color + '22', borderColor: f.color }]}>
              <Icon color={isActive ? f.color : '#7D706A'} size={14} />
              <Text style={[styles.discoverFilterText, isActive && { color: f.color }]}>{f.label}</Text>
            </Pressable>
          );
        })}
      </ScrollView>

      {filter === 'rooms' && <RoomsSection rooms={demoRooms} onOpenRoom={onOpenRoom} />}
      {filter === 'moments' && <MomentsSection moments={demoMoments} />}
      {filter === 'events' && <EventsSection events={demoEvents} savedItems={savedItems} toggleSaved={toggleSaved} joinedItems={joinedItems} toggleJoined={toggleJoined} />}
      {filter === 'games' && <GamesSection games={demoGames} />}
    </ScrollView>
  );
}

function RoomsSection({ rooms, onOpenRoom }: { rooms: Room[]; onOpenRoom: () => void }) {
  return (
    <View>
      <Text style={styles.discoverSectionTitle}>Live rooms</Text>
      <Text style={styles.discoverSectionSub}>Find a room that matches your energy right now</Text>
      {rooms.map((room) => (
        <Pressable key={room.id} style={styles.discoverRoomCard} onPress={onOpenRoom}>
          <Image source={{ uri: room.coverUrl ?? portraitImages[0] }} style={styles.discoverRoomImage} />
          <LinearGradient colors={['transparent', 'rgba(15,10,12,0.94)']} style={styles.discoverRoomShade} />
          <View style={styles.discoverRoomLive}><View style={styles.liveDot} /><Text style={styles.liveText}>LIVE</Text></View>
          <View style={styles.discoverRoomCopy}>
            <Text style={styles.discoverRoomTitle}>{room.name}</Text>
            <Text style={styles.discoverRoomMeta}>{room.ownerUsername} · {formatCoins(room.viewerCount)} listeners</Text>
          </View>
          <View style={styles.enterRoomButton}><Mic2 color="#1B1417" size={13} /><Text style={styles.enterRoomText}>Enter</Text></View>
        </Pressable>
      ))}
    </View>
  );
}

function MomentsSection({ moments }: { moments: Moment[] }) {
  return (
    <View>
      <Text style={styles.discoverSectionTitle}>User Moments</Text>
      <Text style={styles.discoverSectionSub}>Photos up to 3MB · Captions up to 1000 characters</Text>
      {moments.map((m) => (
        <View key={m.id} style={styles.momentCard}>
          <View style={styles.momentHeader}>
            <Image source={{ uri: m.avatar }} style={styles.momentAvatar} />
            <View style={{ flex: 1 }}>
              <Text style={styles.momentAuthor}>{m.author}</Text>
              <Text style={styles.momentTime}>2h ago</Text>
            </View>
            <Pressable style={styles.momentMore}><Sparkles color="#5BC8A9" size={15} /></Pressable>
          </View>
          <Image source={{ uri: m.image }} style={styles.momentImage} />
          <View style={styles.momentActions}>
            <View style={styles.momentActionRow}>
              <Pressable style={styles.momentAction}><Flame color="#E07B95" size={17} /><Text style={styles.momentActionText}>{formatCoins(m.likes)}</Text></Pressable>
              <Pressable style={styles.momentAction}><MessageCircle color="#7B9BE8" size={17} /><Text style={styles.momentActionText}>{m.comments}</Text></Pressable>
              <Pressable style={styles.momentAction}><Bookmark color="#9D7BE0" size={17} /></Pressable>
            </View>
          </View>
          <Text style={styles.momentCaption} numberOfLines={3}>{m.caption}</Text>
        </View>
      ))}
    </View>
  );
}

function ActionButton({ id, label, icon: Icon, color, joinedItems, toggleJoined }: { id: string; label: string; icon: typeof Trophy; color: string; joinedItems: Set<string>; toggleJoined: (id: string) => void }) {
  const joined = joinedItems.has(id);
  return (
    <Pressable style={[styles.actionBtn, joined && { borderColor: color + '66' }]} onPress={() => toggleJoined(id)}>
      <Icon color={joined ? color : '#9C8779'} size={13} />
      <Text style={[styles.actionBtnText, { color: joined ? color : '#9C8779' }]}>{joined ? 'Joined' : label}</Text>
    </Pressable>
  );
}

function SaveButton({ id, savedItems, toggleSaved }: { id: string; savedItems: Set<string>; toggleSaved: (id: string) => void }) {
  const saved = savedItems.has(id);
  return (
    <Pressable style={styles.saveBtn} onPress={() => toggleSaved(id)}>
      <Bookmark color={saved ? '#9D7BE0' : '#7D706A'} size={14} fill={saved ? '#9D7BE0' : 'transparent'} />
      <Text style={[styles.saveBtnText, { color: saved ? '#9D7BE0' : '#7D706A' }]}>{saved ? 'Saved' : 'Remind me'}</Text>
    </Pressable>
  );
}

function EventsSection({ events, savedItems, toggleSaved, joinedItems, toggleJoined }: { events: AppEvent[]; savedItems: Set<string>; toggleSaved: (id: string) => void; joinedItems: Set<string>; toggleJoined: (id: string) => void }) {
  return (
    <View>
      <Text style={styles.discoverSectionTitle}>Official Events</Text>
      <Text style={styles.discoverSectionSub}>Curated by KEYSI creators</Text>
      {events.map((e) => (
        <View key={e.id} style={styles.eventCard}>
          <Image source={{ uri: e.image }} style={styles.eventImage} />
          <LinearGradient colors={['transparent', 'rgba(15,10,12,0.92)']} style={styles.eventShade} />
          <View style={styles.eventContent}>
            <View style={styles.eventDateBadge}>
              <Calendar color="#9D7BE0" size={12} />
              <Text style={styles.eventDateText}>{e.date}</Text>
            </View>
            <Text style={styles.eventTitle}>{e.title}</Text>
            <Text style={styles.eventDesc} numberOfLines={2}>{e.description}</Text>
            <View style={styles.eventFooter}>
              <View style={styles.eventAttendees}><Users color="#9D7BE0" size={13} /><Text style={styles.eventAttendeesText}>{e.attendees.toLocaleString()} attending</Text></View>
            </View>
            <View style={styles.tournamentActions}>
              <ActionButton id={e.id} label="Participate" icon={Zap} color="#9D7BE0" joinedItems={joinedItems} toggleJoined={toggleJoined} />
              <SaveButton id={e.id} savedItems={savedItems} toggleSaved={toggleSaved} />
            </View>
          </View>
        </View>
      ))}
    </View>
  );
}

function GamesSection({ games }: { games: Game[] }) {
  return (
    <View>
      <Text style={styles.discoverSectionTitle}>KEYSI Games</Text>
      <Text style={styles.discoverSectionSub}>Free to play · You decide how much to spend</Text>
      <View style={styles.freePlayBanner}>
        <Dice5 color="#5BC8A9" size={18} />
        <Text style={styles.freePlayText}>All games are free to enter. Spend coins only when you choose to.</Text>
      </View>
      <View style={styles.gamesGrid}>
        {games.map((g) => (
          <Pressable key={g.id} style={styles.gameCard}>
            <Image source={{ uri: g.image }} style={styles.gameImage} />
            <LinearGradient colors={['transparent', 'rgba(15,10,12,0.92)']} style={styles.gameShade} />
            {g.hot && <View style={styles.hotBadge}><Flame color="#E07B95" size={11} /><Text style={styles.hotBadgeText}>HOT</Text></View>}
            <View style={styles.gameContent}>
              <Text style={styles.gameTitle}>{g.title}</Text>
              <Text style={styles.gameDesc} numberOfLines={2}>{g.desc}</Text>
              <View style={styles.gameMetaRow}>
                <Text style={styles.gameFreeTag}>FREE</Text>
                <Text style={styles.gamePlayers}>{g.players} playing</Text>
              </View>
              <View style={styles.gameJackpot}><Text style={styles.gameJackpotLabel}>Jackpot</Text><Text style={styles.gameJackpotValue}>{g.jackpot}</Text></View>
            </View>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

function SecondaryScreen({ tab, onOpenRoom }: { tab: Exclude<TabKey, 'home' | 'discover'>; onOpenRoom: () => void }) {
  const screenData = {
    messages: { eyebrow: 'YOUR INNER CIRCLE', title: 'Messages', subtitle: 'Keep the conversation glowing.', icon: MessageCircle, color: '#E07B95' },
    profile: { eyebrow: 'YOUR KEYSI WORLD', title: 'Profile', subtitle: 'Your presence, your power, your story.', icon: UserRound, color: '#E3BC5A' },
  }[tab];
  const Icon = screenData.icon;

  return <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.secondaryContent}>
    <View style={styles.secondaryHeader}><View><Text style={styles.eyebrow}>{screenData.eyebrow}</Text><Text style={styles.secondaryTitle}>{screenData.title}</Text><Text style={styles.secondarySubtitle}>{screenData.subtitle}</Text></View><View style={[styles.secondaryIcon, { borderColor: screenData.color + '55' }]}><Icon color={screenData.color} size={23} /></View></View>
    {tab === 'messages' && <>
      <View style={styles.messageCard}><View style={styles.messageOrb}><MessageCircle color="#E07B95" size={20} /></View><View style={styles.messageCopy}><Text style={styles.messageTitle}>Welcome to KEYSI</Text><Text style={styles.messagePreview}>Your new conversations will appear here.</Text></View><Text style={styles.messageTime}>NOW</Text></View>
      <Text style={styles.secondarySectionTitle}>Suggested connections</Text>
      {demoLeaderboard.map((person) => <View key={person.userId} style={styles.connectionRow}><Image source={{ uri: person.image }} style={styles.connectionImage} /><View style={styles.discoverCopy}><Text style={styles.discoverTitle}>{person.name}</Text><Text style={styles.discoverMeta}>Top supporter · {person.country}</Text></View><Pressable style={styles.followButton}><Text style={styles.followText}>Connect</Text></Pressable></View>)}
    </>}
    {tab === 'profile' && <ProfileContent user={demoUser} />}
  </ScrollView>;
}

function ProfileContent({ user }: { user: UserProfile }) {
  const [subTab, setSubTab] = useState<'summary' | 'level'>('summary');
  return (
    <>
      <View style={styles.profileHero}>
        <Image source={{ uri: user.avatarUrl ?? portraitImages[0] }} style={styles.profileImage} />
        <View style={styles.profileIdentity}>
          <Text style={styles.profileName}>{user.username}</Text>
          <Text style={styles.profileHandle}>@{user.username.toLowerCase().replace(/\s+/g, '.')}</Text>
          <View style={styles.profileLevelRow}>
            <LevelPill level={user.levelSent} type="wealth" />
            <LevelPill level={user.levelReceived} type="charm" />
          </View>
        </View>
        <Pressable style={styles.editButton}><Text style={styles.editButtonText}>Edit</Text></Pressable>
      </View>

      <View style={styles.profileSubTabs}>
        <Pressable onPress={() => setSubTab('summary')} style={[styles.profileSubTab, subTab === 'summary' && styles.profileSubTabActive]}><Text style={[styles.profileSubTabText, subTab === 'summary' && styles.profileSubTabTextActive]}>Summary</Text></Pressable>
        <Pressable onPress={() => setSubTab('level')} style={[styles.profileSubTab, subTab === 'level' && styles.profileSubTabActive]}><Text style={[styles.profileSubTabText, subTab === 'level' && styles.profileSubTabTextActive]}>Level</Text></Pressable>
      </View>

      {subTab === 'summary' && <>
        <LinearGradient colors={['#2A201D', '#1A1417']} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.balanceCard}>
          <View style={styles.balanceGlow} />
          <View style={styles.balanceTopLine}>
            <View>
              <Text style={styles.balanceLabel}>YOUR BALANCE · DEMO</Text>
              <Text style={styles.balanceAmount}>{formatNumber(user.coins)}</Text>
              <Text style={styles.balanceCaption}>coins</Text>
            </View>
            <View style={styles.coinMark}><Gem color="#F1CF76" size={20} fill="#D4A94F" /></View>
          </View>
          <View style={styles.balanceBottomLine}>
            <View style={styles.diamondBalance}><Gem color="#7B9BE8" size={14} /><Text style={styles.diamondBalanceText}>{formatNumber(user.diamonds)} diamonds</Text></View>
            <Pressable style={styles.addBalance}><Plus color="#2A1B18" size={12} strokeWidth={2.5} /><Text style={styles.addBalanceText}>TOP UP</Text></Pressable>
          </View>
        </LinearGradient>

        <View style={styles.profileStats}>
          <View><Text style={styles.profileStatValue}>{formatNumber(user.following)}</Text><Text style={styles.profileStatLabel}>following</Text></View>
          <View><Text style={styles.profileStatValue}>{formatNumber(user.followers)}</Text><Text style={styles.profileStatLabel}>followers</Text></View>
          <View><Text style={styles.profileStatValue}>{formatNumber(user.friends)}</Text><Text style={styles.profileStatLabel}>friends</Text></View>
        </View>

        <View style={styles.menuCard}>{['Wallet & earnings', 'My gifts', 'Saved rooms', 'My permanent room', 'Settings'].map((item) => <Pressable key={item} style={styles.menuRow}><View style={styles.menuIcon}><Gem color="#DDB65F" size={16} /></View><Text style={styles.menuText}>{item}</Text><ChevronRight color="#7E6E68" size={16} /></Pressable>)}</View>
      </>}

      {subTab === 'level' && <>
        <View style={styles.profileLevelDetail}>
          <View style={styles.levelDetailCard}>
            <View style={styles.levelDetailHeader}><Gem color="#DDB65F" size={14} fill="#D4A94F" /><Text style={styles.levelDetailTitle}>Wealth</Text></View>
            <Text style={styles.levelDetailValue}>Lv {user.levelSent}</Text>
            <View style={styles.levelProgressTrack}><View style={[styles.levelProgressBar, { width: '68%', backgroundColor: '#DDB65F' }]} /></View>
            <Text style={styles.levelProgressLabel}>68% to Lv {user.levelSent + 1} · {formatCoins(12_400_000)} / {formatCoins(18_000_000)}</Text>
          </View>
          <View style={styles.levelDetailCard}>
            <View style={styles.levelDetailHeader}><GiftIcon color="#4FA8E0" size={14} /><Text style={[styles.levelDetailTitle, { color: '#4FA8E0' }]}>Charm</Text></View>
            <Text style={styles.levelDetailValue}>Lv {user.levelReceived}</Text>
            <View style={styles.levelProgressTrack}><View style={[styles.levelProgressBar, { width: '45%', backgroundColor: '#4FA8E0' }]} /></View>
            <Text style={styles.levelProgressLabel}>45% to Lv {user.levelReceived + 1} · {formatCoins(4_100_000)} / {formatCoins(9_000_000)}</Text>
          </View>
        </View>
        <View style={styles.levelTierInfo}>
          <Text style={styles.levelTierTitle}>How levels work</Text>
          <Text style={styles.levelTierDesc}>Send and receive gifts to raise your Wealth and Charm. As you climb, your badges evolve through four tiers — standard, premium, elite, and royal — with richer colors and ornate details at each stage. Levels are unlimited.</Text>
        </View>
      </>}
    </>
  );
}

// ── LevelPill — uses getLevelTier() which has NO maximum level ───────────────

function LevelPill({ level, type }: { level: number; type: 'wealth' | 'charm' }) {
  const isWealth = type === 'wealth';
  const tier: LevelTier = getLevelTier(level);
  const palette: Record<LevelTier, readonly [string, string, string]> = isWealth
    ? {
        standard: ['#F5E0A0', '#DDB65F', '#A87032'],
        premium: ['#FFF0B8', '#E9A832', '#B85B1D'],
        elite: ['#FFF9D6', '#F3C64E', '#D16B24'],
        royal: ['#FFFCE8', '#FFD76A', '#B97A20'],
      }
    : {
        standard: ['#B8E4FF', '#4FA8E0', '#2B7AB8'],
        premium: ['#D7F4FF', '#4DC6E8', '#2679C4'],
        elite: ['#E7F7FF', '#67B8FF', '#514ACB'],
        royal: ['#F2ECFF', '#A56BFF', '#4A31B8'],
      };
  const colors = palette[tier];
  const Icon = tier === 'royal' ? Crown : tier === 'elite' ? Sparkles : tier === 'premium' ? Gem : null;
  const isOrnate = tier !== 'standard';
  return (
    <View style={[styles.levelPillFrame, isOrnate && { borderColor: colors[0], shadowColor: colors[1] }]}>
      <LinearGradient colors={colors} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={[styles.levelPill, isOrnate && styles.levelPillOrnate]}>
        {Icon && <Icon color="#FFFFFF" size={tier === 'royal' ? 10 : 9} fill={tier === 'royal' ? 'rgba(255,255,255,0.28)' : 'transparent'} strokeWidth={2.5} />}
        <Text style={styles.levelPillText}>{level}</Text>
      </LinearGradient>
    </View>
  );
}

// ── LuckyGiftBar — follows KEYSI product rules ───────────────────────────────
// Value: 10–500,000 Coins. Quantities: 1, 5, 10, 25, 50, 100 or manual.
// Multipliers: 1–1000. Recipients: 1+ (no max). Diamond rate: 10% per send.
// This is a DEMO UI. No real prizes, balance changes, or random outcomes.

function LuckyGiftBar({ gifts }: { gifts: Gift[] }) {
  const [selectedGiftId, setSelectedGiftId] = useState<number | null>(null);
  const [quantity, setQuantity] = useState<number>(1);
  const [customQuantity, setCustomQuantity] = useState<string>('');
  const [customValue, setCustomValue] = useState<string>('');
  const [recipientCount, setRecipientCount] = useState<number>(1);

  const selectedGift = gifts.find((g) => g.id === selectedGiftId) ?? null;
  const giftValue = selectedGift
    ? selectedGift.price
    : (customValue ? Math.floor(parseInt(customValue, 10) || 0) : 0);
  const effectiveQuantity = customQuantity ? Math.max(1, Math.floor(parseInt(customQuantity, 10) || 1)) : quantity;
  const totalCost = giftValue * recipientCount * effectiveQuantity;
  const diamondsPerRecipient = Math.round(giftValue * LUCKY_GIFT_DIAMOND_RATE * effectiveQuantity);
  const maxWinPerSend = giftValue * 1000;

  const valueInRange = giftValue >= LUCKY_GIFT_MIN_VALUE && giftValue <= LUCKY_GIFT_MAX_VALUE;
  const canSend = giftValue > 0 && valueInRange && recipientCount >= 1 && totalCost > 0;

  const currentTier = LUCKY_GIFT_TIERS.find((t) => giftValue >= t.min && giftValue <= t.max);

  return (
    <View style={styles.luckyGiftWrap}>
      <View style={styles.luckyGiftHeader}>
        <View style={styles.luckyGiftTitleRow}><Dice5 color="#E8956A" size={16} /><Text style={styles.luckyGiftTitle}>Lucky Gifts</Text></View>
        <View style={styles.luckyGiftInfo}><Text style={styles.luckyGiftInfoText}>Win up to x1000 · 10% in diamonds</Text></View>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.luckyGiftRow}>
        {gifts.map((g) => (
          <Pressable
            key={g.id}
            onPress={() => { setSelectedGiftId(g.id); setCustomValue(''); }}
            style={[styles.luckyGiftItem, selectedGiftId === g.id && styles.luckyGiftItemSelected]}
          >
            <Text style={styles.luckyGiftEmoji}>{g.name === 'Rose' ? '🌹' : g.name === 'Crown' ? '👑' : g.name === 'Rocket' ? '🚀' : '💎'}</Text>
            <Text style={styles.luckyGiftName}>{g.name}</Text>
            <View style={styles.luckyGiftPriceRow}><Gem color="#DDB65F" size={9} fill="#D4A94F" /><Text style={styles.luckyGiftPrice}>{formatCoins(g.price)}</Text></View>
            <View style={styles.luckyGiftMultBadge}><Text style={styles.luckyGiftMultText}>x1000</Text></View>
          </Pressable>
        ))}
      </ScrollView>

      <View style={styles.luckyGiftConfigSection}>
        <Text style={styles.luckyGiftConfigLabel}>Custom value (Coins) — {formatNumber(LUCKY_GIFT_MIN_VALUE)} to {formatNumber(LUCKY_GIFT_MAX_VALUE)}</Text>
        <TextInput
          style={styles.luckyGiftInput}
          value={customValue}
          onChangeText={(v) => { setCustomValue(v.replace(/[^0-9]/g, '')); setSelectedGiftId(null); }}
          placeholder={selectedGift ? formatNumber(selectedGift.price) : 'Enter value'}
          placeholderTextColor="#5A4A44"
          keyboardType="numeric"
        />
        <Text style={styles.luckyGiftConfigValue}>{formatNumber(giftValue)} coins</Text>
        {currentTier && <Text style={styles.luckyGiftTierLabel}>Tier T{currentTier.tier} · Range {formatNumber(currentTier.min)}–{formatNumber(currentTier.max)}</Text>}
        {!valueInRange && giftValue > 0 && <Text style={styles.luckyGiftErrorText}>Value must be between {formatNumber(LUCKY_GIFT_MIN_VALUE)} and {formatNumber(LUCKY_GIFT_MAX_VALUE)}</Text>}

        <Text style={styles.luckyGiftConfigLabel}>Quantity</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.luckyGiftQtyRow}>
          {LUCKY_GIFT_QUANTITIES.map((q) => (
            <Pressable key={q} onPress={() => { setQuantity(q); setCustomQuantity(''); }} style={[styles.luckyGiftQtyPill, !customQuantity && quantity === q && styles.luckyGiftQtyPillActive]}>
              <Text style={[styles.luckyGiftQtyText, !customQuantity && quantity === q && styles.luckyGiftQtyTextActive]}>x{q}</Text>
            </Pressable>
          ))}
          <View style={[styles.luckyGiftQtyPill, customQuantity !== '' && styles.luckyGiftQtyPillActive]}>
            <TextInput
              style={[styles.luckyGiftManualInput, customQuantity !== '' && styles.luckyGiftQtyTextActive]}
              value={customQuantity}
              onChangeText={(v) => setCustomQuantity(v.replace(/[^0-9]/g, ''))}
              placeholder="Manual"
              placeholderTextColor="#5A4A44"
              keyboardType="numeric"
            />
          </View>
        </ScrollView>

        <Text style={styles.luckyGiftConfigLabel}>Recipients</Text>
        <View style={styles.luckyGiftRecipientRow}>
          <Pressable style={styles.luckyGiftRecipientBtn} onPress={() => setRecipientCount(Math.max(1, recipientCount - 1))}><Text style={styles.luckyGiftRecipientBtnText}>-</Text></Pressable>
          <Text style={styles.luckyGiftRecipientCount}>{recipientCount}</Text>
          <Pressable style={styles.luckyGiftRecipientBtn} onPress={() => setRecipientCount(recipientCount + 1)}><Text style={styles.luckyGiftRecipientBtnText}>+</Text></Pressable>
        </View>

        <Text style={styles.luckyGiftConfigLabel}>Multipliers (backend determines availability)</Text>
        <View style={styles.luckyGiftMultGrid}>
          {LUCKY_GIFT_MULTIPLIERS.map((m) => (
            <View key={m} style={styles.luckyGiftMultChip}>
              <Text style={styles.luckyGiftMultChipText}>x{m}</Text>
            </View>
          ))}
        </View>

        <View style={styles.luckyGiftSummary}>
          <View style={styles.luckyGiftSummaryRow}>
            <Text style={styles.luckyGiftSummaryLabel}>Total cost</Text>
            <Text style={styles.luckyGiftSummaryValue}>{formatNumber(totalCost)} coins</Text>
          </View>
          <View style={styles.luckyGiftSummaryRow}>
            <Text style={styles.luckyGiftSummaryLabel}>Each recipient gets</Text>
            <Text style={styles.luckyGiftSummaryValue}>{formatNumber(diamondsPerRecipient)} diamonds</Text>
          </View>
          <View style={styles.luckyGiftSummaryRow}>
            <Text style={styles.luckyGiftSummaryLabel}>Max win per send</Text>
            <Text style={styles.luckyGiftSummaryValue}>{formatNumber(maxWinPerSend)} coins</Text>
          </View>
        </View>

        <Pressable style={[styles.luckyGiftSendBtn, !canSend && styles.luckyGiftSendBtnDisabled]} disabled={!canSend}>
          <Dice5 color={canSend ? '#1B1417' : '#5A4A44'} size={15} />
          <Text style={[styles.luckyGiftSendBtnText, !canSend && styles.luckyGiftSendBtnTextDisabled]}>Send (demo)</Text>
        </Pressable>
        <Text style={styles.luckyGiftDemoNote}>Demo only — no real transaction. Prizes, probabilities, and limits are determined by the backend.</Text>
      </View>
    </View>
  );
}

function CreateModal({ visible, onClose }: { visible: boolean; onClose: () => void }) {
  const createOptions = [
    { label: 'Create your room', desc: 'Your permanent room · Edit anytime', icon: Mic2, color: '#5BC8A9' },
    { label: 'Organize an event', desc: 'Plan and schedule an event', icon: Calendar, color: '#9D7BE0' },
    { label: 'Create a moment', desc: 'Share a photo with your circle', icon: Sparkles, color: '#E07B95' },
    { label: 'Invite friends', desc: 'Bring people into KEYSI', icon: Users, color: '#7B9BE8' },
  ];
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable style={styles.createBackdrop} onPress={onClose}>
        <Pressable style={styles.createSheet} onPress={(e) => e.stopPropagation()}>
          <View style={styles.createHandle} />
          <Text style={styles.createTitle}>Create</Text>
          <Text style={styles.createSubtitle}>What would you like to do?</Text>
          {createOptions.map((opt) => {
            const Icon = opt.icon;
            return (
              <Pressable key={opt.label} style={styles.createOption} onPress={onClose}>
                <View style={[styles.createOptionIcon, { backgroundColor: opt.color + '22', borderColor: opt.color + '55' }]}><Icon color={opt.color} size={20} /></View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.createOptionLabel}>{opt.label}</Text>
                  <Text style={styles.createOptionDesc}>{opt.desc}</Text>
                </View>
                <ChevronRight color="#7D706A" size={18} />
              </Pressable>
            );
          })}
        </Pressable>
      </Pressable>
    </Modal>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#100D0F' }, page: { flex: 1, backgroundColor: '#100D0F' }, content: { paddingHorizontal: 20, paddingBottom: 112 },
  header: { paddingTop: 16, paddingBottom: 22, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }, eyebrow: { color: '#9C8779', fontSize: 10, letterSpacing: 2, fontWeight: '600' }, brand: { color: '#F1DEBA', fontSize: 27, letterSpacing: 7, fontWeight: '300', marginTop: 4 }, headerActions: { flexDirection: 'row', gap: 10 }, iconButton: { width: 39, height: 39, borderRadius: 20, backgroundColor: '#21191A', alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: '#3D2C27' }, notificationDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: '#D3AA51', position: 'absolute', right: 9, top: 8 },
  balanceCard: { borderRadius: 21, padding: 20, overflow: 'hidden', borderWidth: 1, borderColor: '#C28F43' }, balanceGlow: { width: 190, height: 190, borderRadius: 100, backgroundColor: 'rgba(255,214,118,0.13)', position: 'absolute', right: -55, top: -84 }, balanceTopLine: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }, balanceLabel: { color: '#E9C982', fontSize: 10, letterSpacing: 1.6, fontWeight: '700' }, balanceAmount: { color: '#FFF0C9', fontSize: 30, fontWeight: '600', letterSpacing: 1, marginTop: 7 }, coinMark: { width: 38, height: 38, borderRadius: 20, backgroundColor: 'rgba(255,226,151,0.16)', alignItems: 'center', justifyContent: 'center' }, balanceBottomLine: { marginTop: 19, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }, balanceCaption: { color: '#D8BE9D', fontSize: 11 }, addBalance: { flexDirection: 'row', alignItems: 'center', gap: 5, paddingHorizontal: 11, paddingVertical: 8, backgroundColor: '#E1BE68', borderRadius: 18 }, addBalanceText: { color: '#2A1B18', fontSize: 10, fontWeight: '800', letterSpacing: 1 },
  sectionHeader: { marginTop: 28, marginBottom: 14, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end' }, sectionEyebrow: { color: '#8E786D', fontSize: 9, letterSpacing: 1.5, fontWeight: '700' }, sectionTitle: { color: '#F0E1C7', fontSize: 23, fontWeight: '500', marginTop: 4 }, seeAll: { flexDirection: 'row', alignItems: 'center', gap: 2, paddingBottom: 2 }, seeAllText: { color: '#CDA65A', fontSize: 11, fontWeight: '600' }, filterRow: { gap: 8, paddingBottom: 16 }, filterPill: { borderRadius: 16, borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 14, paddingVertical: 8 }, filterPillActive: { backgroundColor: '#B88542', borderColor: '#D4AD5D' }, filterText: { color: '#A99588', fontSize: 11 }, filterTextActive: { color: '#261A17', fontWeight: '700' },
  roomRail: { gap: 12 }, roomCard: { width: 192, height: 245, borderRadius: 17, overflow: 'hidden', backgroundColor: '#231A1D', borderWidth: 1, borderColor: '#47312A' }, roomImage: { width: '100%', height: '100%', resizeMode: 'cover' }, roomShade: { position: 'absolute', left: 0, right: 0, bottom: 0, height: '62%' }, liveBadge: { position: 'absolute', top: 12, left: 12, flexDirection: 'row', gap: 5, alignItems: 'center', backgroundColor: 'rgba(36,20,21,0.82)', borderRadius: 12, paddingHorizontal: 8, paddingVertical: 5 }, liveDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#E9B75C' }, liveText: { color: '#F4D990', fontSize: 9, letterSpacing: 1, fontWeight: '800' }, roomCardBottom: { position: 'absolute', left: 13, right: 11, bottom: 13 }, roomTitle: { color: '#FFF2DA', fontSize: 16, fontWeight: '600' }, roomMeta: { flexDirection: 'row', alignItems: 'center', gap: 5, marginTop: 7 }, roomHost: { color: '#D5B990', fontSize: 10, flexShrink: 1 }, metaDivider: { width: 2, height: 2, borderRadius: 1, backgroundColor: '#9A7D6E' }, viewerText: { color: '#E1CFAD', fontSize: 10 },
  spotlightCard: { marginTop: 28, minHeight: 178, borderRadius: 20, overflow: 'hidden', borderWidth: 1, borderColor: '#55402D', flexDirection: 'row' }, spotlightCopy: { flex: 1, padding: 18, zIndex: 1 }, spotlightTag: { flexDirection: 'row', alignItems: 'center', gap: 5 }, spotlightTagText: { color: '#E2BC62', fontSize: 9, letterSpacing: 1.3, fontWeight: '800' }, spotlightTitle: { color: '#F8E7C3', fontSize: 25, lineHeight: 29, fontWeight: '500', marginTop: 13 }, spotlightSub: { color: '#BFA797', fontSize: 11, lineHeight: 16, marginTop: 8, maxWidth: 175 }, primaryButton: { marginTop: 14, alignSelf: 'flex-start', flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: '#DDB65F', borderRadius: 17, paddingHorizontal: 13, paddingVertical: 8 }, primaryButtonText: { color: '#2C1B17', fontSize: 10, fontWeight: '800' }, spotlightArt: { width: 125, alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(162,111,48,0.14)' }, artRing: { position: 'absolute', width: 110, height: 110, borderRadius: 55, borderWidth: 1, borderColor: 'rgba(220,177,84,0.33)' }, artRingSmall: { position: 'absolute', width: 78, height: 78, borderRadius: 39, borderWidth: 1, borderColor: 'rgba(220,177,84,0.23)' },
  rankingCard: { backgroundColor: '#1A1417', borderRadius: 18, borderWidth: 1, borderColor: '#35272A', padding: 14 }, rankingTabs: { flexDirection: 'row', alignItems: 'center', gap: 19, borderBottomWidth: 1, borderBottomColor: '#2F2426', paddingBottom: 13, marginBottom: 4 }, rankingTabActive: { color: '#E0BB63', fontSize: 11, fontWeight: '800' }, rankingTab: { color: '#88776F', fontSize: 11 }, rankingPeriod: { marginLeft: 'auto', flexDirection: 'row', alignItems: 'center', gap: 1 }, rankingPeriodText: { color: '#9D887B', fontSize: 10 }, rankingRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10 }, rankNumber: { width: 25, alignItems: 'center' }, rankNumberFirst: { backgroundColor: '#4D3425', borderRadius: 10, paddingVertical: 4 }, rankText: { color: '#BBA89A', fontSize: 11, fontWeight: '700' }, avatar: { width: 39, height: 39, borderRadius: 20, borderWidth: 1, borderColor: '#B68A44' }, personCopy: { marginLeft: 10, flex: 1 }, personName: { color: '#EADAC0', fontSize: 12, fontWeight: '600' }, personCountry: { color: '#927D74', fontSize: 10, marginTop: 3 }, powerValue: { flexDirection: 'row', alignItems: 'center', gap: 5 }, powerText: { color: '#DCC17B', fontSize: 11, fontWeight: '700' },
  bottomBar: { position: 'absolute', left: 0, right: 0, bottom: 0, height: 82, backgroundColor: '#171114', borderTopWidth: 1, borderTopColor: '#312529', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-around', paddingHorizontal: 12 }, navItem: { width: 62, alignItems: 'center', gap: 5 }, navLabel: { color: '#756965', fontSize: 9 }, createButton: { width: 54, height: 54, borderRadius: 27, marginTop: -24, padding: 4, backgroundColor: '#171114', borderWidth: 1, borderColor: '#886232' }, createButtonGradient: { flex: 1, borderRadius: 25, alignItems: 'center', justifyContent: 'center' },
  modalBackdrop: { flex: 1, backgroundColor: 'rgba(8,5,6,0.8)', justifyContent: 'flex-end' }, roomModal: { maxHeight: '90%', backgroundColor: '#1B1417', borderTopLeftRadius: 28, borderTopRightRadius: 28, overflow: 'hidden', borderWidth: 1, borderColor: '#6A4D35' }, closeButton: { position: 'absolute', top: 15, right: 16, zIndex: 2, width: 34, height: 34, borderRadius: 18, backgroundColor: 'rgba(16,11,12,0.65)', alignItems: 'center', justifyContent: 'center' }, modalImage: { width: '100%', height: 250, resizeMode: 'cover' }, modalImageShade: { position: 'absolute', top: 0, left: 0, right: 0, height: 250, backgroundColor: 'rgba(20,12,12,0.18)' }, modalContent: { padding: 20 }, modalTitle: { color: '#F5E4C4', fontSize: 26, fontWeight: '500', marginTop: 12 }, modalHost: { color: '#AF9788', fontSize: 12, marginTop: 5 }, modalStats: { flexDirection: 'row', gap: 35, marginTop: 20 }, modalStatValue: { color: '#E2BC62', fontSize: 17, fontWeight: '700' }, modalStatLabel: { color: '#8E7970', fontSize: 10, marginTop: 3 }, joinButton: { height: 48, backgroundColor: '#DDB65F', borderRadius: 15, marginTop: 22, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: 8 }, joinButtonText: { color: '#2C1B17', fontWeight: '800', fontSize: 13 },

  secondaryContent: { paddingHorizontal: 20, paddingTop: 24, paddingBottom: 112 }, secondaryHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', paddingBottom: 20 }, secondaryTitle: { color: '#F0E1C7', fontSize: 32, fontWeight: '500', marginTop: 7 }, secondarySubtitle: { color: '#9D887B', fontSize: 12, marginTop: 6 }, secondaryIcon: { width: 45, height: 45, borderRadius: 23, borderWidth: 1, borderColor: '#5A402D', backgroundColor: '#241A1C', alignItems: 'center', justifyContent: 'center' }, searchBar: { height: 48, borderRadius: 15, borderWidth: 1, borderColor: '#3C2C2C', backgroundColor: '#191315', flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 15 }, searchPlaceholder: { color: '#816F67', fontSize: 12 }, secondarySectionTitle: { color: '#EADAC0', fontSize: 18, fontWeight: '600', marginTop: 28, marginBottom: 14 }, discoverCopy: { flex: 1, marginLeft: 12 }, discoverTitle: { color: '#EADAC0', fontSize: 14, fontWeight: '600', marginTop: 5 }, discoverMeta: { color: '#927D74', fontSize: 10, marginTop: 4 }, messageCard: { flexDirection: 'row', alignItems: 'center', padding: 15, borderRadius: 17, backgroundColor: '#21181B', borderWidth: 1, borderColor: '#4B342C' }, messageOrb: { width: 43, height: 43, borderRadius: 22, backgroundColor: '#4A3227', alignItems: 'center', justifyContent: 'center' }, messageCopy: { flex: 1, marginLeft: 12 }, messageTitle: { color: '#EADAC0', fontSize: 13, fontWeight: '600' }, messagePreview: { color: '#978279', fontSize: 10, marginTop: 5 }, messageTime: { color: '#CFA956', fontSize: 9, fontWeight: '700' }, connectionRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 11, borderBottomWidth: 1, borderBottomColor: '#2D2224' }, connectionImage: { width: 45, height: 45, borderRadius: 23, borderWidth: 1, borderColor: '#B68A44' }, followButton: { borderRadius: 14, borderWidth: 1, borderColor: '#9B713B', paddingHorizontal: 11, paddingVertical: 7 }, followText: { color: '#DDB65F', fontSize: 10, fontWeight: '700' }, profileHero: { flexDirection: 'row', alignItems: 'center', padding: 17, borderRadius: 19, backgroundColor: '#21181B', borderWidth: 1, borderColor: '#4B342C' }, profileImage: { width: 70, height: 70, borderRadius: 35, borderWidth: 2, borderColor: '#DDB65F' }, profileIdentity: { flex: 1, marginLeft: 13 }, profileName: { color: '#F3E0BF', fontSize: 18, fontWeight: '600' }, profileHandle: { color: '#9D887B', fontSize: 11, marginTop: 4 }, profileBadge: { flexDirection: 'row', alignItems: 'center', gap: 4, alignSelf: 'flex-start', backgroundColor: '#DDB65F', borderRadius: 10, paddingHorizontal: 7, paddingVertical: 4, marginTop: 8 }, profileBadgeText: { color: '#2B1B17', fontSize: 8, fontWeight: '800', letterSpacing: 0.7 }, editButton: { borderRadius: 13, borderWidth: 1, borderColor: '#765434', paddingHorizontal: 11, paddingVertical: 7, alignSelf: 'flex-start' }, editButtonText: { color: '#DDB65F', fontSize: 10, fontWeight: '700' }, profileStats: { flexDirection: 'row', justifyContent: 'space-around', paddingVertical: 23, borderBottomWidth: 1, borderBottomColor: '#2D2224' }, profileStatValue: { color: '#E1BA5C', fontSize: 18, fontWeight: '700', textAlign: 'center' }, profileStatLabel: { color: '#927D74', fontSize: 10, marginTop: 5, textAlign: 'center' }, menuCard: { marginTop: 25, borderRadius: 18, backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#35272A', paddingHorizontal: 14 }, menuRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 15, borderBottomWidth: 1, borderBottomColor: '#2D2224' }, menuIcon: { width: 31, height: 31, borderRadius: 16, backgroundColor: '#3E2A24', alignItems: 'center', justifyContent: 'center' }, menuText: { flex: 1, color: '#D9C6AA', fontSize: 12, marginLeft: 11 },

  discoverFilterRow: { gap: 8, paddingVertical: 18 }, discoverFilterPill: { flexDirection: 'row', alignItems: 'center', gap: 6, borderRadius: 16, borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 13, paddingVertical: 8 }, discoverFilterText: { color: '#A99588', fontSize: 11, fontWeight: '600' },
  discoverSectionTitle: { color: '#F0E1C7', fontSize: 20, fontWeight: '600', marginTop: 8, marginBottom: 4 }, discoverSectionSub: { color: '#8E786D', fontSize: 11, marginBottom: 16 },

  momentCard: { borderRadius: 18, backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#2E2326', marginBottom: 16, overflow: 'hidden' }, momentHeader: { flexDirection: 'row', alignItems: 'center', padding: 13 }, momentAvatar: { width: 38, height: 38, borderRadius: 19, borderWidth: 1, borderColor: '#5BC8A9' }, momentAuthor: { color: '#EADAC0', fontSize: 13, fontWeight: '600' }, momentTime: { color: '#7D706A', fontSize: 10, marginTop: 2 }, momentMore: { width: 34, height: 34, borderRadius: 17, alignItems: 'center', justifyContent: 'center' }, momentImage: { width: '100%', height: 220, resizeMode: 'cover' }, momentActions: { paddingHorizontal: 13, paddingTop: 11 }, momentActionRow: { flexDirection: 'row', gap: 20 }, momentAction: { flexDirection: 'row', alignItems: 'center', gap: 6 }, momentActionText: { color: '#A99588', fontSize: 12, fontWeight: '600' }, momentCaption: { color: '#C8B79E', fontSize: 12, lineHeight: 17, paddingHorizontal: 13, paddingBottom: 14 },

  discoverRoomCard: { height: 154, borderRadius: 18, overflow: 'hidden', backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#2E2326', marginBottom: 12 }, discoverRoomImage: { width: '100%', height: '100%', resizeMode: 'cover' }, discoverRoomShade: { position: 'absolute', left: 0, right: 0, bottom: 0, height: '74%' }, discoverRoomLive: { position: 'absolute', top: 12, left: 12, flexDirection: 'row', alignItems: 'center', gap: 5, backgroundColor: 'rgba(15,10,12,0.76)', borderRadius: 10, paddingHorizontal: 8, paddingVertical: 5 }, discoverRoomCopy: { position: 'absolute', left: 14, bottom: 14, right: 90 }, discoverRoomTitle: { color: '#FFF2DA', fontSize: 16, fontWeight: '600' }, discoverRoomMeta: { color: '#D5B990', fontSize: 10, marginTop: 5 }, enterRoomButton: { position: 'absolute', right: 13, bottom: 13, flexDirection: 'row', alignItems: 'center', gap: 5, borderRadius: 14, backgroundColor: '#5BC8A9', paddingHorizontal: 11, paddingVertical: 8 }, enterRoomText: { color: '#1B1417', fontSize: 10, fontWeight: '800' }, tournamentIcon: { width: 44, height: 44, borderRadius: 22, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: '#3D2D2A' }, tournamentTitle: { color: '#EADAC0', fontSize: 15, fontWeight: '600' }, tournamentMeta: { color: '#927D74', fontSize: 10, marginTop: 4 }, tournamentActions: { flexDirection: 'row', gap: 9, marginTop: 14 }, actionBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, borderRadius: 13, borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 13, paddingVertical: 8 }, actionBtnText: { fontSize: 11, fontWeight: '700' }, saveBtn: { flexDirection: 'row', alignItems: 'center', gap: 5, borderRadius: 13, borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 12, paddingVertical: 8 }, saveBtnText: { fontSize: 11, fontWeight: '600' },

  eventCard: { borderRadius: 19, backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#2E2326', marginBottom: 16, overflow: 'hidden' }, eventImage: { width: '100%', height: 160, resizeMode: 'cover' }, eventShade: { position: 'absolute', top: 0, left: 0, right: 0, height: 160 }, eventContent: { padding: 15 }, eventDateBadge: { flexDirection: 'row', alignItems: 'center', gap: 6, alignSelf: 'flex-start', borderRadius: 10, backgroundColor: '#9D7BE022', paddingHorizontal: 9, paddingVertical: 5 }, eventDateText: { color: '#9D7BE0', fontSize: 10, fontWeight: '700' }, eventTitle: { color: '#F0E1C7', fontSize: 18, fontWeight: '600', marginTop: 10 }, eventDesc: { color: '#A99588', fontSize: 11, lineHeight: 16, marginTop: 7 }, eventFooter: { marginTop: 10 }, eventAttendees: { flexDirection: 'row', alignItems: 'center', gap: 6 }, eventAttendeesText: { color: '#9D7BE0', fontSize: 11, fontWeight: '600' },

  gamesGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 }, gameCard: { width: '47%', flexGrow: 1, borderRadius: 16, backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#2E2326', overflow: 'hidden' }, gameImage: { width: '100%', height: 110, resizeMode: 'cover' }, gameShade: { position: 'absolute', top: 0, left: 0, right: 0, height: 110 }, hotBadge: { position: 'absolute', top: 9, right: 9, flexDirection: 'row', alignItems: 'center', gap: 3, borderRadius: 8, backgroundColor: 'rgba(15,10,12,0.82)', paddingHorizontal: 7, paddingVertical: 4 }, hotBadgeText: { color: '#E07B95', fontSize: 8, fontWeight: '800' }, gameContent: { padding: 12 }, gameTitle: { color: '#EADAC0', fontSize: 13, fontWeight: '600' }, gameDesc: { color: '#927D74', fontSize: 10, lineHeight: 14, marginTop: 5 }, gameMetaRow: { flexDirection: 'row', alignItems: 'center', gap: 7, marginTop: 7 }, gameFreeTag: { color: '#5BC8A9', fontSize: 9, fontWeight: '800', letterSpacing: 0.8 }, gamePlayers: { color: '#7D706A', fontSize: 10 }, gameJackpot: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 9, paddingTop: 9, borderTopWidth: 1, borderTopColor: '#2D2224' }, gameJackpotLabel: { color: '#8E786D', fontSize: 9 }, gameJackpotValue: { color: '#5BC8A9', fontSize: 13, fontWeight: '700' },
  freePlayBanner: { flexDirection: 'row', alignItems: 'center', gap: 10, borderRadius: 14, borderWidth: 1, borderColor: '#5BC8A933', backgroundColor: '#5BC8A90D', paddingHorizontal: 14, paddingVertical: 11, marginBottom: 16 }, freePlayText: { color: '#5BC8A9', fontSize: 11, flex: 1, lineHeight: 16 },
  levelPillFrame: { borderRadius: 10, borderWidth: 1, borderColor: 'transparent', shadowOpacity: 0, shadowRadius: 5, shadowOffset: { width: 0, height: 2 }, elevation: 2 }, levelPill: { minWidth: 34, height: 19, borderRadius: 8, paddingHorizontal: 7, flexDirection: 'row', gap: 3, alignItems: 'center', justifyContent: 'center' }, levelPillOrnate: { height: 21, borderRadius: 9, paddingHorizontal: 8 }, levelPillText: { color: '#FFFFFF', fontSize: 11, fontWeight: '800', textShadowColor: 'rgba(0,0,0,0.35)', textShadowOffset: { width: 0, height: 1 }, textShadowRadius: 2 },
  profileSubTabs: { flexDirection: 'row', gap: 10, marginTop: 20 }, profileSubTab: { flex: 1, alignItems: 'center', paddingVertical: 11, borderRadius: 14, borderWidth: 1, borderColor: '#3D2D2A' }, profileSubTabActive: { backgroundColor: '#DDB65F22', borderColor: '#DDB65F' }, profileSubTabText: { color: '#927D74', fontSize: 12, fontWeight: '700' }, profileSubTabTextActive: { color: '#DDB65F' },
  diamondBalance: { flexDirection: 'row', alignItems: 'center', gap: 6 }, diamondBalanceText: { color: '#A8C0F0', fontSize: 12, fontWeight: '600' },
  levelTierInfo: { marginTop: 20, borderRadius: 16, backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#35272A', padding: 16 }, levelTierTitle: { color: '#F0E1C7', fontSize: 14, fontWeight: '600' }, levelTierDesc: { color: '#927D74', fontSize: 11, lineHeight: 17, marginTop: 8 },
  profileLevelRow: { flexDirection: 'row', gap: 6, marginTop: 8 },
  profileLevelDetail: { flexDirection: 'row', gap: 12, marginTop: 18 }, levelDetailCard: { flex: 1, borderRadius: 16, backgroundColor: '#1A1417', borderWidth: 1, borderColor: '#35272A', padding: 14 }, levelDetailHeader: { flexDirection: 'row', alignItems: 'center', gap: 6 }, levelDetailTitle: { color: '#DDB65F', fontSize: 11, fontWeight: '700' }, levelDetailValue: { color: '#F0E1C7', fontSize: 22, fontWeight: '700', marginTop: 8 }, levelProgressTrack: { height: 6, borderRadius: 3, backgroundColor: '#2D2224', overflow: 'hidden', marginTop: 10 }, levelProgressBar: { height: '100%', borderRadius: 3 }, levelProgressLabel: { color: '#7D706A', fontSize: 9, marginTop: 6 },

  luckyGiftWrap: { marginTop: 20, borderTopWidth: 1, borderTopColor: '#35272A', paddingTop: 16 }, luckyGiftHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }, luckyGiftTitleRow: { flexDirection: 'row', alignItems: 'center', gap: 6 }, luckyGiftTitle: { color: '#F0E1C7', fontSize: 15, fontWeight: '600' }, luckyGiftInfo: { borderRadius: 8, backgroundColor: '#E8956A1A', paddingHorizontal: 8, paddingVertical: 4 }, luckyGiftInfoText: { color: '#E8956A', fontSize: 9, fontWeight: '600' }, luckyGiftRow: { gap: 9, paddingBottom: 4 }, luckyGiftItem: { width: 68, alignItems: 'center', borderRadius: 13, borderWidth: 1, borderColor: '#3D2D2A', backgroundColor: '#211719', paddingVertical: 10 }, luckyGiftItemSelected: { borderColor: '#E8956A', backgroundColor: '#E8956A1A' }, luckyGiftEmoji: { fontSize: 28 }, luckyGiftName: { color: '#C8B79E', fontSize: 10, fontWeight: '600', marginTop: 4 }, luckyGiftPriceRow: { flexDirection: 'row', alignItems: 'center', gap: 3, marginTop: 4 }, luckyGiftPrice: { color: '#DDB65F', fontSize: 9, fontWeight: '700' }, luckyGiftMultBadge: { marginTop: 5, borderRadius: 5, backgroundColor: '#E8956A33', paddingHorizontal: 5, paddingVertical: 2 }, luckyGiftMultText: { color: '#E8956A', fontSize: 8, fontWeight: '800' },
  luckyGiftConfigSection: { marginTop: 14, borderRadius: 14, backgroundColor: '#211719', borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 14, paddingVertical: 12 }, luckyGiftConfigLabel: { color: '#927D74', fontSize: 10, fontWeight: '700', letterSpacing: 0.5, marginTop: 10, marginBottom: 4 }, luckyGiftConfigValue: { color: '#F0E1C7', fontSize: 16, fontWeight: '700' }, luckyGiftTierLabel: { color: '#E8956A', fontSize: 9, fontWeight: '600', marginTop: 3 }, luckyGiftErrorText: { color: '#E07B95', fontSize: 9, fontWeight: '600', marginTop: 4 }, luckyGiftInput: { color: '#F0E1C7', fontSize: 13, borderWidth: 1, borderColor: '#3D2D2A', borderRadius: 10, paddingHorizontal: 12, paddingVertical: 9, marginTop: 2 }, luckyGiftManualInput: { color: '#927D74', fontSize: 11, fontWeight: '700', paddingHorizontal: 4, paddingVertical: 0, minWidth: 50 }, luckyGiftMultGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginTop: 4 }, luckyGiftMultChip: { borderRadius: 7, borderWidth: 1, borderColor: '#3D2D2A', backgroundColor: '#191315', paddingHorizontal: 8, paddingVertical: 4 }, luckyGiftMultChipText: { color: '#927D74', fontSize: 10, fontWeight: '700' }, luckyGiftQtyRow: { gap: 7, paddingBottom: 2 }, luckyGiftQtyPill: { borderRadius: 11, borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 10, paddingVertical: 6 }, luckyGiftQtyPillActive: { backgroundColor: '#E8956A22', borderColor: '#E8956A' }, luckyGiftQtyText: { color: '#927D74', fontSize: 11, fontWeight: '700' }, luckyGiftQtyTextActive: { color: '#E8956A' }, luckyGiftRecipientRow: { flexDirection: 'row', alignItems: 'center', gap: 14 }, luckyGiftRecipientBtn: { width: 32, height: 32, borderRadius: 16, borderWidth: 1, borderColor: '#3D2D2A', backgroundColor: '#191315', alignItems: 'center', justifyContent: 'center' }, luckyGiftRecipientBtnText: { color: '#C8B79E', fontSize: 18, fontWeight: '700' }, luckyGiftRecipientCount: { color: '#F0E1C7', fontSize: 18, fontWeight: '700' }, luckyGiftSummary: { marginTop: 14, borderTopWidth: 1, borderTopColor: '#2D2224', paddingTop: 12 }, luckyGiftSummaryRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 }, luckyGiftSummaryLabel: { color: '#927D74', fontSize: 11 }, luckyGiftSummaryValue: { color: '#DDB65F', fontSize: 11, fontWeight: '700' }, luckyGiftSendBar: { marginTop: 14, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', borderRadius: 14, backgroundColor: '#211719', borderWidth: 1, borderColor: '#3D2D2A', paddingHorizontal: 14, paddingVertical: 10 }, luckyGiftSendName: { color: '#EADAC0', fontSize: 13, fontWeight: '600' }, luckyGiftSendDesc: { color: '#927D74', fontSize: 10, marginTop: 3 }, luckyGiftSendBtn: { flexDirection: 'row', alignItems: 'center', gap: 6, borderRadius: 14, backgroundColor: '#E8956A', paddingHorizontal: 14, paddingVertical: 9, marginTop: 12, justifyContent: 'center' }, luckyGiftSendBtnDisabled: { backgroundColor: '#2D2224' }, luckyGiftSendBtnText: { color: '#1B1417', fontSize: 12, fontWeight: '800' }, luckyGiftSendBtnTextDisabled: { color: '#5A4A44' }, luckyGiftDemoNote: { color: '#7D706A', fontSize: 9, marginTop: 8, textAlign: 'center' },

  createBackdrop: { flex: 1, backgroundColor: 'rgba(8,5,6,0.85)', justifyContent: 'flex-end' }, createSheet: { backgroundColor: '#1B1417', borderTopLeftRadius: 28, borderTopRightRadius: 28, borderWidth: 1, borderColor: '#3D2C27', paddingHorizontal: 20, paddingBottom: 34, paddingTop: 12 }, createHandle: { width: 38, height: 4, borderRadius: 2, backgroundColor: '#3D2C27', alignSelf: 'center', marginBottom: 18 }, createTitle: { color: '#F0E1C7', fontSize: 24, fontWeight: '600' }, createSubtitle: { color: '#9D887B', fontSize: 12, marginTop: 5, marginBottom: 22 }, createOption: { flexDirection: 'row', alignItems: 'center', paddingVertical: 15, borderBottomWidth: 1, borderBottomColor: '#2D2224', gap: 13 }, createOptionIcon: { width: 46, height: 46, borderRadius: 23, alignItems: 'center', justifyContent: 'center', borderWidth: 1 }, createOptionLabel: { color: '#EADAC0', fontSize: 15, fontWeight: '600' }, createOptionDesc: { color: '#927D74', fontSize: 11, marginTop: 3 },
});
