-- ============================================================================
-- ALTN83 NanoOrbit — Phase 2 — Étape 6 : DDL (Création des 11 Tables)
-- ============================================================================
-- Nomenclature : L2-A_DDL_Tables.sql
-- Projet : Bases de données réparties
-- SGBD : Oracle 23ai
-- Schéma : NANOORBIT_ADMIN
-- Données de référence : 43 lignes
-- ============================================================================

-- Suppression des tables existantes (optionnel - décommenter si needed)
-- DROP TABLE PARTICIPATION;
-- DROP TABLE FENETRE_COM;
-- DROP TABLE AFFECTATION_STATION;
-- DROP TABLE EMBARQUEMENT;
-- DROP TABLE MISSION;
-- DROP TABLE STATION_SOL;
-- DROP TABLE CENTRE_CONTROLE;
-- DROP TABLE SATELLITE;
-- DROP TABLE INSTRUMENT;
-- DROP TABLE ORBITE;
-- DROP TABLE HISTORIQUE_STATUT_SATELLITE;

-- ============================================================================
-- TABLE 1 : ORBITE (3 lignes de données)
-- ============================================================================
CREATE TABLE ORBITE (
    id_orbite NUMBER PRIMARY KEY,
    type_orbite VARCHAR2(50) NOT NULL,
    altitude NUMBER NOT NULL,
    inclinaison NUMBER NOT NULL,
    periode_orbitale NUMBER NOT NULL,
    excentricite NUMBER NOT NULL,
    zone_couverture VARCHAR2(100) NOT NULL,
    CONSTRAINT UK_ORBITE_ALT_INCL UNIQUE (altitude, inclinaison)
);

COMMENT ON TABLE ORBITE IS 'Caractéristiques des orbites spatiales — 3 orbites : 2 SSO + 1 LEO';
COMMENT ON COLUMN ORBITE.id_orbite IS 'Identifiant unique de l''orbite';
COMMENT ON COLUMN ORBITE.type_orbite IS 'Type d''orbite (SSO, LEO)';
COMMENT ON COLUMN ORBITE.altitude IS 'Altitude en km';
COMMENT ON COLUMN ORBITE.inclinaison IS 'Inclinaison en degrés';
COMMENT ON COLUMN ORBITE.periode_orbitale IS 'Période orbitale en minutes';
COMMENT ON COLUMN ORBITE.excentricite IS 'Excentricité de l''orbite';
COMMENT ON COLUMN ORBITE.zone_couverture IS 'Zone géographique couverte';

-- ============================================================================
-- TABLE 2 : SATELLITE (5 lignes de données)
-- ============================================================================
CREATE TABLE SATELLITE (
    id_satellite VARCHAR2(10) PRIMARY KEY,
    nom_satellite VARCHAR2(50) NOT NULL,
    date_lancement DATE NOT NULL,
    masse NUMBER NOT NULL,
    format_cubesat VARCHAR2(10) NOT NULL,
    statut VARCHAR2(20) NOT NULL,
    duree_vie_prevue NUMBER NOT NULL,
    capacite_batterie NUMBER NOT NULL,
    id_orbite NUMBER NOT NULL,
    CONSTRAINT FK_SAT_ORBITE FOREIGN KEY (id_orbite) REFERENCES ORBITE(id_orbite),
    CONSTRAINT CK_SAT_STATUT CHECK (statut IN ('Opérationnel', 'En veille', 'Désorbité')),
    CONSTRAINT CK_SAT_FORMAT CHECK (format_cubesat IN ('3U', '6U', '12U'))
);

COMMENT ON TABLE SATELLITE IS 'Satellites NanoOrbit — 5 satellites (3 Opérationnels, 1 En veille, 1 Désorbité)';
COMMENT ON COLUMN SATELLITE.id_satellite IS 'Identifiant unique du satellite (SAT-001 à SAT-005)';
COMMENT ON COLUMN SATELLITE.nom_satellite IS 'Nom commercial du satellite (NanoOrbit-Alpha à Epsilon)';
COMMENT ON COLUMN SATELLITE.statut IS 'Statut opérationnel (Opérationnel, En veille, Désorbité) — pivot RG-F01';

-- ============================================================================
-- TABLE 3 : INSTRUMENT (4 lignes de données)
-- ============================================================================
CREATE TABLE INSTRUMENT (
    ref_instrument VARCHAR2(15) PRIMARY KEY,
    type_instrument VARCHAR2(50) NOT NULL,
    modele VARCHAR2(50) NOT NULL,
    resolution NUMBER,
    consommation NUMBER NOT NULL,
    masse NUMBER NOT NULL
);

