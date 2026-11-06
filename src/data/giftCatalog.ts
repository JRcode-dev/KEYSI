export type GiftCatalogType = 'normal' | 'lucky';

export interface GiftCatalogItem {
  id: string;
  name: string;
  type: GiftCatalogType;
  isDemo: true;
  nameApproval: 'pending';
  price: null;
  priceApproval: 'pending';
  imageFileName: null;
  imagePath: null;
  imageExists: false;
  imageType: 'static';
  imageStatus: 'pending';
  lottiePath: null;
  lottieExists: false;
  animationType: 'none';
}

const normalGiftNames = [
  'Rose',
  'Heart',
  'Star',
  'Kiss',
  'Hug',
  'Cake',
  'Crown',
  'Diamond',
  'Trophy',
  'Rocket',
  'Fireworks',
  'Rainbow',
  'Unicorn',
  'Dragon',
  'Galaxy',
  'Shooting Star',
  'Butterfly',
  'Phoenix',
  'Golden Lion',
  'Castle',
  'Spaceship',
  'Tornado',
  'Supernova',
  'King of the Universe',
  'Empire',
  'Legend',
  'God of Love',
  'Vivra VIP',
  'Master',
  'Vivra King',
] as const;

const luckyGiftNames = [
  'Lucky Spark',
  'Lucky Leaf',
  'Lucky Coin',
  'Lucky Star',
  'Lucky Heart',
  'Lucky Moon',
  'Lucky Sun',
  'Lucky Rose',
  'Lucky Candy',
  'Lucky Gem',
  'Lucky Bear',
  'Lucky Fox',
  'Lucky Owl',
  'Lucky Wolf',
  'Lucky Tiger',
  'Lucky Panda',
  'Lucky Lion',
  'Lucky Eagle',
  'Lucky Dragon',
  'Lucky Phoenix',
  'Lucky Unicorn',
  'Lucky Meteor',
  'Lucky Nova',
  'Lucky Aurora',
  'Lucky Thunder',
  'Lucky Galaxy',
  'Lucky Diamond',
  'Lucky Universe',
  'Lucky Legend',
  'Lucky Vivra',
] as const;

function toIdPart(name: string): string {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function makeGift(name: string, type: GiftCatalogType): GiftCatalogItem {
  const idName = type === 'lucky' ? name.replace(/^Lucky /, '') : name;
  return {
    id: `${type}-${toIdPart(idName)}`,
    name,
    type,
    isDemo: true,
    nameApproval: 'pending',
    price: null,
    priceApproval: 'pending',
    imageFileName: null,
    imagePath: null,
    imageExists: false,
    imageType: 'static',
    imageStatus: 'pending',
    lottiePath: null,
    lottieExists: false,
    animationType: 'none',
  };
}

export const giftCatalog: GiftCatalogItem[] = [
  ...normalGiftNames.map((name) => makeGift(name, 'normal')),
  ...luckyGiftNames.map((name) => makeGift(name, 'lucky')),
];

const catalogIds = new Set(giftCatalog.map((gift) => gift.id));
const catalogNames = new Set(giftCatalog.map((gift) => gift.name));
const normalGifts = giftCatalog.filter((gift) => gift.type === 'normal');
const luckyGifts = giftCatalog.filter((gift) => gift.type === 'lucky');

if (
  normalGifts.length !== 30 ||
  luckyGifts.length !== 30 ||
  giftCatalog.length !== 60 ||
  catalogIds.size !== giftCatalog.length ||
  catalogNames.size !== giftCatalog.length
) {
  throw new Error('Gift catalog must contain 30 normal and 30 uniquely named, identified Lucky Gifts.');
}

export { normalGifts, luckyGifts };
