-- ============================================================================
-- NanoOrbit - Phase 2 - Livrable L2-C
-- Fichier : L2-C_Triggers.sql
-- Objet   : 5 triggers metier + jeux de tests commentes
-- ============================================================================

SET SERVEROUTPUT ON;

-- ==========================================================================
-- T1 - trg_valider_fenetre
-- Regle : bloque une fenetre si satellite desorbite ou station en maintenance
-- Erreurs attendues : ORA-20001 / ORA-20002
-- ==========================================================================
CREATE OR REPLACE TRIGGER trg_valider_fenetre
BEFORE INSERT ON FENETRE_COM
FOR EACH ROW
DECLARE
    v_statut_satellite SATELLITE.statut%TYPE;
    v_statut_station   STATION_SOL.statut%TYPE;
BEGIN
    SELECT statut
      INTO v_statut_satellite
      FROM SATELLITE
     WHERE id_satellite = :NEW.id_satellite;

    IF v_statut_satellite IN ('Désorbité', 'Desorbite') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insertion refusee : satellite desorbite.');
    END IF;

    SELECT statut
      INTO v_statut_station
      FROM STATION_SOL
     WHERE code_station = :NEW.code_station;

    IF v_statut_station = 'Maintenance' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insertion refusee : station en maintenance.');
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_valider_fenetre;

-- ==========================================================================
-- T2 - trg_no_chevauchement
-- Regle : pas de chevauchement temporel pour un meme satellite ou une meme station
-- Erreur attendue : ORA-20003
-- ==========================================================================
CREATE OR REPLACE TRIGGER trg_no_chevauchement
BEFORE INSERT OR UPDATE ON FENETRE_COM
FOR EACH ROW
DECLARE
    v_nb_chevauchements NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_nb_chevauchements
      FROM FENETRE_COM f
     WHERE f.id_fenetre <> NVL(:NEW.id_fenetre, -1)
       AND (f.id_satellite = :NEW.id_satellite OR f.code_station = :NEW.code_station)
       AND :NEW.datetime_debut < (f.datetime_debut + NUMTODSINTERVAL(f.duree, 'SECOND'))
       AND f.datetime_debut < (:NEW.datetime_debut + NUMTODSINTERVAL(:NEW.duree, 'SECOND'));

    IF v_nb_chevauchements > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Insertion/MAJ refusee : chevauchement de fenetres detecte.');
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_no_chevauchement;

-- ==========================================================================
-- T3 - trg_volume_realise
-- Regle : volume_donnees force a NULL si statut != Realisee
-- ==========================================================================
CREATE OR REPLACE TRIGGER trg_volume_realise
BEFORE INSERT OR UPDATE ON FENETRE_COM
FOR EACH ROW
BEGIN
    IF :NEW.statut NOT IN ('Réalisée', 'Realisee') THEN
        :NEW.volume_donnees := NULL;
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_volume_realise;

-- ==========================================================================
-- T4 - trg_mission_terminee
-- Regle : bloque l'ajout de participation si mission terminee
-- Erreur attendue : ORA-20004
-- ==========================================================================
CREATE OR REPLACE TRIGGER trg_mission_terminee
BEFORE INSERT ON PARTICIPATION
FOR EACH ROW
DECLARE
    v_statut_mission MISSION.statut_mission%TYPE;
BEGIN
    SELECT statut_mission
      INTO v_statut_mission
      FROM MISSION
     WHERE id_mission = :NEW.id_mission;

    IF v_statut_mission IN ('Terminée', 'Terminee') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Insertion refusee : mission terminee.');
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_mission_terminee;

-- ==========================================================================
-- T5 - trg_historique_statut
-- Regle : historise tout changement de statut satellite
-- ==========================================================================
CREATE OR REPLACE TRIGGER trg_historique_statut
AFTER UPDATE OF statut ON SATELLITE
FOR EACH ROW
WHEN (NVL(OLD.statut, '#') <> NVL(NEW.statut, '#'))
BEGIN
    INSERT INTO HISTORIQUE_STATUT (
        id_satellite,
        ancien_statut,
        nouveau_statut,
        date_changement,
        motif
    ) VALUES (
        :NEW.id_satellite,
        :OLD.statut,
        :NEW.statut,
        SYSTIMESTAMP,
        'Changement de statut via UPDATE SATELLITE'
    );
END;
/
SHOW ERRORS TRIGGER trg_historique_statut;

-- ==========================================================================
-- TESTS T1
-- ==========================================================================
PROMPT
PROMPT ===== TESTS T1 - trg_valider_fenetre =====

SAVEPOINT sp_t1;

