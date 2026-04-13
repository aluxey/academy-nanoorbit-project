-- ============================================================================
-- NanoOrbit - Phase 2 - Livrable L2-A
-- Fichier : L2-A_DDL_Tables.sql
-- Objet   : DDL complet (10 tables NanoOrbit + 1 table de traçabilite)
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

-- Ordre de creation impose par les dependances FK :
-- 1 ORBITE
-- 2 SATELLITE (FK ORBITE)
-- + HISTORIQUE_STATUT (annexe technique pour T5, apres SATELLITE)
-- 3 INSTRUMENT
-- 4 EMBARQUEMENT (FK SATELLITE, INSTRUMENT)
-- 5 CENTRE_CONTROLE
-- 6 STATION_SOL
-- 7 AFFECTATION_STATION (FK CENTRE_CONTROLE, STATION_SOL)
-- 8 MISSION
-- 9 FENETRE_COM (FK SATELLITE, STATION_SOL)
-- 10 PARTICIPATION (FK SATELLITE, MISSION)

-- Q1
-- SATELLITE ne peut pas etre cree avant ORBITE car SATELLITE.id_orbite reference
-- ORBITE.id_orbite. Cela traduit la regle de gestion : un satellite doit toujours
-- etre rattache a une orbite existante (integrite referentielle).
--
-- Q2
-- La regle RG-S06 (satellite desorbite bloque) n'est pas exprimable en DDL pur
-- car elle depend d'un etat metier dynamique. Solution : trigger BEFORE INSERT
-- (FENETRE_COM) et BEFORE INSERT (PARTICIPATION / selon regles ciblees).
--
-- Q3
-- RG-F02 (pas de chevauchement temporel) n'est pas exprimable en CHECK car CHECK
-- ne compare pas une ligne avec les autres lignes de la table. Solution : trigger
-- BEFORE INSERT OR UPDATE sur FENETRE_COM.
--
-- Q4
-- format_cubesat est stocke en VARCHAR2(4) avec CHECK sur ('1U','3U','6U','12U').
-- Ce domaine est stable, petit et textuel ; VARCHAR2 + CHECK est le choix Oracle
-- le plus simple et lisible.

-- ==========================================================================
-- Nettoyage (optionnel)
-- ==========================================================================
-- DROP TABLE PARTICIPATION;
-- DROP TABLE FENETRE_COM;
-- DROP TABLE AFFECTATION_STATION;
-- DROP TABLE EMBARQUEMENT;
-- DROP TABLE MISSION;
-- DROP TABLE STATION_SOL;
-- DROP TABLE CENTRE_CONTROLE;
-- DROP TABLE INSTRUMENT;
-- DROP TABLE HISTORIQUE_STATUT;
-- DROP TABLE SATELLITE;
-- DROP TABLE ORBITE;

-- ==========================================================================
-- 1) ORBITE
-- ==========================================================================
CREATE TABLE ORBITE (
    id_orbite           NUMBER(3)       CONSTRAINT pk_orbite PRIMARY KEY,
    type_orbite         VARCHAR2(20)    NOT NULL,
    altitude            NUMBER(7,2)     NOT NULL,
    inclinaison         NUMBER(5,2)     NOT NULL,
    periode_orbitale    NUMBER(6,2)     NOT NULL,
    excentricite        NUMBER(8,6)     NOT NULL,
    zone_couverture     VARCHAR2(120)   NOT NULL,
    CONSTRAINT uk_orbite_alt_incl UNIQUE (altitude, inclinaison)
);

