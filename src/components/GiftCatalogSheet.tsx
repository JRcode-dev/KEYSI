import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { ChevronDown, Dice5, Gem, Gift as GiftIcon, Minus, Plus, X } from 'lucide-react-native';

import {
  LUCKY_GIFT_MAX_VALUE,
  LUCKY_GIFT_MIN_VALUE,
  LUCKY_GIFT_QUANTITIES,
  LUCKY_GIFT_DIAMOND_RATE,
} from '@/src/config/keysi';
import { formatNumber } from '@/src/utils/format';
import { giftCatalog, luckyGifts, normalGifts, type GiftCatalogItem, type GiftCatalogType } from '@/src/data/giftCatalog';

const backendConnected = false;

export function GiftCatalogSheet({ onClose }: { onClose: () => void }) {
  const [activeTab, setActiveTab] = useState<GiftCatalogType>('normal');
  const [selectedGiftId, setSelectedGiftId] = useState<string | null>(null);
  const [giftValueInput, setGiftValueInput] = useState('');
  const [quantity, setQuantity] = useState<number>(1);
  const [manualQuantity, setManualQuantity] = useState('');
  const [usesManualQuantity, setUsesManualQuantity] = useState(false);
  const [quantityMenuOpen, setQuantityMenuOpen] = useState(false);
  const [recipientCount, setRecipientCount] = useState(1);

  const items = activeTab === 'normal' ? normalGifts : luckyGifts;
  const selectedGift = giftCatalog.find((gift) => gift.id === selectedGiftId) ?? null;
  const selectedLuckyGift = activeTab === 'lucky' && selectedGift?.type === 'lucky' ? selectedGift : null;
  const giftValue = giftValueInput === '' ? 0 : Number(giftValueInput);
  const quantityInput = usesManualQuantity ? manualQuantity : String(quantity);
  const quantityIsInteger = /^\d+$/.test(quantityInput);
  const quantityValue = quantityIsInteger ? BigInt(quantityInput) : BigInt(0);
  const giftValueIsValid =
    Number.isInteger(giftValue) &&
    giftValue >= LUCKY_GIFT_MIN_VALUE &&
    giftValue <= LUCKY_GIFT_MAX_VALUE;
  const totalCost = BigInt(giftValueIsValid ? giftValue : 0) * BigInt(recipientCount) * quantityValue;
  const diamondsPerRecipient =
    (BigInt(giftValueIsValid ? giftValue : 0) * quantityValue * BigInt(Math.round(LUCKY_GIFT_DIAMOND_RATE * 100)) + BigInt(50)) /
    BigInt(100);
  const luckyGiftIsValid =
    selectedLuckyGift !== null &&
    giftValueIsValid &&
    quantityIsInteger &&
    quantityValue >= BigInt(1) &&
    recipientCount >= 1 &&
    totalCost > BigInt(0) &&
    diamondsPerRecipient >= BigInt(0);

  const setTab = (tab: GiftCatalogType) => {
    setActiveTab(tab);
    setSelectedGiftId(null);
    setQuantityMenuOpen(false);
    setGiftValueInput('');
  };

  const chooseQuantity = (value: number) => {
    setQuantity(value);
    setManualQuantity('');
    setUsesManualQuantity(false);
    setQuantityMenuOpen(false);
  };

  const chooseManualQuantity = () => {
    setUsesManualQuantity(true);
    setManualQuantity('');
    setQuantityMenuOpen(false);
  };

  return (
    <View style={styles.overlay}>
      <Pressable accessibilityLabel="Close gifts" style={styles.scrim} onPress={onClose} />
      <View style={styles.sheet}>
        <View style={styles.sheetHeader}>
          <View style={styles.sheetTitleRow}>
            <View style={styles.sheetIcon}><GiftIcon color="#E3BC5A" size={18} /></View>
            <View>
              <Text style={styles.sheetTitle}>Gifts</Text>
              <Text style={styles.sheetSubtitle}>Demo catalog · no transactions</Text>
            </View>
          </View>
          <Pressable onPress={onClose} accessibilityLabel="Close gifts" style={styles.closeButton}>
            <X color="#C8B79E" size={18} />
          </Pressable>
        </View>

        <Text style={styles.approvalNote}>
          Names are proposals. Artwork and approved prices are pending.
        </Text>

        <View style={styles.tabs}>
          <CatalogTab label="Normales" count={normalGifts.length} active={activeTab === 'normal'} onPress={() => setTab('normal')} />
          <CatalogTab label="Reembolso" count={luckyGifts.length} active={activeTab === 'lucky'} onPress={() => setTab('lucky')} />
        </View>

        <ScrollView
          style={styles.catalogScroll}
          contentContainerStyle={styles.catalogContent}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
        >
          {activeTab === 'lucky' && (
            <View style={styles.maxWinTag}>
              <Dice5 color="#E8956A" size={13} />
              <Text style={styles.maxWinText}>Win up to x1000</Text>
            </View>
          )}

          <View style={styles.giftGrid}>
            {items.map((gift) => (
              <GiftCard
                key={gift.id}
                gift={gift}
                selected={selectedGiftId === gift.id}
                onPress={() => setSelectedGiftId(gift.id)}
              />
            ))}
          </View>

          {activeTab === 'lucky' && (
            <View style={styles.luckySettings}>
              <View style={styles.settingsHeader}>
                <Gem color="#DDB65F" size={15} />
                <Text style={styles.settingsTitle}>{selectedLuckyGift?.name ?? 'Lucky Gift'}</Text>
              </View>
              <Text style={styles.settingsDescription}>
                Set the value for each send. This is demo input only.
              </Text>

              <Text style={styles.fieldLabel}>Custom value · {formatNumber(LUCKY_GIFT_MIN_VALUE)}–{formatNumber(LUCKY_GIFT_MAX_VALUE)} Coins</Text>
              <TextInput
                value={giftValueInput}
                onChangeText={(value) => setGiftValueInput(value.replace(/\D/g, '').slice(0, 6))}
                placeholder="Enter value"
                placeholderTextColor="#76655D"
                keyboardType="number-pad"
                style={styles.textInput}
                accessibilityLabel="Lucky Gift value in Coins"
              />
              {giftValueInput !== '' && !giftValueIsValid && (
                <Text style={styles.validationText}>
                  Enter a value from {formatNumber(LUCKY_GIFT_MIN_VALUE)} to {formatNumber(LUCKY_GIFT_MAX_VALUE)}.
                </Text>
              )}

              <Text style={styles.fieldLabel}>Quantity · each activation is separate</Text>
              <View style={styles.quantityControl}>
                <Pressable
                  style={styles.quantityTrigger}
                  onPress={() => setQuantityMenuOpen((open) => !open)}
                  accessibilityRole="button"
                  accessibilityLabel="Change quantity"
                  accessibilityState={{ expanded: quantityMenuOpen }}
                >
                  <Text style={styles.quantityTriggerText}>
                    {usesManualQuantity ? 'Manual' : `×${quantity}`}
                  </Text>
                  <ChevronDown color="#DDB65F" size={16} />
                </Pressable>
                {quantityMenuOpen && (
                  <View style={styles.quantityMenu}>
                    <Text style={styles.quantityMenuHeading}>Change quantity</Text>
                    {LUCKY_GIFT_QUANTITIES.map((value) => (
                      <Pressable key={value} style={styles.quantityOption} onPress={() => chooseQuantity(value)}>
                        <Text style={styles.quantityOptionText}>×{value}</Text>
                        {!usesManualQuantity && quantity === value && <Text style={styles.quantitySelected}>Selected</Text>}
                      </Pressable>
                    ))}
                    <Pressable style={styles.quantityOption} onPress={chooseManualQuantity}>
                      <Text style={styles.quantityOptionText}>Manual</Text>
                      {usesManualQuantity && <Text style={styles.quantitySelected}>Selected</Text>}
                    </Pressable>
                  </View>
                )}
              </View>
              {usesManualQuantity && (
                <>
                  <TextInput
                    value={manualQuantity}
                    onChangeText={(value) => setManualQuantity(value.replace(/\D/g, ''))}
                    placeholder="Enter a whole number"
                    placeholderTextColor="#76655D"
                    keyboardType="number-pad"
                    style={styles.textInput}
                    accessibilityLabel="Manual quantity"
                  />
                  {manualQuantity !== '' && quantityValue < BigInt(1) && (
                    <Text style={styles.validationText}>Quantity must be at least 1.</Text>
                  )}
                </>
              )}

              <Text style={styles.fieldLabel}>Recipients</Text>
              <View style={styles.recipientControl}>
                <Pressable
                  style={styles.recipientButton}
                  onPress={() => setRecipientCount((count) => Math.max(1, count - 1))}
                  accessibilityLabel="Remove recipient"
                >
                  <Minus color="#C8B79E" size={15} />
                </Pressable>
                <Text style={styles.recipientCount}>{recipientCount}</Text>
                <Pressable
                  style={styles.recipientButton}
                  onPress={() => setRecipientCount((count) => count + 1)}
                  accessibilityLabel="Add recipient"
                >
                  <Plus color="#C8B79E" size={15} />
                </Pressable>
              </View>

              <Pressable
                style={[styles.sendButton, (!luckyGiftIsValid || !backendConnected) && styles.sendButtonDisabled]}
                disabled={!luckyGiftIsValid || !backendConnected}
                accessibilityHint="Sending is unavailable because the backend is not connected."
              >
                <Text style={[styles.sendButtonText, (!luckyGiftIsValid || !backendConnected) && styles.sendButtonTextDisabled]}>
                  Send
                </Text>
              </Pressable>
              <Text style={styles.demoNote}>
                Sending is disabled. The frontend is not connected to the backend.
              </Text>
            </View>
          )}
        </ScrollView>
      </View>
    </View>
  );
}

