# Sushi Galaxy — Game Design Document

**Version :** 1.0
**Date :** 2026-03-28
**Genre :** Match-3 Puzzle Game
**Platformes :** iOS, Android

---

## 1. Executive Summary

### 1.1 Concept

**Sushi Galaxy** est un jeu de puzzle match-3 où le joueur combine des sushis et onigiris lumineux dans un décor de restaurant spatial futuriste. Chaque combinaison crée des "recettes de chef" animées, progressant à travers des niveaux représentant des plats gastronomiques à compléter.

### 1.2 Proposition de Valeur

| Pour le joueur | Pour nous |
|----------------|-----------|
| Gameplay addictif et satisfaisant | ARPU élevé via IAP + Ads |
| Esthétique food relaxante | Rétention D1/D7/D30 élevée |
| Collection de recettes uniques | Événements saisonniers viraux |
| Gratuit avec monétisation douce | Scalable via Firebase |

### 1.3 Cible

- **Âge :** 18-45 ans
- **Genre :** 60% femmes, 40% hommes
- **Style :** Casual gamers, food enthusiasts, TikTok users

---

## 2. Gameplay

### 2.1 Mécaniques Core

#### Grille de Jeu
- **Taille :** 8x8 (standard), évoluant de 6x6 à 10x10 selon niveau
- **Éléments :** 8 types de sushis/onkigourmet

#### Éléments du Jeu

| ID | Nom | Couleur | Rareté |
|----|-----|--------|--------|
| 1 | 🍣 Salmon | Orange rose | Common |
| 2 | 🐟 Tuna | Rouge rubis | Common |
| 3 | 🦐 Shrimp | Rose corail | Common |
| 4 | 🥚 Tamago | Jaune or | Common |
| 5 | 🥑 Avocado | Vert émeraude | Uncommon |
| 6 | 🥒 Cucumber | Vert jade | Uncommon |
| 7 | 🧀 Cheese | Jaune vif | Rare |
| 8 | 🌭 Sausage | Marron | Epic |

#### Système de Matching
- **Match 3 :** Échange de 2 éléments adjacents
- **Match 4 ligne :** +Bombe directionnelle
- **Match 4 L/T :** +Bombe radiale
- **Match 5 ligne :** +Effaceur de rangée
- **Match 5+ :** +Super-bombe (détruit 5x5)

#### Power-ups

| Type | Créé par | Effet |
|------|----------|-------|
| 💣 Directionnelle | Match 4 | Détruit ligne OU colonne |
| 💥 Radiale | Match 4 L/T | Détruit rayon 3x3 |
| ⚡ Éraseur | Match 5 | Détruit rangée/colonne entière |
| 🌟 Super | Match 6+ | Détruit zone 5x5 |

#### Objectifs par Niveau

| Type | Description |
|------|-------------|
| 🏆 Score | Atteindre X points |
| 🍣 Collect | Collecter N sushi spécifiques |
| 💨 Clear | Éliminer tous les bloquants |
| 🎯 Order | Détuire dans un ordre précis |

### 2.2 Progression

#### Système de Vies
- **Vies max :** 5
- **Recharge :** 30 min par vie
- **Prix refill :** 100 gems ou 1 ad

#### Difficulté Curve

| Niveau | Difficulté | Win Rate Target |
|--------|------------|-----------------|
| 1-10 | Tutorial | 95% |
| 11-30 | Easy | 85% |
| 31-60 | Medium | 70% |
| 61-100 | Hard | 60% |
| 101-200 | Expert | 50% |
| 201+ | Procedural | Adaptatif |

---

## 3. Univers Visuel

### 3.1 Thème Principal

**Restaurant Spatial Futuriste** — néons suaves, planètes en cuisine, gravité légère, musique ambient zen.

### 3.2 Palette de Couleurs

| Usage | Couleur | Hex |
|-------|---------|-----|
| Primary | Deep Space Blue | #0D1B2A |
| Secondary | Neon Purple | #7B2CBF |
| Accent 1 | Sakura Pink | #FF6B9D |
| Accent 2 | Golden Rice | #FFD93D |
| Background | Cosmos Dark | #1B1B2F |
| Surface | Glass White | #FFFFFF20 |

### 3.3 Typographie

- **Display :** Poppins Bold (pour titres)
- **Body :** Inter Regular (pour textes)

---

## 4. Économie

### 4.1 Monnaies

| Currency | Usage | Acquisition |
|----------|-------|-------------|
| ⭐ Stars | Score, progression | Niveau gagné |
| 💎 Gems | Boosters, vies, IAP | Daily, IAP, events |
| 🪙 Coins | cosmetics, upgrades | Parties |

### 4.2 Catalogue IAP

| ID | Prix | Gems | Badge |
|----|------|------|-------|
| starter_small | $0.99 | 80 | - |
| starter_medium | $4.99 | 500 | POPULAR |
| starter_large | $9.99 | 1200 | - |
| starter_xl | $19.99 | 3000 | BEST |

### 4.3 Abonnements

| Plan | Prix | Avantages |
|------|------|-----------|
| Weekly | $1.99 | No ads + 1 vie/h |
| Monthly | $5.99 | No ads + 2 vies/h + daily bonus x3 |
| Yearly | $39.99 | Monthly + exclusif annuel |

---

## 5. Rétention

### 5.1 Daily Login

- **Jours 1-7 :** 10, 20, 30, 50, 75, 100, 200 gems
- **Streak bonus :** Multiplicateur x1.5 à x3

### 5.2 Événements

- **Frequency :** Bi-weekly
- **Types :** Holiday theme, Special recipes, Bonus rewards

---

## 6. Analytics

### 6.1 Events à Tracker

```dart
// Gameplay
'level_started',
'level_completed',
'level_failed',
'move_made',
'powerup_created',

// Monetization
'ad_shown',
'ad_rewarded',
'iap_purchased',
'subscription_started',

// Engagement
'daily_login',
'session_duration',
'feature_used',
```

---

## 7. Roadmap

### Phase 1 (MVP)
- [ ] 50 niveaux
- [ ] Match-3 core + power-ups
- [ ] Ads intégration
- [ ] IAP basique

### Phase 2 (Growth)
- [ ] Abonnements
- [ ] Événements
- [ ] Leaderboards
- [ ] Social features

### Phase 3 (Scale)
- [ ] 500 niveaux procéduraux
- [ ] A/B testing
- [ ] Seasonal events
- [ ] Multiple themes

---

## 8. Risques & Mitigations

| Risque | Mitigation |
|--------|------------|
| Churn élevé après lvl 50 | Procedural level generator |
| Low IAP conversion | A/B test offers |
| Ads fatigue | Strict frequency cap |
| Performance low-end | Flame optimization |

---

*Document généré pour Sushi Galaxy — Match-3 Game*