-- ==========================================================================
-- 2) SATELLITE
-- ==========================================================================
CREATE TABLE SATELLITE (
    id_satellite         VARCHAR2(10)   CONSTRAINT pk_satellite PRIMARY KEY,
    nom_satellite        VARCHAR2(60)   NOT NULL,
    date_lancement       DATE           NOT NULL,
    masse                NUMBER(6,2)    NOT NULL,
    format_cubesat       VARCHAR2(4)    NOT NULL,
    statut               VARCHAR2(20)   NOT NULL,
    duree_vie_prevue     NUMBER(4)      NOT NULL,
    capacite_batterie    NUMBER(6,2)    NOT NULL,
    id_orbite            NUMBER(3)      NOT NULL,
    CONSTRAINT fk_sat_orbite FOREIGN KEY (id_orbite) REFERENCES ORBITE(id_orbite),
    CONSTRAINT ck_sat_format CHECK (format_cubesat IN ('1U', '3U', '6U', '12U')),
    CONSTRAINT ck_sat_statut CHECK (statut IN ('Operationnel', 'Opérationnel', 'En veille', 'Defaillant', 'Défaillant', 'Désorbité', 'Desorbite'))
);

-- ==========================================================================
-- Table technique annexe demandee en 2.4 (necessaire au trigger T5)
-- ==========================================================================
CREATE TABLE HISTORIQUE_STATUT (
    id_historique      NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_historique_statut PRIMARY KEY,
    id_satellite       VARCHAR2(10)   NOT NULL,
    ancien_statut      VARCHAR2(20),
    nouveau_statut     VARCHAR2(20)   NOT NULL,
    date_changement    TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    motif              VARCHAR2(200),
    CONSTRAINT fk_hist_sat FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite)
);

-- ==========================================================================
-- 3) INSTRUMENT
-- ==========================================================================
CREATE TABLE INSTRUMENT (
    ref_instrument      VARCHAR2(15)   CONSTRAINT pk_instrument PRIMARY KEY,
    type_instrument     VARCHAR2(50)   NOT NULL,
    modele              VARCHAR2(50)   NOT NULL,
    resolution          NUMBER(10,2),
    consommation        NUMBER(6,2)    NOT NULL,
    masse               NUMBER(6,2)    NOT NULL
);

-- ==========================================================================
-- 4) EMBARQUEMENT
-- ==========================================================================
CREATE TABLE EMBARQUEMENT (
    id_satellite          VARCHAR2(10)  NOT NULL,
    ref_instrument        VARCHAR2(15)  NOT NULL,
    date_integration      DATE          NOT NULL,
    etat_fonctionnement   VARCHAR2(20)  NOT NULL,
    CONSTRAINT pk_embarquement PRIMARY KEY (id_satellite, ref_instrument),
    CONSTRAINT fk_emb_sat FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT fk_emb_ins FOREIGN KEY (ref_instrument) REFERENCES INSTRUMENT(ref_instrument),
    CONSTRAINT ck_emb_etat CHECK (etat_fonctionnement IN ('Nominal', 'Dégradé', 'Degrade', 'Hors service'))
);

-- ==========================================================================
-- 5) CENTRE_CONTROLE
-- ==========================================================================
CREATE TABLE CENTRE_CONTROLE (
    id_centre         NUMBER(3)       CONSTRAINT pk_centre PRIMARY KEY,
    nom_centre        VARCHAR2(80)    NOT NULL,
    ville             VARCHAR2(50)    NOT NULL,
    region_geo        VARCHAR2(60)    NOT NULL,
    fuseau_horaire    VARCHAR2(40)    NOT NULL,
    statut            VARCHAR2(20)    NOT NULL,
    CONSTRAINT ck_centre_statut CHECK (statut IN ('Actif', 'Inactif'))
);

-- ==========================================================================
-- 6) STATION_SOL
-- ==========================================================================
CREATE TABLE STATION_SOL (
    code_station         VARCHAR2(15)   CONSTRAINT pk_station PRIMARY KEY,
    nom_station          VARCHAR2(80)   NOT NULL,
    latitude             NUMBER(8,4)    NOT NULL,
    longitude            NUMBER(8,4)    NOT NULL,
    diametre_antenne     NUMBER(5,2)    NOT NULL,
    bande_frequence      VARCHAR2(10)   NOT NULL,
    debit_max            NUMBER(8,2)    NOT NULL,
    statut               VARCHAR2(20)   NOT NULL,
    CONSTRAINT ck_station_bande CHECK (bande_frequence IN ('S', 'X', 'Ku', 'Ka')),
    CONSTRAINT ck_station_statut CHECK (statut IN ('Active', 'Maintenance', 'Hors service'))
);

