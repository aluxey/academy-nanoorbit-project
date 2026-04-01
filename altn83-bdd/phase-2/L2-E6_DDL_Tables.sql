-- ============================================================================
-- ALTN83 NanoOrbit — Phase 2 — Étape 6 : DDL (Création des 10 Tables)
-- ============================================================================
-- Projet : Bases de données réparties
-- SGBD : Oracle 23ai
-- Schéma : NANOORBIT_ADMIN
-- ============================================================================

-- Suppression des tables existantes (optionnel - décommenter si needed)
-- DROP TABLE PARTICIPATION;
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

-- ============================================================================
-- TABLE 1 : ORBITE (pas de FK)
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

COMMENT ON TABLE ORBITE IS 'Caractéristiques des orbites spatiales (RG-O02)';
COMMENT ON COLUMN ORBITE.id_orbite IS 'Identifiant unique de l''orbite';
COMMENT ON COLUMN ORBITE.type_orbite IS 'Type d''orbite (SSO, LEO, GEO, etc.)';
COMMENT ON COLUMN ORBITE.altitude IS 'Altitude en km';
COMMENT ON COLUMN ORBITE.inclinaison IS 'Inclinaison en degrés';
COMMENT ON COLUMN ORBITE.periode_orbitale IS 'Période orbitale en minutes';
COMMENT ON COLUMN ORBITE.excentricite IS 'Excentricité de l''orbite';
COMMENT ON COLUMN ORBITE.zone_couverture IS 'Zone géographique couverte';

-- ============================================================================
-- TABLE 2 : SATELLITE (FK vers ORBITE)
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

COMMENT ON TABLE SATELLITE IS 'Satellites NanoOrbit et leurs caractéristiques (RG-S03)';
COMMENT ON COLUMN SATELLITE.id_satellite IS 'Identifiant unique du satellite (ex: SAT-001)';
COMMENT ON COLUMN SATELLITE.nom_satellite IS 'Nom commercial du satellite';
COMMENT ON COLUMN SATELLITE.date_lancement IS 'Date de lancement';
COMMENT ON COLUMN SATELLITE.statut IS 'Statut opérationnel (Opérationnel, En veille, Désorbité)';
COMMENT ON COLUMN SATELLITE.format_cubesat IS 'Format CubeSat (3U, 6U, 12U)';

-- ============================================================================
-- TABLE 3 : INSTRUMENT (pas de FK)
-- ============================================================================
CREATE TABLE INSTRUMENT (
    ref_instrument VARCHAR2(15) PRIMARY KEY,
    type_instrument VARCHAR2(50) NOT NULL,
    modele VARCHAR2(50) NOT NULL,
    resolution NUMBER,
    consommation NUMBER NOT NULL,
    masse NUMBER NOT NULL
);

COMMENT ON TABLE INSTRUMENT IS 'Instruments embarqués sur les satellites (RG-I01: résolution nullable)';
COMMENT ON COLUMN INSTRUMENT.ref_instrument IS 'Référence unique de l''instrument';
COMMENT ON COLUMN INSTRUMENT.type_instrument IS 'Type d''instrument (Caméra optique, Infrarouge, Récepteur AIS, Spectromètre)';
COMMENT ON COLUMN INSTRUMENT.resolution IS 'Résolution en mètres (NULL pour certains types comme AIS)';
COMMENT ON COLUMN INSTRUMENT.consommation IS 'Consommation énergétique en W';

-- ============================================================================
-- TABLE 4 : EMBARQUEMENT (Association SATELLITE ↔ INSTRUMENT)
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

COMMENT ON TABLE EMBARQUEMENT IS 'Association SATELLITE ↔ INSTRUMENT avec attributs';
COMMENT ON COLUMN EMBARQUEMENT.date_integration IS 'Date d''intégration de l''instrument sur le satellite';
COMMENT ON COLUMN EMBARQUEMENT.etat_fonctionnement IS 'État de fonctionnement de l''instrument';

-- ============================================================================
-- TABLE 5 : CENTRE_CONTROLE (pas de FK)
-- ============================================================================
CREATE TABLE CENTRE_CONTROLE (
    id_centre NUMBER PRIMARY KEY,
    nom_centre VARCHAR2(50) NOT NULL,
    ville VARCHAR2(50) NOT NULL,
    region_geo VARCHAR2(50) NOT NULL,
    fuseau_horaire VARCHAR2(50) NOT NULL,
    statut VARCHAR2(20) NOT NULL
);

COMMENT ON TABLE CENTRE_CONTROLE IS 'Centres de contrôle opérationnel répartis';
COMMENT ON COLUMN CENTRE_CONTROLE.id_centre IS 'Identifiant unique du centre';
COMMENT ON COLUMN CENTRE_CONTROLE.fuseau_horaire IS 'Fuseau horaire (format IANA: Europe/Paris, America/Chicago, Asia/Singapore)';
COMMENT ON COLUMN CENTRE_CONTROLE.region_geo IS 'Région géographique (Europe, Amériques, Asie-Pacifique)';

-- ============================================================================
-- TABLE 6 : STATION_SOL (pas de FK)
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

