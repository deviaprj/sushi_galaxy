# Sushi Galaxy — Monetization Strategy

## Overview

Revenue model: **Hybrid (Ads + IAP + Subscriptions)**

Target ARPU: $0.50-1.50 per DAU
Target retention: D1 40%, D7 20%, D30 10%

---

## Revenue Streams

### 1. Advertising (60% of revenue)

#### Interstitial Ads
- Show every 3 levels maximum
- Never during gameplay
- Cooldown: 2 minutes minimum
- Excluded: First 10 levels, failed states

#### Rewarded Ads (always optional)
| Trigger | Reward | Daily Limit |
|---------|--------|-------------|
| Continue after fail | +5 moves | 3/day |
| Extra life | +1 life | 5/day |
| Daily bonus double | 2x gems | 1/day |
| Free hint | Show move | 10/day |

#### Banner Ads
- **DISABLED** - UX priority over revenue

### 2. In-App Purchases (30% of revenue)

#### Gem Packs

| Pack | Price | Gems | Value/Gem |
|------|-------|------|-----------|
| Starter | $0.99 | 80 | 0.012 |
| Popular | $4.99 | 500 | 0.010 |
| Power | $9.99 | 1200 | 0.008 |
| Mega | $19.99 | 3000 | 0.007 |

#### Boosters

| Booster | Effect | Price |
|---------|--------|-------|
| Hammer | Destroy 1 tile | 50 gems |
| Shuffle | Randomize grid | 75 gems |
| +5 Moves | Extra moves | 100 gems |

#### Limited Offers

| Offer | Price | Value | Duration |
|-------|-------|-------|----------|
| Welcome | $1.99 | 500 gems + starter boosters | 24h |
| Retry | $0.99 | +5 moves | After fail |
| Stuck | $2.99 | Booster pack | 3 fails |

### 3. Subscriptions (10% of revenue)

| Plan | Price | Key Benefits |
|------|-------|--------------|
| Weekly | $1.99 | No ads, +1 life/hour |
| Monthly | $5.99 | No ads, +2 lives/hour, 3x daily bonus |
| Yearly | $39.99 | All monthly + exclusive themes |

---

## Lives System

- **Max Lives**: 5
- **Recharge Time**: 30 minutes
- **Full Recharge**: 2.5 hours

### Conversion Flow (Out of Lives)

1. Watch 1 ad (free) → +1 life
2. Buy refill (60 gems or $0.99) → 5 lives
3. Wait for timer
4. Subscribe (CTA)

---

## Key Metrics to Track

| Metric | Target | Action |
|--------|--------|--------|
| Ad CTR | >5% | Optimize placement |
| IAP Conversion | >3% | A/B test offers |
| Subscription Rate | >2% | Trial offers |
| Rewarded Ad Rate | >40% | Adjust reward values |
| Day 7 Retention | >20% | Improve onboarding |

---

## A/B Testing Roadmap

1. **Offer pricing** - Test $4.99 vs $5.99 for medium pack
2. **Ad frequency** - Every 3 vs every 5 levels
3. **Reward values** - +3 vs +5 moves for continue
4. **Starter pack** - Different bundle contents

---

## Compliance

- **GDPR**: Consent required before ads
- **COPPA**: No collection from under-13
- **Store Guidelines**: All IAPs must deliver promised value
- **No Dark Patterns**: No fake countdowns, no pressure tactics