-- ==========================================================================
-- 7) AFFECTATION_STATION
-- ==========================================================================
CREATE TABLE AFFECTATION_STATION (
    id_centre           NUMBER(3)      NOT NULL,
    code_station        VARCHAR2(15)   NOT NULL,
    date_affectation    DATE           NOT NULL,
    CONSTRAINT pk_affectation_station PRIMARY KEY (id_centre, code_station),
    CONSTRAINT fk_aff_centre FOREIGN KEY (id_centre) REFERENCES CENTRE_CONTROLE(id_centre),
    CONSTRAINT fk_aff_station FOREIGN KEY (code_station) REFERENCES STATION_SOL(code_station)
);

-- ==========================================================================
-- 8) MISSION
-- ==========================================================================
CREATE TABLE MISSION (
    id_mission          VARCHAR2(20)   CONSTRAINT pk_mission PRIMARY KEY,
    nom_mission         VARCHAR2(80)   NOT NULL,
    objectif            VARCHAR2(300)  NOT NULL,
    zone_geo_cible      VARCHAR2(100)  NOT NULL,
    date_debut          DATE           NOT NULL,
    date_fin            DATE,
    statut_mission      VARCHAR2(20)   NOT NULL,
    CONSTRAINT ck_mission_statut CHECK (statut_mission IN ('Active', 'Terminée', 'Terminee', 'Planifiée', 'Planifiee')),
    CONSTRAINT ck_mission_dates CHECK (date_fin IS NULL OR date_fin >= date_debut)
);

-- ==========================================================================
-- 9) FENETRE_COM
-- ==========================================================================
CREATE TABLE FENETRE_COM (
    id_fenetre         NUMBER(6)      CONSTRAINT pk_fenetre PRIMARY KEY,
    datetime_debut     TIMESTAMP      NOT NULL,
    duree              NUMBER(4)      NOT NULL,
    elevation_max      NUMBER(5,2)    NOT NULL,
    volume_donnees     NUMBER(12,2),
    statut             VARCHAR2(20)   NOT NULL,
    id_satellite       VARCHAR2(10)   NOT NULL,
    code_station       VARCHAR2(15)   NOT NULL,
    CONSTRAINT fk_fen_sat FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT fk_fen_station FOREIGN KEY (code_station) REFERENCES STATION_SOL(code_station),
    CONSTRAINT ck_fen_duree CHECK (duree BETWEEN 1 AND 900),
    CONSTRAINT ck_fen_elevation CHECK (elevation_max BETWEEN 0 AND 90),
    CONSTRAINT ck_fen_statut CHECK (statut IN ('Réalisée', 'Realisee', 'Planifiée', 'Planifiee')),
    CONSTRAINT ck_fen_volume_statut CHECK (
        (statut IN ('Réalisée', 'Realisee') AND volume_donnees IS NOT NULL) OR
        (statut IN ('Planifiée', 'Planifiee') AND volume_donnees IS NULL)
    )
);

-- ==========================================================================
-- 10) PARTICIPATION
-- ==========================================================================
CREATE TABLE PARTICIPATION (
    id_satellite      VARCHAR2(10)   NOT NULL,
    id_mission        VARCHAR2(20)   NOT NULL,
    role_satellite    VARCHAR2(80)   NOT NULL,
    CONSTRAINT pk_participation PRIMARY KEY (id_satellite, id_mission),
    CONSTRAINT fk_part_sat FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT fk_part_mission FOREIGN KEY (id_mission) REFERENCES MISSION(id_mission)
);

-- ==========================================================================
-- Verification rapide
-- ==========================================================================
SELECT table_name
FROM user_tables
WHERE table_name IN (
    'ORBITE', 'SATELLITE', 'HISTORIQUE_STATUT', 'INSTRUMENT', 'EMBARQUEMENT',
    'CENTRE_CONTROLE', 'STATION_SOL', 'AFFECTATION_STATION', 'MISSION',
    'FENETRE_COM', 'PARTICIPATION'
)
ORDER BY table_name;
