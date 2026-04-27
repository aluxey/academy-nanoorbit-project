-- ============================================================================
-- NanoOrbit - Phase 4 - Livrable L4-B
-- Fichier : L4-B_CTE_Sous_Requetes.sql
-- Objet   : CTE et sous-requetes avancees, exercices 5 a 10
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

-- Ex. 5 - CTE simple : Top 3 des satellites ayant telecharge le plus de donnees.
WITH volumes_satellites AS (
    SELECT s.id_satellite,
           s.nom_satellite,
           COUNT(CASE WHEN f.statut = 'Réalisée' THEN 1 END) AS nb_fenetres_realisees,
           NVL(SUM(CASE WHEN f.statut = 'Réalisée' THEN f.volume_donnees END), 0) AS volume_total,
           NVL(AVG(CASE WHEN f.statut = 'Réalisée' THEN f.volume_donnees END), 0) AS volume_moyen
    FROM SATELLITE s
    LEFT JOIN FENETRE_COM f ON f.id_satellite = s.id_satellite
    GROUP BY s.id_satellite, s.nom_satellite
)
SELECT *
FROM volumes_satellites
ORDER BY volume_total DESC
FETCH FIRST 3 ROWS ONLY;

-- Ex. 6 - CTE multiples : analyse comparative par centre de controle.
WITH fenetres_centres AS (
    SELECT c.id_centre,
           c.nom_centre,
           f.id_fenetre,
           f.volume_donnees,
           st.code_station
    FROM CENTRE_CONTROLE c
    JOIN AFFECTATION_STATION a ON a.id_centre = c.id_centre
    JOIN STATION_SOL st ON st.code_station = a.code_station
    LEFT JOIN FENETRE_COM f ON f.code_station = st.code_station
), stats_centres AS (
    SELECT id_centre,
           nom_centre,
           COUNT(id_fenetre) AS nb_fenetres,
           NVL(SUM(volume_donnees), 0) AS volume_total
    FROM fenetres_centres
    GROUP BY id_centre, nom_centre
), stations_classees AS (
    SELECT id_centre,
           code_station,
           COUNT(id_fenetre) AS nb_fenetres_station,
           ROW_NUMBER() OVER (PARTITION BY id_centre ORDER BY COUNT(id_fenetre) DESC, code_station) AS rn
    FROM fenetres_centres
    GROUP BY id_centre, code_station
)
SELECT sc.id_centre,
       sc.nom_centre,
       sc.nb_fenetres,
       sc.volume_total,
       stc.code_station AS station_plus_active
FROM stats_centres sc
LEFT JOIN stations_classees stc ON stc.id_centre = sc.id_centre AND stc.rn = 1
ORDER BY sc.id_centre;

-- Ex. 7 - CTE recursive : hierarchie Centre -> Station -> Fenetres.
WITH hierarchie (niveau, libelle, id_centre, code_station, id_fenetre, chemin) AS (
    SELECT 1,
           c.nom_centre,
           c.id_centre,
           CAST(NULL AS VARCHAR2(20)),
           CAST(NULL AS NUMBER),
           TO_CHAR(c.id_centre)
    FROM CENTRE_CONTROLE c
    UNION ALL
    SELECT h.niveau + 1,
           CASE
               WHEN h.niveau = 1 THEN st.nom_station
               ELSE 'Fenetre ' || f.id_fenetre || ' - ' || TO_CHAR(f.datetime_debut, 'YYYY-MM-DD HH24:MI')
           END,
           h.id_centre,
           CASE
               WHEN h.niveau = 1 THEN st.code_station
               ELSE h.code_station
           END,
           CASE
               WHEN h.niveau = 1 THEN CAST(NULL AS NUMBER)
               ELSE f.id_fenetre
           END,
           h.chemin || '/' || CASE
               WHEN h.niveau = 1 THEN st.code_station
               ELSE 'F' || f.id_fenetre
           END
    FROM hierarchie h
    LEFT JOIN AFFECTATION_STATION a ON h.niveau = 1 AND a.id_centre = h.id_centre
    LEFT JOIN STATION_SOL st ON h.niveau = 1 AND st.code_station = a.code_station
    LEFT JOIN FENETRE_COM f ON h.niveau = 2 AND f.code_station = h.code_station
    WHERE (h.niveau = 1 AND st.code_station IS NOT NULL)
       OR (h.niveau = 2 AND f.id_fenetre IS NOT NULL)
)
SELECT LPAD(' ', (niveau - 1) * 2) || libelle AS arbre_operationnel
FROM hierarchie
ORDER BY chemin;

-- Ex. 8 - Sous-requete scalaire : fenetres au-dessus de la moyenne generale.
SELECT id_fenetre,
       id_satellite,
       code_station,
       volume_donnees,
       ROUND(volume_donnees - (SELECT AVG(volume_donnees) FROM FENETRE_COM WHERE volume_donnees IS NOT NULL), 1) AS ecart_moyenne
FROM FENETRE_COM
WHERE volume_donnees > (SELECT AVG(volume_donnees) FROM FENETRE_COM WHERE volume_donnees IS NOT NULL)
ORDER BY volume_donnees DESC;

-- Ex. 9 - Sous-requete correlee : derniere fenetre realisee par satellite.
SELECT s.id_satellite,
       s.nom_satellite,
       f.datetime_debut,
       f.code_station,
       f.volume_donnees
FROM SATELLITE s
LEFT JOIN FENETRE_COM f ON f.id_satellite = s.id_satellite
                        AND f.statut = 'Réalisée'
                        AND f.datetime_debut = (
                            SELECT MAX(f2.datetime_debut)
                            FROM FENETRE_COM f2
                            WHERE f2.id_satellite = s.id_satellite
                              AND f2.statut = 'Réalisée'
                        )
ORDER BY s.id_satellite;

-- Ex. 10 - EXISTS / NOT EXISTS : satellites sans fenetre realisee et stations
-- sans fenetre ce trimestre. Une station peut etre dans ce cas si elle est en
-- maintenance ou si aucune communication ne lui a ete planifiee sur la periode.
SELECT 'SATELLITE_SANS_FENETRE_REALISEE' AS type_resultat,
       s.id_satellite AS identifiant,
       s.nom_satellite AS libelle
FROM SATELLITE s
WHERE NOT EXISTS (
    SELECT 1
    FROM FENETRE_COM f
    WHERE f.id_satellite = s.id_satellite
      AND f.statut = 'Réalisée'
)
UNION ALL
SELECT 'STATION_SANS_FENETRE_TRIMESTRE',
       st.code_station,
       st.nom_station
FROM STATION_SOL st
WHERE NOT EXISTS (
    SELECT 1
    FROM FENETRE_COM f
    WHERE f.code_station = st.code_station
      AND f.datetime_debut >= DATE '2024-01-01'
      AND f.datetime_debut < DATE '2024-04-01'
)
ORDER BY type_resultat, identifiant;

-- Fin du livrable L4-B.
