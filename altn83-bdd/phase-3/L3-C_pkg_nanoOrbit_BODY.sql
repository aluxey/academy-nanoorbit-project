-- ============================================================================
-- NanoOrbit - Phase 3 - Livrable L3-C
-- Fichier : L3-C_pkg_nanoOrbit_BODY.sql
-- Objet   : Corps du package pkg_nanoOrbit
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE BODY pkg_nanoOrbit AS
    PROCEDURE verifier_satellite_existe(p_id_satellite IN SATELLITE.id_satellite%TYPE)
    IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM SATELLITE
        WHERE id_satellite = p_id_satellite;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20301, 'Satellite introuvable : ' || p_id_satellite);
        END IF;
    END verifier_satellite_existe;

    PROCEDURE planifier_fenetre(
        p_id_satellite IN SATELLITE.id_satellite%TYPE,
        p_code_station IN STATION_SOL.code_station%TYPE,
        p_datetime_debut IN FENETRE_COM.datetime_debut%TYPE,
        p_duree IN FENETRE_COM.duree%TYPE,
        p_id_fenetre OUT FENETRE_COM.id_fenetre%TYPE
    )
    IS
        v_statut_satellite SATELLITE.statut%TYPE;
        v_statut_station STATION_SOL.statut%TYPE;
    BEGIN
        IF p_duree IS NULL OR p_duree < 1 OR p_duree > c_duree_max_fenetre THEN
            RAISE_APPLICATION_ERROR(-20310, 'Duree de fenetre invalide.');
        END IF;

        SELECT statut
        INTO v_statut_satellite
        FROM SATELLITE
        WHERE id_satellite = p_id_satellite;

        IF v_statut_satellite <> c_statut_min_fenetre THEN
            RAISE_APPLICATION_ERROR(-20311, 'Satellite non operationnel : ' || p_id_satellite);
        END IF;

        SELECT statut
        INTO v_statut_station
        FROM STATION_SOL
        WHERE code_station = p_code_station;

        IF v_statut_station <> 'Active' THEN
            RAISE_APPLICATION_ERROR(-20312, 'Station non active : ' || p_code_station);
        END IF;

        INSERT INTO FENETRE_COM (
            datetime_debut,
            duree,
            elevation_max,
            volume_donnees,
            statut,
            id_satellite,
            code_station
        ) VALUES (
            p_datetime_debut,
            p_duree,
            60,
            NULL,
            'Planifiée',
            p_id_satellite,
            p_code_station
        ) RETURNING id_fenetre INTO p_id_fenetre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20313, 'Satellite ou station introuvable.');
    END planifier_fenetre;

    PROCEDURE cloturer_fenetre(
        p_id_fenetre IN FENETRE_COM.id_fenetre%TYPE,
        p_volume_donnees IN FENETRE_COM.volume_donnees%TYPE
    )
    IS
    BEGIN
        IF p_volume_donnees IS NULL OR p_volume_donnees < 0 THEN
            RAISE_APPLICATION_ERROR(-20320, 'Volume de donnees invalide.');
        END IF;

        UPDATE FENETRE_COM
        SET statut = 'Réalisée',
            volume_donnees = p_volume_donnees
        WHERE id_fenetre = p_id_fenetre;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20321, 'Fenetre introuvable : ' || p_id_fenetre);
        END IF;
    END cloturer_fenetre;

    PROCEDURE affecter_satellite_mission(
        p_id_satellite IN SATELLITE.id_satellite%TYPE,
        p_id_mission IN MISSION.id_mission%TYPE,
        p_role IN PARTICIPATION.role_satellite%TYPE
    )
    IS
    BEGIN
        IF p_role IS NULL THEN
            RAISE_APPLICATION_ERROR(-20330, 'Role satellite obligatoire.');
        END IF;

        INSERT INTO PARTICIPATION (id_satellite, id_mission, role_satellite)
        VALUES (p_id_satellite, p_id_mission, p_role);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20331, 'Participation deja existante.');
    END affecter_satellite_mission;

    PROCEDURE mettre_en_revision(
        p_id_satellite IN SATELLITE.id_satellite%TYPE
    )
    IS
    BEGIN
        verifier_satellite_existe(p_id_satellite);

        UPDATE SATELLITE
        SET statut = 'En veille'
        WHERE id_satellite = p_id_satellite;
    END mettre_en_revision;

    FUNCTION calculer_volume_theorique(
        p_id_fenetre IN FENETRE_COM.id_fenetre%TYPE
    ) RETURN NUMBER
    IS
        v_duree FENETRE_COM.duree%TYPE;
        v_debit STATION_SOL.debit_max%TYPE;
    BEGIN
        SELECT f.duree, st.debit_max
        INTO v_duree, v_debit
        FROM FENETRE_COM f
        JOIN STATION_SOL st ON st.code_station = f.code_station
        WHERE f.id_fenetre = p_id_fenetre;

        RETURN ROUND((v_debit * v_duree) / 8, 1);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20340, 'Fenetre introuvable : ' || p_id_fenetre);
    END calculer_volume_theorique;

    FUNCTION statut_constellation RETURN VARCHAR2
    IS
        v_total_sat NUMBER;
        v_sat_op NUMBER;
        v_missions_actives NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total_sat FROM SATELLITE;
        SELECT COUNT(*) INTO v_sat_op FROM SATELLITE WHERE statut = 'Opérationnel';
        SELECT COUNT(*) INTO v_missions_actives FROM MISSION WHERE statut_mission = 'Active';

        RETURN v_sat_op || '/' || v_total_sat || ' satellites opérationnels, ' ||
               v_missions_actives || ' missions actives';
    END statut_constellation;

    FUNCTION stats_satellite(
        p_id_satellite IN SATELLITE.id_satellite%TYPE
    ) RETURN t_stats_satellite
    IS
        v_stats t_stats_satellite;
    BEGIN
        verifier_satellite_existe(p_id_satellite);

        SELECT COUNT(*),
               NVL(SUM(volume_donnees), 0),
               NVL(AVG(duree), 0)
        INTO v_stats.nb_fenetres,
             v_stats.volume_total,
             v_stats.duree_moy_secondes
        FROM FENETRE_COM
        WHERE id_satellite = p_id_satellite;

        RETURN v_stats;
    END stats_satellite;
END pkg_nanoOrbit;
/

SHOW ERRORS PACKAGE BODY pkg_nanoOrbit;
