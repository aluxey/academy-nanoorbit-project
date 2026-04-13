-- ============================================================================
-- NanoOrbit - Phase 2 - Livrable L2-D
-- Fichier : L2-D_Controle_Schema.sql
-- Objet   : Requetes de controle du schema, contraintes et triggers
-- ============================================================================

SET SERVEROUTPUT ON;

PROMPT
PROMPT ===== L2-D - Controle des tables =====

SELECT table_name
FROM user_tables
WHERE table_name IN (
    'ORBITE', 'SATELLITE', 'HISTORIQUE_STATUT', 'INSTRUMENT', 'EMBARQUEMENT',
    'CENTRE_CONTROLE', 'STATION_SOL', 'AFFECTATION_STATION', 'MISSION',
    'FENETRE_COM', 'PARTICIPATION'
)
ORDER BY table_name;

PROMPT
PROMPT ===== L2-D - Controle des contraintes =====

SELECT c.table_name,
       c.constraint_name,
       c.constraint_type,
       c.status
FROM user_constraints c
WHERE c.table_name IN (
    'ORBITE', 'SATELLITE', 'HISTORIQUE_STATUT', 'INSTRUMENT', 'EMBARQUEMENT',
    'CENTRE_CONTROLE', 'STATION_SOL', 'AFFECTATION_STATION', 'MISSION',
    'FENETRE_COM', 'PARTICIPATION'
)
ORDER BY c.table_name, c.constraint_type, c.constraint_name;

PROMPT
PROMPT ===== L2-D - Detail des colonnes contraintes (PK/FK/UQ/CK) =====

SELECT cc.table_name,
       cc.constraint_name,
       cc.column_name,
       cc.position
FROM user_cons_columns cc
WHERE cc.table_name IN (
    'ORBITE', 'SATELLITE', 'HISTORIQUE_STATUT', 'INSTRUMENT', 'EMBARQUEMENT',
    'CENTRE_CONTROLE', 'STATION_SOL', 'AFFECTATION_STATION', 'MISSION',
    'FENETRE_COM', 'PARTICIPATION'
)
ORDER BY cc.table_name, cc.constraint_name, cc.position;

PROMPT
PROMPT ===== L2-D - Controle des triggers =====

SELECT trigger_name,
       table_name,
       trigger_type,
       triggering_event,
       status
FROM user_triggers
WHERE trigger_name IN (
    'TRG_VALIDER_FENETRE',
    'TRG_NO_CHEVAUCHEMENT',
    'TRG_VOLUME_REALISE',
    'TRG_MISSION_TERMINEE',
    'TRG_HISTORIQUE_STATUT'
)
ORDER BY trigger_name;

PROMPT
PROMPT ===== L2-D - Erreurs de compilation (doit retourner 0 ligne) =====

SELECT name, type, line, position, text
FROM user_errors
WHERE name IN (
    'TRG_VALIDER_FENETRE',
    'TRG_NO_CHEVAUCHEMENT',
    'TRG_VOLUME_REALISE',
    'TRG_MISSION_TERMINEE',
    'TRG_HISTORIQUE_STATUT'
)
ORDER BY name, sequence;

PROMPT
PROMPT ===== L2-D - Controle des volumes de donnees =====

SELECT 'ORBITE' table_name, COUNT(*) row_count FROM ORBITE
UNION ALL SELECT 'SATELLITE', COUNT(*) FROM SATELLITE
UNION ALL SELECT 'INSTRUMENT', COUNT(*) FROM INSTRUMENT
UNION ALL SELECT 'EMBARQUEMENT', COUNT(*) FROM EMBARQUEMENT
UNION ALL SELECT 'CENTRE_CONTROLE', COUNT(*) FROM CENTRE_CONTROLE
UNION ALL SELECT 'STATION_SOL', COUNT(*) FROM STATION_SOL
UNION ALL SELECT 'AFFECTATION_STATION', COUNT(*) FROM AFFECTATION_STATION
UNION ALL SELECT 'MISSION', COUNT(*) FROM MISSION
UNION ALL SELECT 'FENETRE_COM', COUNT(*) FROM FENETRE_COM
UNION ALL SELECT 'PARTICIPATION', COUNT(*) FROM PARTICIPATION
UNION ALL SELECT 'HISTORIQUE_STATUT', COUNT(*) FROM HISTORIQUE_STATUT
ORDER BY table_name;
