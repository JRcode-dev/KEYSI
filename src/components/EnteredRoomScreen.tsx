import { useState } from 'react';
import { Image, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ArrowLeft, Gift as GiftIcon, Mic2, Users, Volume2 } from 'lucide-react-native';

import type { Room } from '@/src/types';
import { formatCoins } from '@/src/utils/format';
import { GiftCatalogSheet } from '@/src/components/GiftCatalogSheet';

export function EnteredRoomScreen({ room, onLeave }: { room: Room; onLeave: () => void }) {
  const [giftCatalogOpen, setGiftCatalogOpen] = useState(false);
  const occupiedSeats = room.seats.filter((seat) => seat.userId !== null).length;

  return (
    <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
      <View style={styles.screen}>
        <View style={styles.header}>
          <Pressable onPress={onLeave} style={styles.iconButton} accessibilityLabel="Leave room">
            <ArrowLeft color="#E8D9C0" size={19} />
          </Pressable>
          <View style={styles.headerCopy}>
            <Text style={styles.headerEyebrow}>LIVE ROOM · DEMO</Text>
            <Text style={styles.headerTitle} numberOfLines={1}>{room.name}</Text>
          </View>
          <View style={styles.liveBadge}><View style={styles.liveDot} /><Text style={styles.liveText}>LIVE</Text></View>
        </View>

        <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
          <View style={styles.roomHero}>
            {room.coverUrl && <Image source={{ uri: room.coverUrl }} style={StyleSheet.absoluteFill} />}
            <LinearGradient
              colors={['rgba(22,14,17,0.12)', 'rgba(22,14,17,0.96)']}
              style={StyleSheet.absoluteFill}
            />
            <Text style={styles.heroEyebrow}>HOSTED BY</Text>
            <Text style={styles.heroHost}>{room.ownerUsername}</Text>
            <Text style={styles.heroDescription}>{room.description ?? 'Join the conversation.'}</Text>
          </View>

          <View style={styles.statsRow}>
            <RoomStat icon={<Users color="#DDB65F" size={15} />} value={formatCoins(room.viewerCount)} label="listeners" />
            <RoomStat icon={<Mic2 color="#5BC8A9" size={15} />} value={String(occupiedSeats)} label="on stage" />
            <RoomStat icon={<Volume2 color="#9D7BE0" size={15} />} value={String(room.maxSeats)} label="seats" />
          </View>

          <View style={styles.sectionHeading}>
            <View>
              <Text style={styles.sectionEyebrow}>THE STAGE</Text>
              <Text style={styles.sectionTitle}>Room seats</Text>
            </View>
            <Text style={styles.seatCount}>{occupiedSeats}/{room.maxSeats}</Text>
          </View>

          <View style={styles.seatGrid}>
            {room.seats.map((seat) => (
              <View key={seat.seatNumber} style={[styles.seatCard, seat.userId === null && styles.emptySeatCard]}>
                {seat.avatarUrl ? (
                  <Image source={{ uri: seat.avatarUrl }} style={styles.seatAvatar} />
                ) : (
                  <View style={styles.emptySeatAvatar}><Mic2 color="#665650" size={18} /></View>
                )}
                <Text style={styles.seatName} numberOfLines={1}>{seat.username ?? `Seat ${seat.seatNumber}`}</Text>
                <Text style={styles.seatRole}>{seat.username ? seat.role.toLowerCase() : 'available'}</Text>
              </View>
            ))}
          </View>

          <View style={styles.chatPlaceholder}>
            <Text style={styles.chatTitle}>Room conversation</Text>
            <Text style={styles.chatCopy}>Live chat and voice are not connected in this demo.</Text>
          </View>
        </ScrollView>

        <View style={styles.footer}>
          <Text style={styles.footerNote}>Demo room · no live connection</Text>
          <Pressable onPress={() => setGiftCatalogOpen(true)} style={styles.giftsButton}>
            <GiftIcon color="#251815" size={17} />
            <Text style={styles.giftsButtonText}>Gifts</Text>
          </Pressable>
        </View>

        {giftCatalogOpen && <GiftCatalogSheet onClose={() => setGiftCatalogOpen(false)} />}
      </View>
    </SafeAreaView>
  );
}