-- Cas valide attendu : INSERT OK
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9001, TO_TIMESTAMP('2024-01-22 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 180, 55, NULL, 'Planifiée', 'SAT-001', 'GS-TLS-01');
    DBMS_OUTPUT.PUT_LINE('T1 valide : OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T1 valide : KO - ' || SQLERRM);
END;
/

-- Cas erreur attendu : ORA-20001 (satellite desorbite)
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9002, TO_TIMESTAMP('2024-01-22 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 180, 45, NULL, 'Planifiée', 'SAT-005', 'GS-TLS-01');
    DBMS_OUTPUT.PUT_LINE('T1 erreur SAT-005 : KO (devait echouer)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T1 erreur SAT-005 : OK - ' || SQLERRM);
END;
/

-- Cas erreur attendu : ORA-20002 (station maintenance)
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9003, TO_TIMESTAMP('2024-01-22 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 180, 50, NULL, 'Planifiée', 'SAT-001', 'GS-SGP-01');
    DBMS_OUTPUT.PUT_LINE('T1 erreur GS-SGP-01 : KO (devait echouer)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T1 erreur GS-SGP-01 : OK - ' || SQLERRM);
END;
/

ROLLBACK TO sp_t1;

-- ==========================================================================
-- TESTS T2
-- ==========================================================================
PROMPT
PROMPT ===== TESTS T2 - trg_no_chevauchement =====

SAVEPOINT sp_t2;

-- Cas valide attendu : INSERT OK (pas de chevauchement)
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9011, TO_TIMESTAMP('2024-01-22 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 200, 60, NULL, 'Planifiée', 'SAT-003', 'GS-KIR-01');
    DBMS_OUTPUT.PUT_LINE('T2 valide : OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T2 valide : KO - ' || SQLERRM);
END;
/

-- Cas erreur attendu : ORA-20003 (chevauchement satellite SAT-001)
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9012, TO_TIMESTAMP('2024-01-15 09:16:00', 'YYYY-MM-DD HH24:MI:SS'), 120, 42, NULL, 'Planifiée', 'SAT-001', 'GS-TLS-01');
    DBMS_OUTPUT.PUT_LINE('T2 chevauchement SAT : KO (devait echouer)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T2 chevauchement SAT : OK - ' || SQLERRM);
END;
/

-- Cas erreur attendu : ORA-20003 (chevauchement station GS-TLS-01)
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9013, TO_TIMESTAMP('2024-01-15 11:55:00', 'YYYY-MM-DD HH24:MI:SS'), 120, 40, NULL, 'Planifiée', 'SAT-003', 'GS-TLS-01');
    DBMS_OUTPUT.PUT_LINE('T2 chevauchement STATION : KO (devait echouer)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T2 chevauchement STATION : OK - ' || SQLERRM);
END;
/

ROLLBACK TO sp_t2;

-- ==========================================================================
-- TESTS T3
-- ==========================================================================
PROMPT
PROMPT ===== TESTS T3 - trg_volume_realise =====

SAVEPOINT sp_t3;

-- Cas attendu : volume force a NULL car statut = Planifiee
DECLARE
    v_volume FENETRE_COM.volume_donnees%TYPE;
    v_id_fenetre FENETRE_COM.id_fenetre%TYPE;
BEGIN
    INSERT INTO FENETRE_COM (id_fenetre, datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
    VALUES (9021, TO_TIMESTAMP('2024-01-23 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 180, 45, 9999, 'Planifiée', 'SAT-002', 'GS-KIR-01')
    RETURNING id_fenetre INTO v_id_fenetre;

    SELECT volume_donnees
      INTO v_volume
      FROM FENETRE_COM
     WHERE id_fenetre = v_id_fenetre;

    IF v_volume IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('T3 correction silencieuse : OK (volume devenu NULL)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('T3 correction silencieuse : KO (volume=' || v_volume || ')');
    END IF;
END;
/

ROLLBACK TO sp_t3;

-- ==========================================================================
-- TESTS T4
-- ==========================================================================
PROMPT
PROMPT ===== TESTS T4 - trg_mission_terminee =====

SAVEPOINT sp_t4;

-- Cas valide attendu : INSERT OK (mission active)
BEGIN
    INSERT INTO PARTICIPATION (id_satellite, id_mission, role_satellite)
    VALUES ('SAT-004', 'MSN-ARC-2023', 'Satellite de test');
    DBMS_OUTPUT.PUT_LINE('T4 valide : OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T4 valide : KO - ' || SQLERRM);
END;
/

-- Cas erreur attendu : ORA-20004 (mission terminee)
BEGIN
    INSERT INTO PARTICIPATION (id_satellite, id_mission, role_satellite)
    VALUES ('SAT-002', 'MSN-DEF-2022', 'Satellite de test');
    DBMS_OUTPUT.PUT_LINE('T4 mission terminee : KO (devait echouer)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T4 mission terminee : OK - ' || SQLERRM);
END;
/

ROLLBACK TO sp_t4;

-- ==========================================================================
-- TESTS T5
-- ==========================================================================
PROMPT
PROMPT ===== TESTS T5 - trg_historique_statut =====

SAVEPOINT sp_t5;

DECLARE
    v_old SATELLITE.statut%TYPE;
    v_new SATELLITE.statut%TYPE;
BEGIN
    UPDATE SATELLITE
       SET statut = 'Opérationnel'
     WHERE id_satellite = 'SAT-004';

    SELECT ancien_statut, nouveau_statut
      INTO v_old, v_new
      FROM HISTORIQUE_STATUT
     WHERE id_historique = (SELECT MAX(id_historique) FROM HISTORIQUE_STATUT WHERE id_satellite = 'SAT-004');

    DBMS_OUTPUT.PUT_LINE('T5 trace creee : OK - ancien=' || v_old || ', nouveau=' || v_new);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('T5 trace creee : KO - aucune ligne dans HISTORIQUE_STATUT');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('T5 trace creee : KO - ' || SQLERRM);
END;
/

ROLLBACK TO sp_t5;

PROMPT
PROMPT ===== Fin des tests L2-C =====
