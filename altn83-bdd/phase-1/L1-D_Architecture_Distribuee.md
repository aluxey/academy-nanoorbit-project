# Livrable L1-D : Architecture Distribuée

## Étape 5 : Architecture des Bases de Données Réparties

### Contexte du Système Distribué

Le système NanoOrbit comprend 3 centres de contrôle répartis géographiquement :
- **Paris** (Europe)
- **Houston** (Amériques) 
- **Singapour** (Asie-Pacifique)

Chaque centre gère ses propres stations sol et doit pouvoir fonctionner de manière autonome tout en partageant des données globales sur les satellites et missions.

### Q1 : Tables Locales

Tables stockées localement sur chaque site (centre de contrôle) :

#### CENTRE_CONTROLE
- **Localité** : Une seule ligne par site (le centre lui-même)
- **Raison** : Données spécifiques au centre local
- **Opérations** : Lectures/écritures locales uniquement

#### STATION_SOL
- **Localité** : Stations affectées au centre local
- **Raison** : Chaque centre gère ses propres stations
- **Opérations** : Gestion des équipements locaux

#### AFFECTATION_STATION
- **Localité** : Affectations des stations au centre local
- **Raison** : Relation centre-stations locale
- **Opérations** : Maintenance des affectations locales

#### FENETRE_COM
- **Localité** : Communications passant par les stations locales
- **Raison** : Les fenêtres de communication sont gérées par station
- **Opérations** : Planification et suivi des communications locales

### Q2 : Tables Globales

Tables répliquées sur tous les sites avec synchronisation :

#### ORBITE
- **Distribution** : Répliquée sur tous les sites
- **Raison** : Caractéristiques orbitales partagées
- **Stratégie** : Réplication complète (faible volumétrie)

#### SATELLITE
- **Distribution** : Répliquée sur tous les sites
- **Raison** : Flotte satellitaire globale
- **Stratégie** : Réplication complète avec mise à jour propagée

#### INSTRUMENT
- **Distribution** : Répliquée sur tous les sites
- **Raison** : Catalogue d'instruments commun
- **Stratégie** : Réplication complète

#### MISSION
- **Distribution** : Répliquée sur tous les sites
- **Raison** : Missions coordonnées globalement
- **Stratégie** : Réplication complète

#### EMBARQUEMENT
- **Distribution** : Répliquée sur tous les sites
- **Raison** : Configuration satellitaire globale
- **Stratégie** : Réplication complète

#### PARTICIPATION
- **Distribution** : Répliquée sur tous les sites
- **Raison** : Affectation satellites-missions globale
- **Stratégie** : Réplication complète

### Q3 : Fonctionnement Offline

#### Capacité d'Opération Déconnectée

**Oui, partiellement possible** pour les opérations locales :

##### Opérations Possibles Offline :
- **Gestion des stations locales** : Maintenance, configuration
- **Planification communications locales** : Fenêtres utilisant stations locales
- **Consultation données globales** : Lecture des données répliquées (satellites, missions)
- **Rapports locaux** : Analyses sur données disponibles

##### Limites du Mode Offline :
- **Pas de modifications globales** : Impossible de changer statut satellite ou mission
- **Pas de communications inter-sites** : Coordination entre centres
- **Données potentiellement obsolètes** : Réplication différée des mises à jour

##### Durée Maximale Offline :
- **48-72 heures** selon criticité des opérations
- **Synchronisation automatique** à la reconnexion

### Q4 : Problèmes de Cohérence

#### Problèmes Identifiés

##### 1. Cohérence des Données Répliquées
- **Conflits de mise à jour** : Changement simultané du statut d'un satellite sur deux sites
- **Solution** : Stratégie "last-write-wins" ou résolution manuelle pour statuts critiques

##### 2. Chevauchement des Fenêtres de Communication
- **Problème** : Deux centres planifient des communications simultanées pour le même satellite
- **Impact** : Conflit de ressources satellitaires
- **Solution** : Verrouillage distribué ou validation centralisée

##### 3. Cohérence Temporelle
- **Problème** : Différences de fuseaux horaires entre centres
- **Impact** : Fenêtres de communication mal synchronisées
- **Solution** : Stockage en UTC, conversion locale à l'affichage

##### 4. Isolation des Transactions Distribuées
- **Problème** : Transactions modifiant données locales et globales
- **Impact** : Risque d'inconsistance en cas de panne réseau
- **Solution** : Protocole de commit en deux phases (2PC)

##### 5. Performance de Réplication
- **Problème** : Latence réseau inter-continentale
- **Impact** : Délai de propagation des mises à jour critiques
- **Solution** : Réplication asynchrone avec priorité des mises à jour

#### Stratégies de Résolution

- **Réplication multi-maîtres** pour les données globales
- **Partitionnement horizontal** pour les données locales
- **Mécanismes de notification** pour les changements critiques
- **Logs d'audit distribués** pour traçabilité

Cette architecture assure l'autonomie locale tout en maintenant la cohérence globale du système NanoOrbit.</content>
<parameter name="filePath">/Users/louis.maury/Documents/EFREI/M1 - EFREI/BDD reparties/academy-nanoorbit-project/L1-D_Architecture_Distribuee.md