function RoomStat({ icon, value, label }: { icon: React.ReactNode; value: string; label: string }) {
  return (
    <View style={styles.stat}>
      {icon}
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: '#100D0F' },
  screen: { flex: 1, backgroundColor: '#100D0F' },
  header: { height: 63, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 17, gap: 12, borderBottomWidth: 1, borderBottomColor: '#2B2123' },
  iconButton: { width: 37, height: 37, borderRadius: 19, backgroundColor: '#21191C', alignItems: 'center', justifyContent: 'center' },
  headerCopy: { flex: 1, minWidth: 0 },
  headerEyebrow: { color: '#9D887B', fontSize: 8, letterSpacing: 1.4, fontWeight: '800' },
  headerTitle: { color: '#F0E1C7', fontSize: 14, fontWeight: '700', marginTop: 3 },
  liveBadge: { flexDirection: 'row', alignItems: 'center', gap: 5, borderRadius: 10, backgroundColor: '#E9B75C18', paddingHorizontal: 9, paddingVertical: 6 },
  liveDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#E9B75C' },
  liveText: { color: '#F4D990', fontSize: 8, fontWeight: '800', letterSpacing: 0.8 },
  content: { paddingHorizontal: 18, paddingTop: 16, paddingBottom: 25 },
  roomHero: { height: 165, borderRadius: 20, overflow: 'hidden', justifyContent: 'flex-end', padding: 17, backgroundColor: '#342328' },
  heroEyebrow: { color: '#DDB65F', fontSize: 8, letterSpacing: 1.4, fontWeight: '800' },
  heroHost: { color: '#FFF0D5', fontSize: 23, fontWeight: '600', marginTop: 4 },
  heroDescription: { color: '#D1BDA6', fontSize: 11, marginTop: 5 },
  statsRow: { flexDirection: 'row', justifyContent: 'space-between', borderRadius: 17, borderWidth: 1, borderColor: '#35272A', backgroundColor: '#191416', paddingVertical: 13, paddingHorizontal: 15, marginTop: 13 },
  stat: { minWidth: 80, alignItems: 'center', gap: 4 },
  statValue: { color: '#F0E1C7', fontSize: 13, fontWeight: '700' },
  statLabel: { color: '#8E7970', fontSize: 9 },
  sectionHeading: { flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between', marginTop: 24, marginBottom: 12 },
  sectionEyebrow: { color: '#9D887B', fontSize: 8, letterSpacing: 1.3, fontWeight: '700' },
  sectionTitle: { color: '#F0E1C7', fontSize: 19, fontWeight: '600', marginTop: 4 },
  seatCount: { color: '#DDB65F', fontSize: 11, fontWeight: '700', paddingBottom: 2 },
  seatGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 9 },
  seatCard: { width: '31.5%', minHeight: 105, borderRadius: 14, borderWidth: 1, borderColor: '#4A342B', backgroundColor: '#21191C', alignItems: 'center', justifyContent: 'center', paddingHorizontal: 8, paddingVertical: 11 },
  emptySeatCard: { borderColor: '#34272A', backgroundColor: '#181416' },
  seatAvatar: { width: 42, height: 42, borderRadius: 21, borderWidth: 1, borderColor: '#DDB65F' },
  emptySeatAvatar: { width: 42, height: 42, borderRadius: 21, borderWidth: 1, borderStyle: 'dashed', borderColor: '#534347', alignItems: 'center', justifyContent: 'center' },
  seatName: { maxWidth: '100%', color: '#E5D5B6', fontSize: 9, fontWeight: '700', marginTop: 7 },
  seatRole: { color: '#8E7970', fontSize: 8, marginTop: 3, textTransform: 'capitalize' },
  chatPlaceholder: { marginTop: 18, minHeight: 95, borderRadius: 15, borderWidth: 1, borderColor: '#33272A', backgroundColor: '#191416', padding: 15, justifyContent: 'center' },
  chatTitle: { color: '#D8C6AA', fontSize: 12, fontWeight: '700' },
  chatCopy: { color: '#8E7970', fontSize: 10, lineHeight: 15, marginTop: 5 },
  footer: { minHeight: 67, borderTopWidth: 1, borderTopColor: '#302427', backgroundColor: '#171214', paddingHorizontal: 18, paddingVertical: 10, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 12 },
  footerNote: { color: '#8E7970', fontSize: 9, flex: 1 },
  giftsButton: { height: 43, borderRadius: 14, backgroundColor: '#DDB65F', paddingHorizontal: 19, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8 },
  giftsButtonText: { color: '#251815', fontSize: 12, fontWeight: '800' },
});
