-- ============================================================================
-- NanoOrbit - Phase 4 - Livrable L4-A
-- Fichier : L4-A_Vues.sql
-- Objet   : Vues V1 a V3 + vue materialisee V4
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- Prerequis : Phases 2 et 3 executees
-- ============================================================================

SET SERVEROUTPUT ON;

-- V1 - Satellites operationnels avec orbite, nombre d'instruments et statut batterie.
CREATE OR REPLACE VIEW v_satellites_operationnels AS
SELECT s.id_satellite,
       s.nom_satellite,
       s.format_cubesat,
       s.capacite_batterie,
       CASE
           WHEN s.capacite_batterie >= 60 THEN 'Haute capacité'
           WHEN s.capacite_batterie >= 30 THEN 'Capacité moyenne'
           ELSE 'Capacité standard'
       END AS statut_batterie,
       o.type_orbite,
       o.altitude,
       o.inclinaison,
       COUNT(e.ref_instrument) AS nb_instruments
FROM SATELLITE s
JOIN ORBITE o ON o.id_orbite = s.id_orbite
LEFT JOIN EMBARQUEMENT e ON e.id_satellite = s.id_satellite
WHERE s.statut = 'Opérationnel'
GROUP BY s.id_satellite,
         s.nom_satellite,
         s.format_cubesat,
         s.capacite_batterie,
         o.type_orbite,
         o.altitude,
         o.inclinaison;

SELECT * FROM v_satellites_operationnels ORDER BY id_satellite;

-- V2 - Fenetres detaillees avec satellite, station et centre de controle.
CREATE OR REPLACE VIEW v_fenetres_detail AS
SELECT f.id_fenetre,
       f.datetime_debut,
       f.duree,
       TRUNC(f.duree / 60) || ' min ' || MOD(f.duree, 60) || ' s' AS duree_formatee,
       f.elevation_max,
       f.volume_donnees,
       f.statut AS statut_fenetre,
       s.id_satellite,
       s.nom_satellite,
       st.code_station,
       st.nom_station,
       c.id_centre,
       c.nom_centre,
       c.region_geo
FROM FENETRE_COM f
JOIN SATELLITE s ON s.id_satellite = f.id_satellite
JOIN STATION_SOL st ON st.code_station = f.code_station
LEFT JOIN AFFECTATION_STATION a ON a.code_station = st.code_station
LEFT JOIN CENTRE_CONTROLE c ON c.id_centre = a.id_centre;

SELECT * FROM v_fenetres_detail ORDER BY id_fenetre;

-- V3 - Statistiques par mission.
CREATE OR REPLACE VIEW v_stats_missions AS
SELECT m.id_mission,
       m.nom_mission,
       m.statut_mission,
       COUNT(DISTINCT p.id_satellite) AS nb_satellites,
       LISTAGG(DISTINCT o.type_orbite, ', ') WITHIN GROUP (ORDER BY o.type_orbite) AS types_orbites,
       NVL(SUM(CASE WHEN f.statut = 'Réalisée' THEN f.volume_donnees ELSE 0 END), 0) AS volume_total_telecharge
FROM MISSION m
LEFT JOIN PARTICIPATION p ON p.id_mission = m.id_mission
LEFT JOIN SATELLITE s ON s.id_satellite = p.id_satellite
LEFT JOIN ORBITE o ON o.id_orbite = s.id_orbite
LEFT JOIN FENETRE_COM f ON f.id_satellite = s.id_satellite
GROUP BY m.id_mission,
         m.nom_mission,
         m.statut_mission;

SELECT * FROM v_stats_missions ORDER BY id_mission;

-- V4 - Vue materialisee des volumes mensuels par centre et type de satellite.
BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW mv_volumes_mensuels';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-12003, -942) THEN
            RAISE;
        END IF;
END;
/

CREATE MATERIALIZED VIEW mv_volumes_mensuels
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT TRUNC(f.datetime_debut, 'MM') AS mois,
       c.id_centre,
       c.nom_centre,
       c.region_geo,
       s.format_cubesat,
       COUNT(*) AS nb_fenetres,
       NVL(SUM(f.volume_donnees), 0) AS volume_total
FROM FENETRE_COM f
JOIN SATELLITE s ON s.id_satellite = f.id_satellite
JOIN STATION_SOL st ON st.code_station = f.code_station
LEFT JOIN AFFECTATION_STATION a ON a.code_station = st.code_station
LEFT JOIN CENTRE_CONTROLE c ON c.id_centre = a.id_centre
WHERE f.statut = 'Réalisée'
GROUP BY TRUNC(f.datetime_debut, 'MM'),
         c.id_centre,
         c.nom_centre,
         c.region_geo,
         s.format_cubesat;

SELECT * FROM mv_volumes_mensuels ORDER BY mois, id_centre, format_cubesat;

-- Fin du livrable L4-A.
