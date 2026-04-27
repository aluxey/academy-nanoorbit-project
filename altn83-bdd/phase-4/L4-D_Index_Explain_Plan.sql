-- ============================================================================
-- NanoOrbit - Phase 4 - Livrable L4-D
-- Fichier : L4-D_Index_Explain_Plan.sql
-- Objet   : Index, EXPLAIN PLAN, mesure d'impact et rapport de pilotage
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

-- Ex. 17 - Index strategiques.
BEGIN
    FOR r_idx IN (
        SELECT index_name
        FROM user_indexes
        WHERE index_name IN (
            'IDX_FENETRE_SATELLITE',
            'IDX_FENETRE_STATION',
            'IDX_PARTICIPATION_SAT',
            'IDX_PARTICIPATION_MISSION',
            'IDX_SATELLITE_STATUT',
            'IDX_SATELLITE_STATUT_ORBITE',
            'IDX_FENETRE_MOIS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP INDEX ' || r_idx.index_name;
    END LOOP;
END;
/

CREATE INDEX idx_fenetre_satellite ON FENETRE_COM(id_satellite);
CREATE INDEX idx_fenetre_station ON FENETRE_COM(code_station);
CREATE INDEX idx_participation_sat ON PARTICIPATION(id_satellite);
CREATE INDEX idx_participation_mission ON PARTICIPATION(id_mission);
CREATE INDEX idx_satellite_statut ON SATELLITE(statut);
CREATE INDEX idx_satellite_statut_orbite ON SATELLITE(statut, id_orbite);
CREATE INDEX idx_fenetre_mois ON FENETRE_COM(TRUNC(datetime_debut, 'MM'));

SELECT index_name, table_name, status, visibility
FROM user_indexes
WHERE index_name IN (
    'IDX_FENETRE_SATELLITE',
    'IDX_FENETRE_STATION',
    'IDX_PARTICIPATION_SAT',
    'IDX_PARTICIPATION_MISSION',
    'IDX_SATELLITE_STATUT',
    'IDX_SATELLITE_STATUT_ORBITE',
    'IDX_FENETRE_MOIS'
)
ORDER BY index_name;

-- Ex. 18 - EXPLAIN PLAN d'une requete de reporting mensuel.
EXPLAIN PLAN FOR
SELECT TRUNC(f.datetime_debut, 'MM') AS mois,
       c.nom_centre,
       o.type_orbite,
       COUNT(*) AS nb_fenetres,
       SUM(f.volume_donnees) AS volume_total
FROM FENETRE_COM f
JOIN SATELLITE s ON s.id_satellite = f.id_satellite
JOIN ORBITE o ON o.id_orbite = s.id_orbite
JOIN STATION_SOL st ON st.code_station = f.code_station
JOIN AFFECTATION_STATION a ON a.code_station = st.code_station
JOIN CENTRE_CONTROLE c ON c.id_centre = a.id_centre
WHERE f.statut = 'Réalisée'
GROUP BY TRUNC(f.datetime_debut, 'MM'), c.nom_centre, o.type_orbite;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ex. 19 - Mesure d'impact avec index invisible puis visible.
ALTER INDEX idx_satellite_statut INVISIBLE;

EXPLAIN PLAN FOR
SELECT id_satellite, nom_satellite, statut
FROM SATELLITE
WHERE statut = 'Opérationnel';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

ALTER INDEX idx_satellite_statut VISIBLE;

EXPLAIN PLAN FOR
SELECT id_satellite, nom_satellite, statut
FROM SATELLITE
WHERE statut = 'Opérationnel';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Rapport de pilotage integral : CTE, fonctions analytiques et vue materialisee.
WITH volumes_centres AS (
    SELECT mois,
           id_centre,
           nom_centre,
           SUM(volume_total) AS volume_mensuel
    FROM mv_volumes_mensuels
    GROUP BY mois, id_centre, nom_centre
), classement AS (
    SELECT mois,
           id_centre,
           nom_centre,
           volume_mensuel,
           RANK() OVER (PARTITION BY mois ORDER BY volume_mensuel DESC) AS rang_centre,
           ROUND(volume_mensuel / NULLIF(SUM(volume_mensuel) OVER (PARTITION BY mois), 0) * 100, 2) AS part_volume_pct,
           LAG(volume_mensuel) OVER (PARTITION BY id_centre ORDER BY mois) AS volume_mois_precedent
    FROM volumes_centres
)
SELECT c.mois,
       c.rang_centre,
       c.nom_centre,
       c.volume_mensuel,
       c.part_volume_pct,
       c.volume_mois_precedent,
       c.volume_mensuel - NVL(c.volume_mois_precedent, 0) AS evolution_volume,
       s.id_satellite,
       s.nom_satellite,
       s.statut AS statut_satellite
FROM classement c
JOIN AFFECTATION_STATION a ON a.id_centre = c.id_centre
JOIN FENETRE_COM f ON f.code_station = a.code_station
JOIN SATELLITE s ON s.id_satellite = f.id_satellite
WHERE TRUNC(f.datetime_debut, 'MM') = c.mois
ORDER BY c.mois, c.rang_centre, s.id_satellite;

-- Fin du livrable L4-D.