COMMENT ON TABLE INSTRUMENT IS 'Instruments embarqués — 4 instruments (Caméra, IR, AIS, Spectro)';
COMMENT ON COLUMN INSTRUMENT.ref_instrument IS 'Référence unique (INS-CAM-01, INS-IR-01, INS-AIS-01, INS-SPEC-01)';
COMMENT ON COLUMN INSTRUMENT.resolution IS 'Résolution en mètres — NULL pour AIS (RG-I01)';

-- ============================================================================
-- TABLE 4 : EMBARQUEMENT (7 lignes de données)
-- ============================================================================
CREATE TABLE EMBARQUEMENT (
    id_satellite VARCHAR2(10) NOT NULL,
    ref_instrument VARCHAR2(15) NOT NULL,
    date_integration DATE NOT NULL,
    etat_fonctionnement VARCHAR2(20) NOT NULL,
    CONSTRAINT PK_EMBARQUEMENT PRIMARY KEY (id_satellite, ref_instrument),
    CONSTRAINT FK_EMB_SATELLITE FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT FK_EMB_INSTRUMENT FOREIGN KEY (ref_instrument) REFERENCES INSTRUMENT(ref_instrument),
    CONSTRAINT CK_EMB_ETAT CHECK (etat_fonctionnement IN ('Nominal', 'Dégradé', 'Hors service'))
);

COMMENT ON TABLE EMBARQUEMENT IS 'Association SATELLITE ↔ INSTRUMENT avec attributs — 7 relations';

-- ============================================================================
-- TABLE 5 : CENTRE_CONTROLE (3 lignes de données)
-- ============================================================================
CREATE TABLE CENTRE_CONTROLE (
    id_centre NUMBER PRIMARY KEY,
    nom_centre VARCHAR2(50) NOT NULL,
    ville VARCHAR2(50) NOT NULL,
    region_geo VARCHAR2(50) NOT NULL,
    fuseau_horaire VARCHAR2(50) NOT NULL,
    statut VARCHAR2(20) NOT NULL
);

COMMENT ON TABLE CENTRE_CONTROLE IS 'Centres de contrôle répartis — 3 centres (Paris, Houston, Singapour)';
COMMENT ON COLUMN CENTRE_CONTROLE.fuseau_horaire IS 'Fuseau horaire IANA (Europe/Paris, America/Chicago, Asia/Singapore)';

-- ============================================================================
-- TABLE 6 : STATION_SOL (3 lignes de données)
-- ============================================================================
CREATE TABLE STATION_SOL (
    code_station VARCHAR2(15) PRIMARY KEY,
    nom_station VARCHAR2(50) NOT NULL,
    latitude NUMBER NOT NULL,
    longitude NUMBER NOT NULL,
    diametre_antenne NUMBER NOT NULL,
    bande_frequence VARCHAR2(10) NOT NULL,
    debit_max NUMBER NOT NULL,
    statut VARCHAR2(20) NOT NULL,
    CONSTRAINT CK_STATION_BANDE CHECK (bande_frequence IN ('S', 'X', 'Ku', 'Ka')),
    CONSTRAINT CK_STATION_STATUT CHECK (statut IN ('Active', 'Maintenance', 'Hors service'))
);

COMMENT ON TABLE STATION_SOL IS 'Stations sol — 3 stations (GS-TLS-01 Active, GS-KIR-01 Active, GS-SGP-01 Maintenance)';
COMMENT ON COLUMN STATION_SOL.statut IS 'Statut de la station — pivot RG-F01 (Maintenance bloque fenêtres)';

-- ============================================================================
-- TABLE 7 : AFFECTATION_STATION (3 lignes de données)
-- ============================================================================
CREATE TABLE AFFECTATION_STATION (
    id_centre NUMBER NOT NULL,
    code_station VARCHAR2(15) NOT NULL,
    date_affectation DATE NOT NULL,
    CONSTRAINT PK_AFFECTATION PRIMARY KEY (id_centre, code_station),
    CONSTRAINT FK_AFF_CENTRE FOREIGN KEY (id_centre) REFERENCES CENTRE_CONTROLE(id_centre),
    CONSTRAINT FK_AFF_STATION FOREIGN KEY (code_station) REFERENCES STATION_SOL(code_station)
);

COMMENT ON TABLE AFFECTATION_STATION IS 'Association CENTRE_CONTROLE ↔ STATION_SOL — 3 relations';

