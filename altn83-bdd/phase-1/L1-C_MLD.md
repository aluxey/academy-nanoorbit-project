# Livrable L1-C : Modèle Logique de Données (MLD)

## Étape 4 : Passage MCD → MLD

### Transformation du MCD en Schéma Relationnel

Le MCD a été transformé en 10 tables relationnelles selon les règles de transformation MERISE :

- **Entités** → Tables
- **Associations 1-N** → FK dans la table côté N
- **Associations N-M** → Tables d'association avec PK composite (FK1 + FK2) + attributs

### Tables du MLD (avec types Oracle)

#### 1. ORBITE
```sql
ORBITE (
    id_orbite NUMBER PRIMARY KEY,
    type_orbite VARCHAR2(50) NOT NULL,
    altitude NUMBER NOT NULL,
    inclinaison NUMBER NOT NULL,
    periode_orbitale NUMBER NOT NULL,
    excentricite NUMBER NOT NULL,
    zone_couverture VARCHAR2(100) NOT NULL
)
```

#### 2. SATELLITE
```sql
SATELLITE (
    id_satellite VARCHAR2(10) PRIMARY KEY,
    nom_satellite VARCHAR2(50) NOT NULL,
    date_lancement TIMESTAMPNOT NULL,
    masse NUMBER NOT NULL,
    format_cubesat VARCHAR2(10) NOT NULL,
    statut VARCHAR2(20) NOT NULL,
    duree_vie_prevue NUMBER NOT NULL,
    capacite_batterie NUMBER NOT NULL,
    id_orbite NUMBER NOT NULL REFERENCES ORBITE(id_orbite)
)
```

#### 3. INSTRUMENT
```sql
INSTRUMENT (
    ref_instrument VARCHAR2(15) PRIMARY KEY,
    type_instrument VARCHAR2(50) NOT NULL,
    modele VARCHAR2(50) NOT NULL,
    resolution NUMBER,
    consommation NUMBER NOT NULL,
    masse NUMBER NOT NULL
)
```

#### 4. EMBARQUEMENT (Association SATELLITE ↔ INSTRUMENT)
```sql
EMBARQUEMENT (
    id_satellite VARCHAR2(10) REFERENCES SATELLITE(id_satellite),
    ref_instrument VARCHAR2(15) REFERENCES INSTRUMENT(ref_instrument),
    date_integration TIMESTAMPNOT NULL,
    etat_fonctionnement VARCHAR2(20) NOT NULL,
    PRIMARY KEY (id_satellite, ref_instrument)
)
```

#### 5. CENTRE_CONTROLE
```sql
CENTRE_CONTROLE (
    id_centre NUMBER PRIMARY KEY,
    nom_centre VARCHAR2(50) NOT NULL,
    ville VARCHAR2(50) NOT NULL,
    region_geo VARCHAR2(50) NOT NULL,
    fuseau_horaire VARCHAR2(50) NOT NULL,
    statut VARCHAR2(20) NOT NULL
)
```

#### 6. STATION_SOL
```sql
STATION_SOL (
    code_station VARCHAR2(15) PRIMARY KEY,
    nom_station VARCHAR2(50) NOT NULL,
    latitude NUMBER NOT NULL,
    longitude NUMBER NOT NULL,
    diametre_antenne NUMBER NOT NULL,
    bande_frequence VARCHAR2(10) NOT NULL,
    debit_max NUMBER NOT NULL,
    statut VARCHAR2(20) NOT NULL
)
```

#### 7. AFFECTATION_STATION (Association CENTRE_CONTROLE ↔ STATION_SOL)
```sql
AFFECTATION_STATION (
    id_centre NUMBER REFERENCES CENTRE_CONTROLE(id_centre),
    code_station VARCHAR2(15) REFERENCES STATION_SOL(code_station),
    date_affectation TIMESTAMPNOT NULL,
    PRIMARY KEY (id_centre, code_station)
)
```

#### 8. MISSION
```sql
MISSION (
    id_mission VARCHAR2(20) PRIMARY KEY,
    nom_mission VARCHAR2(50) NOT NULL,
    objectif VARCHAR2(200) NOT NULL,
    zone_geo_cible VARCHAR2(50) NOT NULL,
    date_debut TIMESTAMPNOT NULL,
    date_fin DATE,
    statut_mission VARCHAR2(20) NOT NULL
)
```

#### 9. FENETRE_COM (Association SATELLITE ↔ STATION_SOL)
```sql
FENETRE_COM (
    id_fenetre NUMBER PRIMARY KEY,
    datetime_debut TIMESTAMP NOT NULL,
    duree NUMBER NOT NULL,
    elevation_max NUMBER NOT NULL,
    volume_donnees NUMBER,
    statut VARCHAR2(20) NOT NULL,
    id_satellite VARCHAR2(10) NOT NULL REFERENCES SATELLITE(id_satellite),
    code_station VARCHAR2(15) NOT NULL REFERENCES STATION_SOL(code_station)
)
```

#### 10. PARTICIPATION (Association SATELLITE ↔ MISSION)
```sql
PARTICIPATION (
    id_satellite VARCHAR2(10) REFERENCES SATELLITE(id_satellite),
    id_mission VARCHAR2(20) REFERENCES MISSION(id_mission),
    role_satellite VARCHAR2(50) NOT NULL,
    PRIMARY KEY (id_satellite, id_mission)
)
```

### Vérification de la Normalisation (3NF)

Toutes les tables respectent la 3ème forme normale :

- **1NF** : Attributs atomiques, pas de groupes répétitifs
- **2NF** : Pas de dépendance partielle (PK composites gérées correctement)
- **3NF** : Pas de dépendance transitive (tous attributs non-clés dépendent directement de la PK)

#### Exemples de validation 3NF :
- **SATELLITE** : Tous attributs dépendent de id_satellite (PK)
- **EMBARQUEMENT** : Attributs date_integration, etat_fonctionnement dépendent de (id_satellite, ref_instrument)
- **FENETRE_COM** : Attributs dépendent de id_fenetre, FK vers satellites et stations

### Ordre de Création des Tables (pour respecter les FK)

1. ORBITE (pas de FK)
2. SATELLITE (FK vers ORBITE)
3. INSTRUMENT (pas de FK)
4. EMBARQUEMENT (FK vers SATELLITE et INSTRUMENT)
5. CENTRE_CONTROLE (pas de FK)
6. STATION_SOL (pas de FK)
7. AFFECTATION_STATION (FK vers CENTRE_CONTROLE et STATION_SOL)
8. MISSION (pas de FK)
9. PARTICIPATION (FK vers SATELLITE et MISSION)
10. FENETRE_COM (FK vers SATELLITE et STATION_SOL)

### Cohérence avec les Données de Référence

- **39 lignes** réparties dans les 10 tables
- **PK/FK** cohérentes avec les données CSV
- **Types Oracle** adaptés aux valeurs (NUMBER pour numériques, VARCHAR2 pour chaînes, DATE/TIMESTAMP pour dates)

Ce MLD constitue la base pour l'implémentation DDL Oracle de la Phase 2.</content>
<parameter name="filePath">/Users/louis.maury/Documents/EFREI/M1 - EFREI/BDD reparties/academy-nanoorbit-project/L1-C_MLD.md