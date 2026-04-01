# Livrable L1-A : Analyse du Dictionnaire des Données

## Étape 1 : Compréhension + Extraction des Données

### Entités Identifiées

À partir des fichiers CSV fournis et du dictionnaire de données, voici la liste complète des entités avec leurs attributs, types Oracle estimés et contraintes identifiées.

#### 1. ORBITE
**Description :** Définit les caractéristiques des orbites disponibles pour les satellites.

**Attributs :**
- `id_orbite` : NUMBER (PK, NOT NULL) - Identifiant unique de l'orbite
- `type_orbite` : VARCHAR2(50) (NOT NULL) - Type d'orbite (SSO, LEO, etc.)
- `altitude` : NUMBER (NOT NULL) - Altitude en km
- `inclinaison` : NUMBER (NOT NULL) - Inclinaison en degrés
- `periode_orbitale` : NUMBER (NOT NULL) - Période orbitale en minutes
- `excentricite` : NUMBER (NOT NULL) - Excentricité de l'orbite
- `zone_couverture` : VARCHAR2(100) (NOT NULL) - Zone géographique couverte

#### 2. SATELLITE
**Description :** Informations sur les satellites NanoOrbit.

**Attributs :**
- `id_satellite` : VARCHAR2(10) (PK, NOT NULL) - Identifiant unique du satellite
- `nom_satellite` : VARCHAR2(50) (NOT NULL) - Nom commercial du satellite
- `date_lancement` : DATE (NOT NULL) - Date de lancement
- `masse` : NUMBER (NOT NULL) - Masse en kg
- `format_cubesat` : VARCHAR2(10) (NOT NULL) - Format CubeSat (3U, 6U, 12U)
- `statut` : VARCHAR2(20) (NOT NULL) - Statut opérationnel (Opérationnel, En veille, Désorbité)
- `duree_vie_prevue` : NUMBER (NOT NULL) - Durée de vie prévue en mois
- `capacite_batterie` : NUMBER (NOT NULL) - Capacité batterie en Wh
- `id_orbite` : NUMBER (FK → ORBITE.id_orbite, NOT NULL) - Référence à l'orbite

#### 3. INSTRUMENT
**Description :** Instruments embarqués sur les satellites.

**Attributs :**
- `ref_instrument` : VARCHAR2(15) (PK, NOT NULL) - Référence unique de l'instrument
- `type_instrument` : VARCHAR2(50) (NOT NULL) - Type d'instrument (Caméra optique, Infrarouge, etc.)
- `modele` : VARCHAR2(50) (NOT NULL) - Modèle spécifique
- `resolution` : NUMBER (NULLABLE) - Résolution en mètres (optionnel pour certains types)
- `consommation` : NUMBER (NOT NULL) - Consommation énergétique en W
- `masse` : NUMBER (NOT NULL) - Masse en kg

#### 4. EMBARQUEMENT
**Description :** Association entre satellites et instruments (avec attributs).

**Attributs :**
- `id_satellite` : VARCHAR2(10) (PK, FK → SATELLITE.id_satellite, NOT NULL)
- `ref_instrument` : VARCHAR2(15) (PK, FK → INSTRUMENT.ref_instrument, NOT NULL)
- `date_integration` : DATE (NOT NULL) - Date d'intégration de l'instrument
- `etat_fonctionnement` : VARCHAR2(20) (NOT NULL) - État de fonctionnement (Nominal, Dégradé, Hors service)

#### 5. CENTRE_CONTROLE
**Description :** Centres de contrôle opérationnel.

**Attributs :**
- `id_centre` : NUMBER (PK, NOT NULL) - Identifiant unique du centre
- `nom_centre` : VARCHAR2(50) (NOT NULL) - Nom du centre
- `ville` : VARCHAR2(50) (NOT NULL) - Ville d'implantation
- `region_geo` : VARCHAR2(50) (NOT NULL) - Région géographique
- `fuseau_horaire` : VARCHAR2(50) (NOT NULL) - Fuseau horaire (format IANA)
- `statut` : VARCHAR2(20) (NOT NULL) - Statut du centre (Actif, etc.)

#### 6. STATION_SOL
**Description :** Stations sol pour communications.

