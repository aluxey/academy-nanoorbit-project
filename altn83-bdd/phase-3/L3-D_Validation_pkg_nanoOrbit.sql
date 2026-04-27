-- ============================================================================
-- NanoOrbit - Phase 3 - Livrable L3-D
-- Fichier : L3-D_Validation_pkg_nanoOrbit.sql
-- Objet   : Scenario de validation du package pkg_nanoOrbit
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

DECLARE
    v_id_fenetre FENETRE_COM.id_fenetre%TYPE;
    v_stats pkg_nanoOrbit.t_stats_satellite;
    v_volume_theorique NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Validation pkg_nanoOrbit ===');

    pkg_nanoOrbit.planifier_fenetre(
        p_id_satellite => 'SAT-001',
        p_code_station => 'GS-KIR-01',
        p_datetime_debut => TIMESTAMP '2024-02-10 10:00:00',
        p_duree => 300,
        p_id_fenetre => v_id_fenetre
    );
    DBMS_OUTPUT.PUT_LINE('Fenetre planifiee : ' || v_id_fenetre);

    v_volume_theorique := pkg_nanoOrbit.calculer_volume_theorique(v_id_fenetre);
    DBMS_OUTPUT.PUT_LINE('Volume theorique : ' || v_volume_theorique || ' Mo');

    pkg_nanoOrbit.cloturer_fenetre(
        p_id_fenetre => v_id_fenetre,
        p_volume_donnees => 1200
    );
    DBMS_OUTPUT.PUT_LINE('Fenetre cloturee avec volume 1200 Mo');

    pkg_nanoOrbit.affecter_satellite_mission(
        p_id_satellite => 'SAT-004',
        p_id_mission => 'MSN-ARC-2023',
        p_role => 'Satellite de relais'
    );
    DBMS_OUTPUT.PUT_LINE('SAT-004 affecte a MSN-ARC-2023');

    v_stats := pkg_nanoOrbit.stats_satellite('SAT-001');
    DBMS_OUTPUT.PUT_LINE('Stats SAT-001 : fenetres=' || v_stats.nb_fenetres ||
                         ', volume=' || v_stats.volume_total ||
                         ', duree moyenne=' || ROUND(v_stats.duree_moy_secondes, 1));

    DBMS_OUTPUT.PUT_LINE('Constellation : ' || pkg_nanoOrbit.statut_constellation());

    pkg_nanoOrbit.mettre_en_revision('SAT-003');
    DBMS_OUTPUT.PUT_LINE('SAT-003 mis en revision');

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Scenario valide puis annule par ROLLBACK.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur validation package : ' || SQLERRM);
        ROLLBACK;
END;
/

-- Resultats attendus :
-- - Une nouvelle fenetre est planifiee puis cloturee.
-- - SAT-004 est affecte a MSN-ARC-2023.
-- - Les statistiques de SAT-001 sont affichees.
-- - Le statut global de la constellation est affiche.
-- - SAT-003 passe en revision, ce qui declenche le trigger d'historique.
-- - Le ROLLBACK final annule les donnees de test.
