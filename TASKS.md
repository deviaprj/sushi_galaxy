# Sushi Galaxy - Beta Release Tasks

Objectif: livrer une version **release beta** stable, testable par un groupe fermé, avec boucle de progression complète et monétisation contrôlée.

## Definition of Done (Beta)
- Pas de crash bloquant sur un parcours complet (menu -> niveau -> victoire/echec -> relance).
- Progression, vies, gemmes et paramètres persistent correctement après redémarrage.
- Monétisation fonctionnelle en sandbox (IAP + rewarded ads), sans exploit majeur.
- Performance acceptable sur device cible (Android 15): fluidité gameplay et temps de chargement raisonnables.
- Instrumentation analytics minimale active pour suivre rétention et conversion.

## P0 - Bloquants avant beta

### 1) Stabilite ads/rewards et anti-exploit
- [ ] Vérifier tous les flows rewarded (profil, echec niveau, bonus) avec réseau lent/erreur chargement.
- [ ] Empêcher tout contournement de consommation de vie via navigation rapide / double tap.
- [ ] Bloquer clairement les CTA non autorisés quand `currentLives == 0` sur tous les écrans concernés.
- [ ] Ajouter tests ciblés pour les scénarios 1 pub et 2 pubs (niveau > 20).

### 2) Vies/recharge/notifications
- [ ] Valider la recharge automatique des vies sur longue durée (app ouverte, arrière-plan, app relancée).
- [ ] Vérifier notification "vies pleines" Android (permission, horaire, duplication).
- [ ] Ajouter fallback si notifications désactivées (message explicite dans UI).
- [ ] Vérifier la cohérence des compteurs "prochaine vie" et "vies pleines".

### 3) Audio fiabilité Android
- [ ] Corriger `AudioPlayerException` potentielle (`MEDIA_ERROR_UNKNOWN`) sur SFX (`match.wav`, etc.).
- [ ] Uniformiser format assets audio (PCM 16-bit, sample rate cohérent, mono/stereo validé).
- [ ] Ajouter une vérification runtime: si un son échoue, fallback silencieux sans casser le gameplay.

### 4) UI/UX sans overflow
- [ ] Revalider tous les écrans clés sur petites résolutions (fail/complete/shop/profile/settings).
- [ ] Corriger tout `RenderFlex overflow` restant.
- [ ] Garantir l'accessibilité minimale (tailles lisibles, contrastes, boutons cliquables).

### 5) Build release et signature
- [ ] Configurer signature Android release (`keystore`, `key.properties`, gradle signing).
- [ ] Produire `appbundle` beta (`flutter build appbundle --release`).
- [ ] Vérifier permissions manifest et conformité Android 13+ (notifications).

## P1 - Fortement recommandé avant beta

### 6) Telemetrie minimale
- [ ] Ajouter événements: `session_start`, `level_start`, `level_complete`, `level_fail`, `rewarded_shown`, `rewarded_earned`, `purchase_attempt`, `purchase_success`.
- [ ] Ajouter IDs de niveau et temps de session dans les événements.
- [ ] Créer un mini tableau de bord de suivi (funnel basique).

### 7) Economie et balancing
- [ ] Réviser coûts boutique (boosters/gemmes) vs difficulté des paliers de niveau.
- [ ] Vérifier qu'une progression sans achat reste viable.
- [ ] Définir limites anti-inflation (gemmes récompenses, bonus journaliers).

### 8) Onboarding et comprehension joueur
- [ ] Tutoriel court (swap, objectif, booster, récompense).
- [ ] Clarifier les messages d'échec/victoire et de progression.
- [ ] Vérifier cohérence des textes FR dans toute l'app.

### 9) Graphismes assets
- [ ] Traiter warnings SVG (`unhandled element <filter/>`) en simplifiant les SVG ou en fallback PNG.
- [ ] Vérifier poids des assets pour réduire taille build et temps de chargement.

## P2 - Post-beta (non bloquant)
- [ ] Événements temporaires complets (calendrier, récompenses spécifiques, entry points dédiés).
- [ ] Daily rewards avancés.
- [ ] Social/leaderboard.
- [ ] A/B testing pricing et difficulté.

## Test Plan Beta (checklist exécution)
- [ ] `flutter analyze --no-fatal-infos`
- [ ] `flutter test`
- [ ] Smoke test manuel (30 min): 5 niveaux, 3 échecs, 3 relances, 2 rewarded success, 1 rewarded fail.
- [ ] Test persistance: kill app, reboot device, reprise correcte des données.
- [ ] Test offline/intermittent network: ads indisponibles, gameplay stable.

## Commandes utiles
```bash
/home/geekai/flutter/bin/flutter pub get --offline
/home/geekai/flutter/bin/flutter analyze --no-fatal-infos
/home/geekai/flutter/bin/flutter test
/home/geekai/flutter/bin/flutter build apk --debug
/home/geekai/flutter/bin/flutter build appbundle --release
bash scripts/install-app.sh build/app/outputs/flutter-apk/app-debug.apk
```

## Risques connus à traiter
- Bug intermittent `pub get` (advisories cache). Contournement actuel: purge cache advisories + mode offline.
- Variabilité d'affichage selon la hauteur écran (déjà corrigé sur `level_fail_screen`, à revalider globalement).
- Dépendance forte aux réseaux publicitaires pour les tests rewarded.

## Derniers accomplissements récents
- [x] Séquence rewarded ads 2 vidéos enchaînées (niveau > 20).
- [x] Blocage du flow "continuer" si plus de vie + message guidage.
- [x] Décompte "prochaine vie" et "vies pleines" sur écran d'échec.
- [x] Notification locale quand les vies sont pleines.
- [x] Correction overflow UI sur écran de défaite (scrollable).