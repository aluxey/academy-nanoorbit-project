# Livrable L1-B : Classification des Règles de Gestion

## Étape 2 : Classification des Règles de Gestion

### Méthodologie de Classification

Les règles de gestion (RG-*) sont classées selon leur nature d'implémentation :

1. **Structure** : Contraintes intégrées au schéma relationnel (PK, FK, UNIQUE)
2. **Contrainte simple** : CHECK, NOT NULL, domaines de valeurs
3. **Procédural** : Triggers ou procédures PL/SQL

### Règles Identifiées et Classifiées

#### Règles Structurelles (Schéma Relationnel)

**RG-O02** : Unicité de la combinaison altitude + inclinaison dans ORBITE
- **Type** : Structure
- **Implémentation** : UNIQUE (altitude, inclinaison) sur table ORBITE
- **Justification** : Deux orbites ne peuvent avoir les mêmes paramètres physiques

#### Règles de Contraintes Simples

**RG-F04** : Durée des fenêtres de communication entre 1 et 900 secondes
- **Type** : Contrainte simple
- **Implémentation** : CHECK (duree BETWEEN 1 AND 900) sur FENETRE_COM
- **Justification** : Limites techniques des communications

**RG-S03** : Statut satellite limité aux valeurs autorisées
- **Type** : Contrainte simple
- **Implémentation** : CHECK (statut IN ('Opérationnel', 'En veille', 'Désorbité')) sur SATELLITE
- **Justification** : Contrôle du domaine des valeurs

**RG-M02** : Statut mission limité
- **Type** : Contrainte simple
- **Implémentation** : CHECK (statut_mission IN ('Active', 'Terminée')) sur MISSION
- **Justification** : États possibles des missions

**RG-I01** : Résolution optionnelle pour certains instruments
- **Type** : Contrainte simple
- **Implémentation** : NULLABLE sur resolution dans INSTRUMENT
- **Justification** : Certains types d'instruments n'ont pas de résolution définie

**RG-F05** : Volume de données NULL pour fenêtres planifiées
- **Type** : Contrainte simple
- **Implémentation** : CHECK ((statut = 'Réalisée' AND volume_donnees IS NOT NULL) OR (statut = 'Planifiée' AND volume_donnees IS NULL)) sur FENETRE_COM
- **Justification** : Données disponibles seulement après réalisation

#### Règles Procédurales (Triggers PL/SQL)

**RG-F01** : Interdiction de fenêtre de communication si satellite désorbité ou station en maintenance
- **Type** : Procédural
- **Implémentation** : Trigger BEFORE INSERT sur FENETRE_COM
- **Code erreur** : ORA-20001 / ORA-20002
- **Justification** : Vérification dynamique des statuts opérationnels

**RG-F02** : Pas de chevauchement temporel des fenêtres de communication
- **Type** : Procédural
- **Implémentation** : Trigger BEFORE INSERT/UPDATE sur FENETRE_COM
- **Code erreur** : ORA-20003
- **Justification** : Évite les conflits de ressources de communication

**RG-F03** : Correction automatique du volume de données pour fenêtres non réalisées
- **Type** : Procédural
- **Implémentation** : Trigger BEFORE INSERT/UPDATE sur FENETRE_COM (correction silencieuse)
- **Justification** : Maintien de la cohérence des données

**RG-M01** : Interdiction de participation à une mission terminée
- **Type** : Procédural
- **Implémentation** : Trigger BEFORE INSERT sur PARTICIPATION
- **Code erreur** : ORA-20004
- **Justification** : Contrôle temporel des affectations

**RG-S01** : Historique automatique des changements de statut satellite
- **Type** : Procédural
- **Implémentation** : Trigger AFTER UPDATE sur statut de SATELLITE
- **Justification** : Traçabilité des changements opérationnels

### Analyse par Entité

#### ORBITE
- Structurelles : RG-O02 (unicité altitude+inclinaison)

#### SATELLITE
- Simples : RG-S03 (domaine statut)
- Procédurales : RG-S01 (historique statut)

#### INSTRUMENT
- Simples : RG-I01 (résolution nullable)

#### MISSION
- Simples : RG-M02 (domaine statut_mission)
- Procédurales : RG-M01 (participation missions terminées)

#### FENETRE_COM
- Simples : RG-F04 (durée), RG-F05 (volume selon statut)
- Procédurales : RG-F01 (statuts opérationnels), RG-F02 (chevauchement), RG-F03 (correction volume)

#### Autres Entités
- CENTRE_CONTROLE, STATION_SOL, AFFECTATION_STATION, EMBARQUEMENT, PARTICIPATION : Règles principalement structurelles (PK/FK)

### Implications pour l'Implémentation

- **Phase 2 (DDL)** : Implémenter les contraintes structurelles et simples
- **Phase 2 (Triggers)** : Coder les 5 triggers pour les règles procédurales
- **Phase 3 (PL/SQL)** : Éventuelles procédures supplémentaires si needed

Cette classification permet de planifier précisément l'implémentation technique.</content>
<parameter name="filePath">/Users/louis.maury/Documents/EFREI/M1 - EFREI/BDD reparties/academy-nanoorbit-project/L1-B_Classification_Regles.md