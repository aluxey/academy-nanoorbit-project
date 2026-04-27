-- ============================================================================
-- NanoOrbit - Phase 3 - Livrable L3-B
-- Fichier : L3-B_pkg_nanoOrbit_SPEC.sql
-- Objet   : Specification du package pkg_nanoOrbit
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE pkg_nanoOrbit AS
    TYPE t_stats_satellite IS RECORD (
        nb_fenetres NUMBER,
        volume_total NUMBER,
        duree_moy_secondes NUMBER
    );

    c_statut_min_fenetre CONSTANT SATELLITE.statut%TYPE := 'Opérationnel';
    c_duree_max_fenetre CONSTANT NUMBER := 900;
    c_seuil_revision CONSTANT NUMBER := 50;

    PROCEDURE planifier_fenetre(
        p_id_satellite IN SATELLITE.id_satellite%TYPE,
        p_code_station IN STATION_SOL.code_station%TYPE,
        p_datetime_debut IN FENETRE_COM.datetime_debut%TYPE,
        p_duree IN FENETRE_COM.duree%TYPE,
        p_id_fenetre OUT FENETRE_COM.id_fenetre%TYPE
    );

    PROCEDURE cloturer_fenetre(
        p_id_fenetre IN FENETRE_COM.id_fenetre%TYPE,
        p_volume_donnees IN FENETRE_COM.volume_donnees%TYPE
    );

    PROCEDURE affecter_satellite_mission(
        p_id_satellite IN SATELLITE.id_satellite%TYPE,
        p_id_mission IN MISSION.id_mission%TYPE,
        p_role IN PARTICIPATION.role_satellite%TYPE
    );

    PROCEDURE mettre_en_revision(
        p_id_satellite IN SATELLITE.id_satellite%TYPE
    );

    FUNCTION calculer_volume_theorique(
        p_id_fenetre IN FENETRE_COM.id_fenetre%TYPE
    ) RETURN NUMBER;

    FUNCTION statut_constellation RETURN VARCHAR2;

    FUNCTION stats_satellite(
        p_id_satellite IN SATELLITE.id_satellite%TYPE
    ) RETURN t_stats_satellite;
END pkg_nanoOrbit;
/

SHOW ERRORS PACKAGE pkg_nanoOrbit;