**Attributs :**
- `code_station` : VARCHAR2(15) (PK, NOT NULL) - Code unique de la station
- `nom_station` : VARCHAR2(50) (NOT NULL) - Nom de la station
- `latitude` : NUMBER (NOT NULL) - Latitude en degrés
- `longitude` : NUMBER (NOT NULL) - Longitude en degrés
- `diametre_antenne` : NUMBER (NOT NULL) - Diamètre de l'antenne en mètres
- `bande_frequence` : VARCHAR2(10) (NOT NULL) - Bande de fréquence (S, X, etc.)
- `debit_max` : NUMBER (NOT NULL) - Débit maximum en Mbps
- `statut` : VARCHAR2(20) (NOT NULL) - Statut de la station (Active, Maintenance)

#### 7. AFFECTATION_STATION
**Description :** Association entre centres de contrôle et stations sol.

**Attributs :**
- `id_centre` : NUMBER (PK, FK → CENTRE_CONTROLE.id_centre, NOT NULL)
- `code_station` : VARCHAR2(15) (PK, FK → STATION_SOL.code_station, NOT NULL)
- `date_affectation` : DATE (NOT NULL) - Date d'affectation de la station au centre

#### 8. MISSION
**Description :** Missions spatiales.

**Attributs :**
- `id_mission` : VARCHAR2(20) (PK, NOT NULL) - Identifiant unique de la mission
- `nom_mission` : VARCHAR2(50) (NOT NULL) - Nom de la mission
- `objectif` : VARCHAR2(200) (NOT NULL) - Objectif de la mission
- `zone_geo_cible` : VARCHAR2(50) (NOT NULL) - Zone géographique ciblée
- `date_debut` : DATE (NOT NULL) - Date de début de la mission
- `date_fin` : DATE (NULLABLE) - Date de fin (NULL pour missions actives)
- `statut_mission` : VARCHAR2(20) (NOT NULL) - Statut (Active, Terminée)

#### 9. FENETRE_COM
**Description :** Fenêtres de communication entre satellites et stations sol.

**Attributs :**
- `id_fenetre` : NUMBER (PK, NOT NULL) - Identifiant unique de la fenêtre
- `datetime_debut` : TIMESTAMP (NOT NULL) - Date et heure de début
- `duree` : NUMBER (NOT NULL) - Durée en secondes
- `elevation_max` : NUMBER (NOT NULL) - Élévation maximale en degrés
- `volume_donnees` : NUMBER (NULLABLE) - Volume de données transférées en Mo (NULL si planifiée)
- `statut` : VARCHAR2(20) (NOT NULL) - Statut (Réalisée, Planifiée)
- `id_satellite` : VARCHAR2(10) (FK → SATELLITE.id_satellite, NOT NULL)
- `code_station` : VARCHAR2(15) (FK → STATION_SOL.code_station, NOT NULL)

#### 10. PARTICIPATION
**Description :** Participation des satellites aux missions.

**Attributs :**
- `id_satellite` : VARCHAR2(10) (PK, FK → SATELLITE.id_satellite, NOT NULL)
- `id_mission` : VARCHAR2(20) (PK, FK → MISSION.id_mission, NOT NULL)
- `role_satellite` : VARCHAR2(50) (NOT NULL) - Rôle du satellite dans la mission

### Contraintes Supplémentaires Identifiées

- **Clés primaires (PK)** : Définies sur les attributs marqués PK
- **Clés étrangères (FK)** : Définies vers les entités parentes
- **Contraintes de domaine** : 
  - `statut` dans SATELLITE : valeurs limitées (Opérationnel, En veille, Désorbité)
  - `statut` dans FENETRE_COM : (Réalisée, Planifiée)
  - `format_cubesat` : (3U, 6U, 12U)
  - `etat_fonctionnement` : (Nominal, Dégradé, Hors service)
  - `statut_mission` : (Active, Terminée)
  - `statut` dans STATION_SOL : (Active, Maintenance)
  - `statut` dans CENTRE_CONTROLE : (Actif)
  - `bande_frequence` : (S, X)
- **Contraintes temporelles** : Certaines dates peuvent avoir des règles métier (ex: date_lancement < date_integration)

### Remarques
- Les types Oracle sont estimés à partir des données CSV
- Les contraintes NULLABLE sont basées sur la présence de valeurs vides dans les données
- Les règles de gestion détaillées seront analysées à l'étape 2</content>
<parameter name="filePath">/Users/louis.maury/Documents/EFREI/M1 - EFREI/BDD reparties/academy-nanoorbit-project/L1-A_Analyse_Dictionnaire.md