function CatalogTab({
  label,
  count,
  active,
  onPress,
}: {
  label: string;
  count: number;
  active: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={[styles.tab, active && styles.tabActive]}
      accessibilityRole="tab"
      accessibilityState={{ selected: active }}
    >
      <Text style={[styles.tabText, active && styles.tabTextActive]}>{label}</Text>
      <Text style={[styles.tabCount, active && styles.tabCountActive]}>{count}</Text>
    </Pressable>
  );
}

function GiftCard({ gift, selected, onPress }: { gift: GiftCatalogItem; selected: boolean; onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={[styles.giftCard, selected && styles.giftCardSelected]}
      accessibilityRole="button"
      accessibilityState={{ selected }}
      accessibilityLabel={`${gift.name}, proposal pending approval, artwork pending`}
    >
      <View style={styles.artworkPlaceholder}>
        <GiftIcon color={gift.type === 'lucky' ? '#E8956A' : '#DDB65F'} size={22} strokeWidth={1.5} />
        <Text style={styles.artworkPlaceholderText}>Art pending</Text>
      </View>
      <Text style={styles.giftName} numberOfLines={1}>{gift.name}</Text>
      <Text style={styles.giftMeta} numberOfLines={1}>
        {gift.price === null ? (gift.type === 'normal' ? 'Price pending' : 'Value per send') : formatNumber(gift.price)}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  overlay: { ...StyleSheet.absoluteFill, zIndex: 20, justifyContent: 'flex-end' },
  scrim: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(7,5,6,0.78)' },
  sheet: {
    height: '88%',
    backgroundColor: '#1B1417',
    borderTopLeftRadius: 27,
    borderTopRightRadius: 27,
    borderWidth: 1,
    borderColor: '#5A402D',
    paddingTop: 13,
    paddingHorizontal: 17,
    overflow: 'hidden',
  },
  sheetHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  sheetTitleRow: { flexDirection: 'row', alignItems: 'center', gap: 11 },
  sheetIcon: { width: 38, height: 38, borderRadius: 14, backgroundColor: '#DDB65F1A', alignItems: 'center', justifyContent: 'center' },
  sheetTitle: { color: '#F0E1C7', fontSize: 19, fontWeight: '700' },
  sheetSubtitle: { color: '#8E7970', fontSize: 10, marginTop: 2 },
  closeButton: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center', backgroundColor: '#2A2022' },
  approvalNote: { color: '#A89589', fontSize: 10, lineHeight: 15, marginTop: 13, marginBottom: 11 },
  tabs: { flexDirection: 'row', gap: 9, borderBottomWidth: 1, borderBottomColor: '#33272A', paddingBottom: 10 },
  tab: { flex: 1, minHeight: 42, borderRadius: 13, borderWidth: 1, borderColor: '#3D2D2A', backgroundColor: '#21191C', flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8 },
  tabActive: { borderColor: '#DDB65F', backgroundColor: '#DDB65F18' },
  tabText: { color: '#A99588', fontSize: 12, fontWeight: '700' },
  tabTextActive: { color: '#E8C56D' },
  tabCount: { color: '#8E7970', fontSize: 10, fontWeight: '700' },
  tabCountActive: { color: '#DDB65F' },
  catalogScroll: { flex: 1 },
  catalogContent: { paddingTop: 12, paddingBottom: 34 },
  maxWinTag: { alignSelf: 'flex-start', flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: '#E8956A1A', borderWidth: 1, borderColor: '#E8956A44', borderRadius: 10, paddingHorizontal: 10, paddingVertical: 6, marginBottom: 12 },
  maxWinText: { color: '#E8956A', fontSize: 10, fontWeight: '800', letterSpacing: 0.2 },
  giftGrid: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', rowGap: 9 },
  giftCard: { width: '31.5%', minHeight: 113, padding: 7, borderRadius: 14, borderWidth: 1, borderColor: '#35282A', backgroundColor: '#21191C', alignItems: 'center' },
  giftCardSelected: { borderColor: '#DDB65F', backgroundColor: '#DDB65F12' },
  artworkPlaceholder: { width: '100%', height: 65, borderRadius: 10, backgroundColor: '#191315', alignItems: 'center', justifyContent: 'center', gap: 4 },
  artworkPlaceholderText: { color: '#76655D', fontSize: 8, fontWeight: '600' },
  giftName: { color: '#E5D5B6', fontSize: 10, fontWeight: '700', marginTop: 6, maxWidth: '100%' },
  giftMeta: { color: '#8E7970', fontSize: 8, marginTop: 3, maxWidth: '100%' },
  luckySettings: { marginTop: 17, borderRadius: 16, backgroundColor: '#21191C', borderWidth: 1, borderColor: '#3D2D2A', padding: 14 },
  settingsHeader: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  settingsTitle: { color: '#F0E1C7', fontSize: 14, fontWeight: '700' },
  settingsDescription: { color: '#8E7970', fontSize: 10, lineHeight: 15, marginTop: 5 },
  fieldLabel: { color: '#B8A391', fontSize: 10, fontWeight: '700', marginTop: 14, marginBottom: 6 },
  textInput: { height: 42, borderRadius: 11, borderWidth: 1, borderColor: '#403033', backgroundColor: '#181315', color: '#F0E1C7', paddingHorizontal: 12, fontSize: 12 },
  validationText: { color: '#E07B95', fontSize: 9, marginTop: 5 },
  quantityControl: { position: 'relative', zIndex: 3, alignSelf: 'flex-start', minWidth: 104 },
  quantityTrigger: { minHeight: 39, borderRadius: 11, borderWidth: 1, borderColor: '#59402D', backgroundColor: '#191315', paddingHorizontal: 12, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 14 },
  quantityTriggerText: { color: '#E8C56D', fontSize: 12, fontWeight: '800' },
  quantityMenu: { marginTop: 6, width: 158, borderRadius: 12, borderWidth: 1, borderColor: '#4A3530', backgroundColor: '#171214', padding: 6 },
  quantityMenuHeading: { color: '#9D887B', fontSize: 10, fontWeight: '700', paddingHorizontal: 9, paddingVertical: 7 },
  quantityOption: { minHeight: 34, borderRadius: 8, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 9 },
  quantityOptionText: { color: '#E3D0B0', fontSize: 11, fontWeight: '600' },
  quantitySelected: { color: '#DDB65F', fontSize: 8, fontWeight: '700' },
  recipientControl: { alignSelf: 'flex-start', flexDirection: 'row', alignItems: 'center', gap: 17 },
  recipientButton: { width: 32, height: 32, borderRadius: 16, borderWidth: 1, borderColor: '#403033', backgroundColor: '#191315', alignItems: 'center', justifyContent: 'center' },
  recipientCount: { minWidth: 18, color: '#F0E1C7', fontSize: 15, fontWeight: '700', textAlign: 'center' },
  sendButton: { minHeight: 43, borderRadius: 12, backgroundColor: '#DDB65F', alignItems: 'center', justifyContent: 'center', marginTop: 17 },
  sendButtonDisabled: { backgroundColor: '#392D27' },
  sendButtonText: { color: '#241815', fontSize: 12, fontWeight: '800' },
  sendButtonTextDisabled: { color: '#8E7970' },
  demoNote: { color: '#8E7970', fontSize: 9, textAlign: 'center', lineHeight: 14, marginTop: 8 },
});
