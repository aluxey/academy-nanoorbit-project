# Livrable L1-B : Modèle Conceptuel de Données (MCD)

## Étape 3 : Construction du MCD MERISE

### Entités Identifiées

Le MCD comprend les entités suivantes, extraites du dictionnaire et des données :

- **ORBITE** : Caractéristiques des orbites spatiales
- **SATELLITE** : Satellites NanoOrbit
- **INSTRUMENT** : Instruments embarqués
- **CENTRE_CONTROLE** : Centres de contrôle opérationnel
- **STATION_SOL** : Stations de réception au sol
- **MISSION** : Missions spatiales
- **EMBARQUEMENT** : Association satellite-instrument (avec attributs)
- **PARTICIPATION** : Association satellite-mission (avec attributs)
- **AFFECTATION_STATION** : Association centre-station
- **FENETRE_COM** : Association satellite-station pour communications

### Associations et Cardinalités

#### Associations Binaires

1. **suit** (SATELLITE → ORBITE)
   - Cardinalité : N-1
   - Un satellite suit une seule orbite, une orbite peut être suivie par plusieurs satellites

2. **embarque** (SATELLITE ↔ INSTRUMENT via EMBARQUEMENT)
   - Cardinalité : N-M
   - Un satellite embarque plusieurs instruments, un instrument peut être embarqué sur plusieurs satellites
   - **Attributs de l'association** : date_integration, etat_fonctionnement

3. **participe** (SATELLITE ↔ MISSION via PARTICIPATION)
   - Cardinalité : N-M
   - Un satellite participe à plusieurs missions, une mission implique plusieurs satellites
   - **Attributs de l'association** : role_satellite

4. **affecte** (CENTRE_CONTROLE ↔ STATION_SOL via AFFECTATION_STATION)
   - Cardinalité : N-M
   - Un centre contrôle plusieurs stations, une station peut être affectée à plusieurs centres
   - **Attributs de l'association** : date_affectation

5. **communique** (SATELLITE ↔ STATION_SOL via FENETRE_COM)
   - Cardinalité : N-M
   - Un satellite communique avec plusieurs stations, une station communique avec plusieurs satellites
   - **Attributs de l'association** : datetime_debut, duree, elevation_max, volume_donnees, statut

### Attributs par Entité

Voir le diagramme Mermaid ci-dessous pour la visualisation complète.

### Diagramme MCD

```mermaid
erDiagram
    ORBITE ||--o{ SATELLITE : suit
    SATELLITE }o--|| INSTRUMENT : embarque
    SATELLITE }o--|| MISSION : participe
    CENTRE_CONTROLE }o--|| STATION_SOL : affecte
    SATELLITE }o--|| STATION_SOL : communique

    ORBITE {
        number id_orbite PK
        string type_orbite
        number altitude
        number inclinaison
        number periode_orbitale
        number excentricite
        string zone_couverture
    }

    SATELLITE {
        string id_satellite PK
        string nom_satellite
        date date_lancement
        number masse
        string format_cubesat
        string statut
        number duree_vie_prevue
        number capacite_batterie
        number id_orbite FK
    }

    INSTRUMENT {
        string ref_instrument PK
        string type_instrument
        string modele
        number resolution
        number consommation
        number masse
    }

    MISSION {
        string id_mission PK
        string nom_mission
        string objectif
        string zone_geo_cible
        date date_debut
        date date_fin
        string statut_mission
    }

    CENTRE_CONTROLE {
        number id_centre PK
        string nom_centre
        string ville
        string region_geo
        string fuseau_horaire
        string statut
    }

    STATION_SOL {
        string code_station PK
        string nom_station
        number latitude
        number longitude
        number diametre_antenne
        string bande_frequence
        number debit_max
        string statut
    }

    EMBARQUEMENT {
        string id_satellite PK,FK
        string ref_instrument PK,FK
        date date_integration
        string etat_fonctionnement
    }

    PARTICIPATION {
        string id_satellite PK,FK
        string id_mission PK,FK
        string role_satellite
    }

    AFFECTATION_STATION {
        number id_centre PK,FK
        string code_station PK,FK
        date date_affectation
    }

    FENETRE_COM {
        number id_fenetre PK
        timestamp datetime_debut
        number duree
        number elevation_max
        number volume_donnees
        string statut
        string id_satellite FK
        string code_station FK
    }
```

### Points Critiques Respectés

- ✅ **EMBARQUEMENT** : Modélisé comme association avec attributs (date_integration, etat_fonctionnement)
- ✅ **PARTICIPATION** : Association avec attribut (role_satellite)
- ✅ **FENETRE_COM** : Relation entre satellite et station sol
- ✅ **CENTRE_CONTROLE ↔ STATION_SOL** : Association via AFFECTATION_STATION

### Validation du MCD

- **Normalisation** : Toutes les entités sont en 1NF (attributs atomiques)
- **Dépendances** : Les FK sont correctement identifiées
- **Cardinalités** : Basées sur l'analyse des données CSV
- **Cohérence** : Le modèle couvre tous les cas d'usage identifiés</content>
<parameter name="filePath">/Users/louis.maury/Documents/EFREI/M1 - EFREI/BDD reparties/academy-nanoorbit-project/L1-B_MCD.md