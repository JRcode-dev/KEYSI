/**
 * KEYSI — Formatting utilities for large numbers.
 * Handles coins, diamonds, and XP values that can reach hundreds of millions.
 */

export function formatCoins(amount: number): string {
  if (amount >= 1_000_000_000) {
    return `${(amount / 1_000_000_000).toFixed(2)}B`;
  }
  if (amount >= 1_000_000) {
    const val = amount / 1_000_000;
    return `${val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)}M`;
  }
  if (amount >= 1_000) {
    const val = amount / 1_000;
    return `${val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)}K`;
  }
  return String(amount);
}

export function formatNumber(amount: number): string {
  return amount.toLocaleString('en-US');
}

export function formatMultiplier(mult: number): string {
  return `x${mult}`;
}

export function coinsToUsd(coins: number): number {
  return coins / 1_000_000;
}

export function diamondsToCoins(diamonds: number): number {
  return Math.round(diamonds * 0.95);
}

/**
 * Calculate XP required for a given level using the formula from the reference:
 * xp = BASE_XP × (LEVEL_INCREMENT ^ (level - 1))
 */
export function xpForLevel(level: number): number {
  return Math.round(10_000 * Math.pow(1.15, level - 1));
}

/**
 * Total XP needed to reach a given level from level 1.
 */
export function totalXpForLevel(level: number): number {
  let total = 0;
  for (let l = 1; l < level; l++) {
    total += xpForLevel(l);
  }
  return total;
}

/**
 * Returns progress info for a level given current XP within that level.
 */
export function levelProgress(currentLevel: number, currentXpInLevel: number) {
  const needed = xpForLevel(currentLevel);
  const percent = Math.min((currentXpInLevel / needed) * 100, 100);
  return {
    percent,
    current: currentXpInLevel,
    needed,
    remaining: Math.max(needed - currentXpInLevel, 0),
  };
}
