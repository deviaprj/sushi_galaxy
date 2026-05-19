<a name="toc"></a>
# Notice — Histoire et guide du jeu

## Table des matières
- [Introduction / Histoire du jeu](#introduction--histoire)
- [Concepts principaux](#concepts-principaux)
- [Règles du jeu](#r%C3%A8gles-du-jeu)
- [Éléments de l'écran de jeu](#%C3%A9l%C3%A9ments-de-l%C3%A9cran-de-jeu)
- [Comptabilisation des points](#comptabilisation-des-points)
- [Combos, étoiles et gemmes](#combos-%C3%A9toiles-et-gemmes)
- [Boosters et achats intégrés](#boosters-et-achats-int%C3%A9gr%C3%A9s)
- [Astuces et bonnes pratiques](#astuces-et-bonnes-pratiques)
- [Possibilités et extensions](#possibilit%C3%A9s-et-extensions)
- [Conclusion](#conclusion)

---

<a name="introduction--histoire"></a>
## Introduction / Histoire du jeu

Sushi Galaxy est un jeu de puzzle match-3 inspiré des environnements néomorphiques, avec une esthétique « space-restaurant » chaleureuse. Le joueur aligne des éléments (sushis) sur une grille pour créer des combinaisons et progresser à travers des niveaux de difficulté croissante. Le gameplay mêle stratégie (choisir les meilleurs échanges), gestion du temps et utilisation de boosters pour atteindre des objectifs de niveau.

---

<a name="concepts-principaux"></a>
## Concepts principaux

- Grille : matrice de tuiles (sushis) de taille fixe par niveau.
- Types de sushi : différentes couleurs/icônes représentant des types (réduisent la complexité ou l'augmentent selon le nombre de types actifs).
- Échanges : le joueur échange deux tuiles adjacentes pour créer une suite d'au moins 3 tuiles identiques.
- Match automatique : lorsqu'un match est créé, les tuiles disparaissent, la gravité s'applique et de nouvelles tuiles tombent.
- Objectifs : score, collecte d'items, ou élimination d'obstacles selon le niveau.
- Boosters : actions instantanées qui modifient la grille (ex : supprimer une ligne, détruire une couleur, ajouter du temps).

---

<a name="r%C3%A8gles-du-jeu"></a>
## Règles du jeu

- Faire un échange adjacent pour former au moins une ligne de 3 éléments identiques.
- Les matches de 4+ ou en formes spéciales génèrent des tuiles spéciales (bombes, rayons, etc.) suivant le niveau de design.
- Chaque niveau a des objectifs (score cible, collecter X éléments, éliminer des obstacles) et parfois une limite de mouvements ou de temps.
- Les boosters peuvent être achetés ou gagnés ; leur utilisation est limitée par des ressources ou cooldowns.
- Certaines actions produisent des combos qui augmentent le multiplicateur de score.

---

<a name="%C3%A9l%C3%A9ments-de-l%C3%A9cran-de-jeu"></a>
## Éléments de l'écran de jeu

- Barre de score : affiche le score courant.
- Timer : montre le temps restant si le niveau est chronométré.
- Vies / Tentatives : nombre de vies disponibles (si applicable).
- Objectif : rappel de l'objectif du niveau (ex : atteindre X points, collecter Y items).
- Grille de jeu : zone principale où se trouvent les tuiles.
- Indicateur de combo / multiplicateur : montre le combo en cours.
- Boutons Boosters : accès aux boosters (actifs ou achetables).
- Mini-carte / progression (étoiles) : montre la progression et les étoiles gagnées pour le niveau.
- Indicateur de hint : montre l'aide automatique si activée.

---

<a name="comptabilisation-des-points"></a>
## Comptabilisation des points

- Match de base (3) : valeur de base (ex : 100 pts) — valeur paramétrable par niveau.
- Match de 4 ou plus : bonus + création possible d'une tuile spéciale.
- Combos successifs : chaque match consécutif dans la même cascade augmente un multiplicateur temporaire (ex : x1.2, x1.5...).
- Actions spéciales : destruction de tuiles via boosters ou tuiles spéciales donne des points additionnels.
- Bonus de fin de niveau : temps restant, objectifs complémentaires et combos peuvent ajouter un bonus final.

---

<a name="combos-%C3%A9toiles-et-gemmes"></a>
## Combos, étoiles et gemmes

- Combos : enchaînements de réactions en chaîne après un seul échange. Plus la chaîne est longue, plus le multiplicateur augmente.
- Étoiles : notation de la performance sur un niveau (généralement 1–3 étoiles). Les seuils d'étoiles sont fixés par niveau selon l'objectif.
- Gemmes (ou ressources premium) : monnaie collectionnable (souvent rare) utilisée pour achats spéciaux ou débloquer contenus.

---

<a name="boosters-et-achats-int%C3%A9gr%C3%A9s"></a>
## Boosters et achats intégrés

Les boosters sont des outils pour aider le joueur. Exemples courants :

- `Bomb` : détruit une zone autour d'une tuile.
- `ColorClear` : supprime toutes les tuiles d'une couleur.
- `LineClear` : supprime une ligne ou colonne entière.
- `ExtraTime` : ajoute du temps au timer.
- `Shuffle` : mélange la grille quand aucun coup utile n'est disponible.

Achats :
- Achats en boutique (IAP) : packs de gemmes, boosters, offres quotidiennes.
- Monnaies : pièces (gratuite) et gemmes (premium).

Utilisation :
- Les boosters peuvent être utilisés avant un échange ou pendant la partie suivant la mécanique implémentée. Ils sont généralement limités en nombre et consommés à l'usage.

---

<a name="astuces-et-bonnes-pratiques"></a>
## Astuces et bonnes pratiques

- Chercher les matches qui créent des tuiles spéciales (4+), elles donnent de puissants effets.
- Penser à la gravité : anticiper les chutes après un match pour déclencher des combos.
- Conserver les boosters pour les niveaux à objectifs difficiles ou pour les situations bloquées.
- Prioriser les objectifs (collecte/obstacles) plutôt que le score brut quand le temps est limité.

---

<a name="possibilit%C3%A9s-et-extensions"></a>
## Possibilités et extensions

- Niveaux spéciaux avec obstacles (glace, rochers, tuiles verrouillées).
- Événements temporaires, défis quotidiens et classements sociaux.
- Modes alternatifs : casse-tête sans gravité, survie/time-attack, coopération asynchrone.

---

<a name="conclusion"></a>
## Conclusion

Ce document présente une vue d'ensemble destinée à informer les joueurs du fonctionnement, des règles et des astuces du jeu. Pour des informations techniques ou détaillées sur la conception, consultez `specifications_fonctionnelles.md`.