-- ============================================================================
-- TABLE 8 : MISSION (3 lignes de données)
-- ============================================================================
CREATE TABLE MISSION (
    id_mission VARCHAR2(20) PRIMARY KEY,
    nom_mission VARCHAR2(50) NOT NULL,
    objectif VARCHAR2(200) NOT NULL,
    zone_geo_cible VARCHAR2(50) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE,
    statut_mission VARCHAR2(20) NOT NULL,
    CONSTRAINT CK_MISSION_STATUT CHECK (statut_mission IN ('Active', 'Terminée', 'Planifiée')),
    CONSTRAINT CK_MISSION_DATES CHECK (date_fin IS NULL OR date_fin >= date_debut)
);

COMMENT ON TABLE MISSION IS 'Missions spatiales — 3 missions (2 Active, 1 Terminée)';
COMMENT ON COLUMN MISSION.statut_mission IS 'Statut mission — pivot RG-M01 (Terminée bloque participation)';

-- ============================================================================
-- TABLE 9 : PARTICIPATION (7 lignes de données)
-- ============================================================================
CREATE TABLE PARTICIPATION (
    id_satellite VARCHAR2(10) NOT NULL,
    id_mission VARCHAR2(20) NOT NULL,
    role_satellite VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_PARTICIPATION PRIMARY KEY (id_satellite, id_mission),
    CONSTRAINT FK_PART_SATELLITE FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT FK_PART_MISSION FOREIGN KEY (id_mission) REFERENCES MISSION(id_mission)
);

COMMENT ON TABLE PARTICIPATION IS 'Association SATELLITE ↔ MISSION — 7 relations';

-- ============================================================================
-- TABLE 10 : FENETRE_COM (5 lignes de données)
-- ============================================================================
CREATE TABLE FENETRE_COM (
    id_fenetre NUMBER PRIMARY KEY,
    datetime_debut TIMESTAMP NOT NULL,
    duree NUMBER NOT NULL,
    elevation_max NUMBER NOT NULL,
    volume_donnees NUMBER,
    statut VARCHAR2(20) NOT NULL,
    id_satellite VARCHAR2(10) NOT NULL,
    code_station VARCHAR2(15) NOT NULL,
    CONSTRAINT FK_FENETRE_SATELLITE FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT FK_FENETRE_STATION FOREIGN KEY (code_station) REFERENCES STATION_SOL(code_station),
    CONSTRAINT CK_FENETRE_STATUT CHECK (statut IN ('Réalisée', 'Planifiée')),
    CONSTRAINT CK_FENETRE_DUREE CHECK (duree BETWEEN 1 AND 900),
    CONSTRAINT CK_FENETRE_ELEVATION CHECK (elevation_max BETWEEN 0 AND 90),
    CONSTRAINT CK_FENETRE_VOLUME_REALISE CHECK ((statut = 'Réalisée' AND volume_donnees IS NOT NULL) OR (statut = 'Planifiée' AND volume_donnees IS NULL))
);

COMMENT ON TABLE FENETRE_COM IS 'Association SATELLITE ↔ STATION_SOL — 5 fenêtres (3 Réalisées + 2 Planifiées)';
COMMENT ON COLUMN FENETRE_COM.duree IS 'Durée en secondes (1-900) — RG-F04';
COMMENT ON COLUMN FENETRE_COM.statut IS 'Statut (Réalisée, Planifiée) — volume_donnees règle RG-F05';

-- ============================================================================
-- TABLE 11 : HISTORIQUE_STATUT_SATELLITE (pour trigger RG-S01)
-- ============================================================================
CREATE TABLE HISTORIQUE_STATUT_SATELLITE (
    id_historique NUMBER PRIMARY KEY,
    id_satellite VARCHAR2(10) NOT NULL,
    ancien_statut VARCHAR2(20),
    nouveau_statut VARCHAR2(20) NOT NULL,
    date_changement TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_HIST_SATELLITE FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite)
);

COMMENT ON TABLE HISTORIQUE_STATUT_SATELLITE IS 'Traçabilité des changements de statut satellite — trigger RG-S01';

CREATE SEQUENCE seq_historique_statut START WITH 1;

-- ============================================================================
-- VÉRIFICATIONS POST-CRÉATION
-- ============================================================================
COMMIT;

-- Listing des tables créées
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN ('ORBITE', 'SATELLITE', 'INSTRUMENT', 'EMBARQUEMENT', 
                      'CENTRE_CONTROLE', 'STATION_SOL', 'AFFECTATION_STATION',
                      'MISSION', 'PARTICIPATION', 'FENETRE_COM', 'HISTORIQUE_STATUT_SATELLITE')
ORDER BY table_name;
