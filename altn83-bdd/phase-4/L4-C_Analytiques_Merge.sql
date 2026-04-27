-- ============================================================================
-- NanoOrbit - Phase 4 - Livrable L4-C
-- Fichier : L4-C_Analytiques_Merge.sql
-- Objet   : Fonctions analytiques et MERGE INTO, exercices 11 a 16
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

-- Ex. 11 - ROW_NUMBER / RANK / DENSE_RANK : classement des satellites par volume.
WITH volumes AS (
    SELECT s.id_satellite,
           s.nom_satellite,
           o.type_orbite,
           NVL(SUM(CASE WHEN f.statut = 'Réalisée' THEN f.volume_donnees END), 0) AS volume_total
    FROM SATELLITE s
    JOIN ORBITE o ON o.id_orbite = s.id_orbite
    LEFT JOIN FENETRE_COM f ON f.id_satellite = s.id_satellite
    GROUP BY s.id_satellite, s.nom_satellite, o.type_orbite
)
SELECT id_satellite,
       nom_satellite,
       type_orbite,
       volume_total,
       ROW_NUMBER() OVER (ORDER BY volume_total DESC) AS row_number_global,
       RANK() OVER (ORDER BY volume_total DESC) AS rank_global,
       DENSE_RANK() OVER (PARTITION BY type_orbite ORDER BY volume_total DESC) AS dense_rank_orbite
FROM volumes
ORDER BY volume_total DESC, id_satellite;

-- Ex. 12 - LAG / LEAD : comparaison avec la fenetre precedente par station.
SELECT code_station,
       id_fenetre,
       datetime_debut,
       volume_donnees,
       LAG(volume_donnees) OVER (PARTITION BY code_station ORDER BY datetime_debut) AS volume_precedent,
       LEAD(volume_donnees) OVER (PARTITION BY code_station ORDER BY datetime_debut) AS volume_suivant,
       CASE
           WHEN LAG(volume_donnees) OVER (PARTITION BY code_station ORDER BY datetime_debut) IS NULL
                OR LAG(volume_donnees) OVER (PARTITION BY code_station ORDER BY datetime_debut) = 0
           THEN NULL
           ELSE ROUND(
               (volume_donnees - LAG(volume_donnees) OVER (PARTITION BY code_station ORDER BY datetime_debut))
               / LAG(volume_donnees) OVER (PARTITION BY code_station ORDER BY datetime_debut) * 100,
               2
           )
       END AS evolution_pct
FROM FENETRE_COM
WHERE statut = 'Réalisée'
ORDER BY code_station, datetime_debut;

-- Ex. 13 - SUM OVER : volumes cumules par centre et moyenne mobile 3 fenetres.
SELECT c.id_centre,
       c.nom_centre,
       f.id_fenetre,
       f.datetime_debut,
       f.volume_donnees,
       SUM(NVL(f.volume_donnees, 0)) OVER (
           PARTITION BY c.id_centre
           ORDER BY f.datetime_debut
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS volume_cumule,
       ROUND(AVG(NVL(f.volume_donnees, 0)) OVER (
           PARTITION BY c.id_centre
           ORDER BY f.datetime_debut
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 1) AS moyenne_mobile_3
FROM FENETRE_COM f
JOIN STATION_SOL st ON st.code_station = f.code_station
JOIN AFFECTATION_STATION a ON a.code_station = st.code_station
JOIN CENTRE_CONTROLE c ON c.id_centre = a.id_centre
ORDER BY c.id_centre, f.datetime_debut;

-- Ex. 14 - Tableau de bord constellation.
WITH volumes AS (
    SELECT s.id_satellite,
           s.nom_satellite,
           NVL(SUM(CASE WHEN f.statut = 'Réalisée' THEN f.volume_donnees END), 0) AS volume_total
    FROM SATELLITE s
    LEFT JOIN FENETRE_COM f ON f.id_satellite = s.id_satellite
    GROUP BY s.id_satellite, s.nom_satellite
)
SELECT id_satellite,
       nom_satellite,
       volume_total,
       RANK() OVER (ORDER BY volume_total DESC) AS rang_satellite,
       ROUND(volume_total / NULLIF(SUM(volume_total) OVER (), 0) * 100, 2) AS part_volume_pct,
       SUM(volume_total) OVER (ORDER BY volume_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumul_volume,
       ROUND(volume_total - AVG(volume_total) OVER (), 1) AS ecart_moyenne
FROM volumes
ORDER BY rang_satellite, id_satellite;

-- Ex. 15 - MERGE INTO : synchroniser un lot de statuts satellites IoT.
MERGE INTO SATELLITE cible
USING (
    SELECT 'SAT-001' AS id_satellite,
           'Opérationnel' AS statut,
           1 AS id_orbite,
           'NanoOrbit-Alpha' AS nom_satellite,
           DATE '2022-03-15' AS date_lancement,
           1.3 AS masse,
           '3U' AS format_cubesat,
           60 AS duree_vie_prevue,
           20 AS capacite_batterie
    FROM dual
    UNION ALL
    SELECT 'SAT-006', 'En veille', 3, 'NanoOrbit-Zeta', DATE '2024-04-01', 2.5, '6U', 72, 40
    FROM dual
) source
ON (cible.id_satellite = source.id_satellite)
WHEN MATCHED THEN UPDATE SET
    cible.statut = source.statut,
    cible.id_orbite = source.id_orbite
WHEN NOT MATCHED THEN INSERT (
    id_satellite,
    nom_satellite,
    date_lancement,
    masse,
    format_cubesat,
    statut,
    duree_vie_prevue,
    capacite_batterie,
    id_orbite
) VALUES (
    source.id_satellite,
    source.nom_satellite,
    source.date_lancement,
    source.masse,
    source.format_cubesat,
    source.statut,
    source.duree_vie_prevue,
    source.capacite_batterie,
    source.id_orbite
);

SELECT id_satellite, nom_satellite, statut, id_orbite
FROM SATELLITE
WHERE id_satellite IN ('SAT-001', 'SAT-006')
ORDER BY id_satellite;

ROLLBACK;

-- Ex. 16 - MERGE INTO : synchroniser les affectations stations/centres.
MERGE INTO AFFECTATION_STATION cible
USING (
    SELECT 1 AS id_centre, 'GS-TLS-01' AS code_station, DATE '2024-04-01' AS date_affectation FROM dual
    UNION ALL
    SELECT 2, 'GS-KIR-01', DATE '2024-04-01' FROM dual
) source
ON (cible.id_centre = source.id_centre AND cible.code_station = source.code_station)
WHEN MATCHED THEN UPDATE SET
    cible.date_affectation = source.date_affectation
WHEN NOT MATCHED THEN INSERT (id_centre, code_station, date_affectation)
VALUES (source.id_centre, source.code_station, source.date_affectation);

SELECT id_centre, code_station, date_affectation
FROM AFFECTATION_STATION
WHERE code_station IN ('GS-TLS-01', 'GS-KIR-01')
ORDER BY code_station, id_centre;

ROLLBACK;

-- Fin du livrable L4-C.
