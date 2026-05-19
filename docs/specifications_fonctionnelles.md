<a name="toc"></a>
# Spécifications fonctionnelles

## Table des matières
- [Vue d'ensemble](#vue-densemble)
- [Architecture générale & technologies](#architecture-g%C3%A9n%C3%A9rale--technologies)
- [Écrans — description écran par écran](#%C3%A9crans--description-%C3%A9cran-par-%C3%A9cran)
  - [Écran d'accueil / Menu principal](#%C3%A9cran-daccueil--menu-principal)
  - [Écran de jeu (level screen)](#%C3%A9cran-de-jeu-level-screen)
  - [Écran boutique](#%C3%A9cran-boutique)
  - [Écran profil / progression](#%C3%A9cran-profil--progression)
  - [Écran pause / paramètres](#%C3%A9cran-pause--param%C3%A8tres)
  - [Écran de fin de niveau (victoire/échec)](#%C3%A9cran-de-fin-de-niveau-victoire%C3%A9chec)
- [Fonctionnalités détaillées et implémentation](#fonctionnalit%C3%A9s-d%C3%A9taill%C3%A9es-et-impl%C3%A9mentation)
  - [Moteur de jeu (GameEngine)](#moteur-de-jeu-gameengine)
  - [Génération de niveaux](#g%C3%A9n%C3%A9ration-de-niveaux)
  - [Système d'indices (hints)](#syst%C3%A8me-dindices-hints)
  - [Audio et musique adaptative](#audio-et-musique-adaptative)
  - [IAP, Ads et services](#iap-ads-et-services)
- [Gestion d'état et données](#gestion-d%C3%A9tat-et-donn%C3%A9es)
- [Tests & assurance qualité](#tests--assurance-qualit%C3%A9)
- [Déploiement & builds](#d%C3%A9ploiement--builds)
- [Découpage MOA (fonctionnel / non fonctionnel)](#d%C3%A9coupage-moa-fonctionnel--non-fonctionnel)
- [Annexes & fichiers sources référencés](#annexes--fichiers-sources-r%C3%A9f%C3%A9renc%C3%A9s)

---

<a name="vue-densemble"></a>
## Vue d'ensemble

Ce document décrit comment le jeu a été construit écran par écran, quelles technologies et outils ont été utilisés, et comment chaque fonctionnalité principale a été implémentée. Il sert de référence pour les développeurs, QA et parties prenantes produit.

---

<a name="architecture-g%C3%A9n%C3%A9rale--technologies"></a>
## Architecture générale & technologies

- Langage & framework : Flutter (Dart) pour mobile & web.
- Gestion d'état : Riverpod (voir `lib/core/store/game_providers.dart`).
- Moteur de logique : `lib/core/engine/game_engine.dart` — swap, détection de matches, gravité, hint.
- Génération de niveaux : `lib/core/generators/level_generator.dart`.
- Audio : `lib/services/audio/audio_manager.dart` — musique adaptative et effets.
- Tests : `test/unit/` et `test/widgets/`.
- Assets : `assets/images/sushis/`, `assets/audio/` (music & sfx).

---

<a name="%C3%A9crans--description-%C3%A9cran-par-%C3%A9cran"></a>
## Écrans — description écran par écran

### <a name="%C3%A9cran-daccueil--menu-principal"></a>Écran d'accueil / Menu principal

- Objectif : point d'entrée, navigation vers niveaux, boutique, profil et options.
- Éléments UI : logo, bouton "Jouer", sélecteur de niveau, accès boutique, paramètres.
- Données nécessaires : progression globale du joueur, offres en boutique.
- Dépendances techniques : providers pour progression (`game_providers`), assets UI, animations.
- Tests : vérification des interactions, navigation, affichage des offres.

### <a name="%C3%A9cran-de-jeu-level-screen"></a>Écran de jeu (level screen)

- Objectif : zone de jeu principale où le joueur effectue les échanges.
- Éléments UI : grille (composant animé), HUD (score, timer, objectifs, boosters), boutons pause/hint.
- Composants : `ui/components/game_components.dart` (AnimatedGameGrid, AnimatedSushiTile, etc.), `ui/screens/game_screen.dart` orchestre la vue.
- Flux : init niveau -> `GameEngine.initGrid()` -> affichage -> actions du joueur -> `GameEngine.swap()` -> résolution matches -> mise à jour `GameProviders`.
- Données : état de la grille, score courant, multiplicateur, vies, progression niveau.
- Tests : simulations de swaps, vérification de scoring, tests widget d'UI.

### <a name="%C3%A9cran-boutique"></a>Écran boutique

- Objectif : achat de boosters, packs de gemmes, offres.
- Éléments UI : liste d'offres IAP, boutons d'achat, aperçu de l'inventaire.
- Implémentation : wrapper IAP natif (play store / app store), validation côté client, mise à jour du provider inventaire.
- Sécurité : vérifier les reçus/consommations via backend ou validation native selon besoin.

### <a name="%C3%A9cran-profil--progression"></a>Écran profil / progression

- Objectif : montrer progression, statistiques, achievements, gestion du compte.
- Données : niveaux complétés, étoiles collectées, total gemmes, historique.

### <a name="%C3%A9cran-pause--param%C3%A8tres"></a>Écran pause / paramètres

- Objectif : pause de la partie, réglages audio, réinitialiser tutoriel, accès boutique.

### <a name="%C3%A9cran-de-fin-de-niveau-victoire%C3%A9chec"></a>Écran de fin de niveau (victoire/échec)

- Objectif : récapitulatif du niveau, étoiles obtenues, récompenses, proposer replay / niveau suivant.

---

<a name="fonctionnalit%C3%A9s-d%C3%A9taill%C3%A9es-et-impl%C3%A9mentation"></a>
## Fonctionnalités détaillées et implémentation

<a name="moteur-de-jeu-gameengine"></a>
### Moteur de jeu (`GameEngine`)

- Emplacement : `lib/core/engine/game_engine.dart`.
- Rôle : logique principale — init grille sans matches initiaux, swap, détection de motifs, suppression, application de gravité, recherche d'indices.
- API clés : `initGrid()`, `swap(posA,posB)`, `resolveMatches()`, `getHint()`.
- Intégration UI : le `game_screen` écoute l'état du moteur via Riverpod et anime les changements.

<a name="g%C3%A9n%C3%A9ration-de-niveaux"></a>
### Génération de niveaux

- Emplacement : `lib/core/generators/level_generator.dart`.
- Rôle : définir la configuration d'un niveau (rows, cols, sushiTypeCount, objectifs, seuils d'étoiles).
- Logique : progressive difficulty (ex : augmentation `sushiTypeCount` selon le palier), placement d'obstacles, distribution initiale sans matches.

<a name="syst%C3%A8me-dindices-hints"></a>
### Système d'indices (hints)

- Rôle : proposer le meilleur échange si le joueur reste inactif (auto-hint après délai paramétrable).
- Implémentation : `GameEngine.getHint()` parcourt la grille et renvoie la meilleure action; l'UI affiche un overlay pulsant.
- Paramètres : délai de hint (ex : 10s + palier de niveaux), visibilité persistante jusqu'au mouvement.

<a name="audio-et-musique-adaptive"></a>
### Audio et musique adaptative

- Emplacement : `lib/services/audio/audio_manager.dart`.
- Rôle : jouer SFX (swap, match, combo, erreur) et musique adaptative (calme → urgent selon `timeRatio`).
- API : `playSwap()`, `playMatch()`, `playCombo()`, `updateMusicIntensity(timeRatio)`.

<a name="iap-ads-et-services"></a>
### IAP, Ads et services

- IAP : intégration native store, validation d'achat, mise à jour providers.
- Ads : si présentes, gérées via plugin d'ad network, adapter l'affichage et suivi pour ne pas nuire à la UX.
- Analytics : événements (level_start, level_complete, purchase) envoyés à l'outil choisi (ex : Firebase Analytics).

---

<a name="gestion-d%C3%A9tat-et-donn%C3%A9es"></a>
## Gestion d'état et données

- Riverpod centralise l'état (score, vies, inventaire, progression). Voir `lib/core/store/game_providers.dart`.
- Persistance : sauvegarde locale (SharedPreferences / storage) pour progression et inventaire, synchronisation optionnelle via backend.
- Modèles : définir des DTO pour Niveau, Progression, Inventaire, Achievements.

---

<a name="tests--assurance-qualit%C3%A9"></a>
## Tests & assurance qualité

- Tests unitaires : logique du moteur (ex : `test/unit/game_engine_test.dart`).
- Tests widget : composants UI critiques (ex : `test/widgets/game_components_test.dart`).
- Scénarios QA : niveaux tutoriels, utilisation de boosters, comportements en cas de latence ou d'absence d'indices.

---

<a name="d%C3%A9ploiement--builds"></a>
## Déploiement & builds

- Build Android : Gradle wrapper (voir `android/`), signature et store publishing.
- Build iOS : Xcode workspace (`ios/Runner.xcworkspace`).
- Web : build via `flutter build web`.
- CI/CD : intégrer tests unitaires et widget avant déploiement en store.

---

<a name="d%C3%A9coupage-moa-fonctionnel--non-fonctionnel"></a>
## Découpage MOA (fonctionnel / non fonctionnel)

- Fonctions principales (MOA fonctionnalités) :
  - Jouer un niveau (sélection, démarrage, score, fin)
  - Acheter et utiliser des boosters
  - Visualiser progression et statistiques
  - Notifications / événements (quotidiens)

- Critères d'acceptation :
  - Niveau se lance et termine correctement selon objectifs
  - Score et étoiles sont calculés et persistés
  - Achats consomment la monnaie et mettent à jour l'inventaire

- Non-fonctionnel :
  - Temps de chargement acceptable (<3s pour écran principal sur devices cibles)
  - Disponibilité offline limitée (jouer niveaux déjà téléchargés)
  - Respect des règles stores pour IAP et vie privée

---

<a name="annexes--fichiers-sources-r%C3%A9f%C3%A9renc%C3%A9s"></a>
## Annexes & fichiers sources référencés

- Moteur : `lib/core/engine/game_engine.dart`
- Générateur de niveaux : `lib/core/generators/level_generator.dart`
- Providers / état : `lib/core/store/game_providers.dart`
- Écran de jeu : `lib/ui/screens/game_screen.dart`
- Composants UI : `lib/ui/components/game_components.dart`
- Audio : `lib/services/audio/audio_manager.dart`
- Tests : `test/unit/` et `test/widgets/`

---

Pour toute modification fonctionnelle, mettre à jour ce document et ajouter les cas de test correspondants.
