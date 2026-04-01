# Livrable L2-E6 : DDL - Création des 10 Tables

## Étape 6 : DDL (Implémentation Oracle)

### Vue d'ensemble

10 tables créées dans l'ordre respectant les dépendances de clés étrangères, avec contraintes intégrées selon la Phase 1.

### Ordre de Création (respecte les FK)

```
1. ORBITE              (pas de FK)
2. SATELLITE           (FK → ORBITE)
3. INSTRUMENT          (pas de FK)
4. EMBARQUEMENT        (FK → SATELLITE, INSTRUMENT)
5. CENTRE_CONTROLE     (pas de FK)
6. STATION_SOL         (pas de FK)
7. AFFECTATION_STATION (FK → CENTRE_CONTROLE, STATION_SOL)
8. MISSION             (pas de FK)
9. PARTICIPATION       (FK → SATELLITE, MISSION)
10. FENETRE_COM        (FK → SATELLITE, STATION_SOL)
```

### Contraintes Intégrées

#### Contraintes Structurelles
- **ORBITE** : PK sur id_orbite + UNIQUE (altitude, inclinaison) — RG-O02
- **SATELLITE** : PK sur id_satellite + FK vers ORBITE
- **INSTRUMENT** : PK sur ref_instrument
- **EMBARQUEMENT** : PK composite (id_satellite, ref_instrument) + FK
- **CENTRE_CONTROLE** : PK sur id_centre
- **STATION_SOL** : PK sur code_station
- **AFFECTATION_STATION** : PK composite (id_centre, code_station) + FK
- **MISSION** : PK sur id_mission
- **PARTICIPATION** : PK composite (id_satellite, id_mission) + FK
- **FENETRE_COM** : PK sur id_fenetre + FK vers SATELLITE et STATION_SOL

#### Contraintes de Domaine (CHECK)
- **SATELLITE.statut** : IN ('Opérationnel', 'En veille', 'Désorbité') — RG-S03
- **SATELLITE.format_cubesat** : IN ('3U', '6U', '12U')
- **EMBARQUEMENT.etat_fonctionnement** : IN ('Nominal', 'Dégradé', 'Hors service')
- **STATION_SOL.bande_frequence** : IN ('S', 'X', 'Ku', 'Ka')
- **STATION_SOL.statut** : IN ('Active', 'Maintenance', 'Hors service')
- **MISSION.statut_mission** : IN ('Active', 'Terminée', 'Planifiée') — RG-M02
- **MISSION.date_fin** : >= date_debut (si non NULL)
- **FENETRE_COM.statut** : IN ('Réalisée', 'Planifiée')
- **FENETRE_COM.duree** : BETWEEN 1 AND 900 — RG-F04
- **FENETRE_COM.elevation_max** : BETWEEN 0 AND 90

#### Attributs NULLABLE
- **INSTRUMENT.resolution** : NULL — RG-I01
- **MISSION.date_fin** : NULL pour missions actives
- **FENETRE_COM.volume_donnees** : NULL pour fenêtres planifiées — RG-F05 (à valider par trigger)

### Types Oracle Utilisés

- **NUMBER** : Identifiants numériques, altitudes, angles, durées
- **VARCHAR2** : Codes, noms, descriptions, énumérations
- **DATE** : Dates de lancement, affectation, missions
- **TIMESTAMP** : Horaires précis des fenêtres de communication

### Commentaires de Schéma

Tous les commentaires (TABLE et COLUMN) incluent :
- Description métier
- Références aux règles de gestion
- Explications des formats spéciaux

### Script d'Exécution

**Fichier** : [L2-E6_DDL_Tables.sql](L2-E6_DDL_Tables.sql)

**Pour exécuter** :
```sql
SQL> @L2-E6_DDL_Tables.sql
```

### Validation Après Exécution

Le script inclut une vérification finale listant les 10 tables créées.

---

## ✅ Étape 6 Complétée

Les tables sont prêtes pour l'**Étape 7 : DML (insertion des données)**.