COMMENT ON TABLE STATION_SOL IS 'Stations sol pour communications satellitaires';
COMMENT ON COLUMN STATION_SOL.code_station IS 'Code unique de la station (ex: GS-TLS-01)';
COMMENT ON COLUMN STATION_SOL.latitude IS 'Latitude en degrés';
COMMENT ON COLUMN STATION_SOL.longitude IS 'Longitude en degrés';
COMMENT ON COLUMN STATION_SOL.diametre_antenne IS 'Diamètre de l''antenne en mètres';
COMMENT ON COLUMN STATION_SOL.bande_frequence IS 'Bande de fréquence (S=2-4GHz, X=8-12GHz, Ku=12-18GHz, Ka=26-40GHz)';
COMMENT ON COLUMN STATION_SOL.debit_max IS 'Débit maximal en Mbps';
COMMENT ON COLUMN STATION_SOL.statut IS 'Statut de la station (Active, Maintenance, Hors service)';

-- ============================================================================
-- TABLE 7 : AFFECTATION_STATION (Association CENTRE_CONTROLE ↔ STATION_SOL)
-- ============================================================================
CREATE TABLE AFFECTATION_STATION (
    id_centre NUMBER NOT NULL,
    code_station VARCHAR2(15) NOT NULL,
    date_affectation DATE NOT NULL,
    CONSTRAINT PK_AFFECTATION PRIMARY KEY (id_centre, code_station),
    CONSTRAINT FK_AFF_CENTRE FOREIGN KEY (id_centre) REFERENCES CENTRE_CONTROLE(id_centre),
    CONSTRAINT FK_AFF_STATION FOREIGN KEY (code_station) REFERENCES STATION_SOL(code_station)
);

COMMENT ON TABLE AFFECTATION_STATION IS 'Association CENTRE_CONTROLE ↔ STATION_SOL';
COMMENT ON COLUMN AFFECTATION_STATION.date_affectation IS 'Date d''affectation de la station au centre';

-- ============================================================================
-- TABLE 8 : MISSION (pas de FK)
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

COMMENT ON TABLE MISSION IS 'Missions spatiales (RG-M02)';
COMMENT ON COLUMN MISSION.id_mission IS 'Identifiant unique de la mission (ex: MSN-ARC-2023)';
COMMENT ON COLUMN MISSION.statut_mission IS 'Statut de la mission (Active, Terminée, Planifiée)';
COMMENT ON COLUMN MISSION.date_fin IS 'Date de fin (NULL pour missions actives ou planifiées)';

-- ============================================================================
-- TABLE 9 : PARTICIPATION (Association SATELLITE ↔ MISSION)
-- ============================================================================
CREATE TABLE PARTICIPATION (
    id_satellite VARCHAR2(10) NOT NULL,
    id_mission VARCHAR2(20) NOT NULL,
    role_satellite VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_PARTICIPATION PRIMARY KEY (id_satellite, id_mission),
    CONSTRAINT FK_PART_SATELLITE FOREIGN KEY (id_satellite) REFERENCES SATELLITE(id_satellite),
    CONSTRAINT FK_PART_MISSION FOREIGN KEY (id_mission) REFERENCES MISSION(id_mission)
);

COMMENT ON TABLE PARTICIPATION IS 'Association SATELLITE ↔ MISSION avec attribut role_satellite';
COMMENT ON COLUMN PARTICIPATION.role_satellite IS 'Rôle du satellite dans la mission (Imageur principal, Imageur secondaire, Satellite de relais, etc.)';

-- ============================================================================
-- TABLE 10 : FENETRE_COM (Association SATELLITE ↔ STATION_SOL)
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
    CONSTRAINT CK_FENETRE_ELEVATION CHECK (elevation_max BETWEEN 0 AND 90)
);

COMMENT ON TABLE FENETRE_COM IS 'Fenêtres de communication SATELLITE ↔ STATION_SOL (RG-F01 à RG-F05)';
COMMENT ON COLUMN FENETRE_COM.id_fenetre IS 'Identifiant unique de la fenêtre de communication';
COMMENT ON COLUMN FENETRE_COM.datetime_debut IS 'Date et heure de début de la fenêtre';
COMMENT ON COLUMN FENETRE_COM.duree IS 'Durée en secondes (RG-F04: entre 1 et 900)';
COMMENT ON COLUMN FENETRE_COM.elevation_max IS 'Élévation maximale du satellite en degrés';
COMMENT ON COLUMN FENETRE_COM.volume_donnees IS 'Volume de données transférées en Mo (NULL si Planifiée - RG-F05)';
COMMENT ON COLUMN FENETRE_COM.statut IS 'Statut de la fenêtre (Réalisée, Planifiée)';

-- ============================================================================
-- Verification de la création
-- ============================================================================
COMMIT;
SELECT table_name FROM user_tables 
WHERE table_name IN ('ORBITE', 'SATELLITE', 'INSTRUMENT', 'EMBARQUEMENT', 
                      'CENTRE_CONTROLE', 'STATION_SOL', 'AFFECTATION_STATION',
                      'MISSION', 'PARTICIPATION', 'FENETRE_COM')
ORDER BY table_name;
