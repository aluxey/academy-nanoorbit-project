# NanoOrbit Android — Projet Starter

Ce dossier sera complété avec le projet Android Studio de démarrage.

## Pour démarrer

1. Ouvrir Android Studio
2. `File > Open` → sélectionner ce dossier
3. Attendre la synchronisation Gradle
4. Lancer sur émulateur Pixel 8 (API 26+) ou téléphone réel

## Ce qui est fourni

- `build.gradle.kts` avec toutes les dépendances déclarées
- Structure de packages vide
- `Models.kt` avec les squelettes des data classes à compléter

## Ce qui est à implémenter

Voir `altn82-android/sujets/ALTN82_NanoOrbit_Projet_Android.pdf`


## Réponse questions

### Phase 1

#### Question 1
LazyColumn crée uniquement les éléments visibles.
Column rendrait les 100 satellites d'un coup :
surconsommation mémoire + recompositions coûteuses.

#### Question 2
Une enum empêche des valeurs invalides
(ex: "operatonnel") et garantit la cohérence
avec les CHECK Oracle.

#### Question 3
Si statut == DESORBITE :
- désactiver le bouton planification
- refuser la création côté UI
- afficher erreur utilisateur

Equivalent du trigger Oracle qui bloque
la création côté base.
