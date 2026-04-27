-- ============================================================================
-- NanoOrbit - Phase 2 - Livrable L2-C
-- Fichier : L2-C_Triggers.sql
-- Objet   : 5 triggers metier + SHOW ERRORS + jeux de tests commentes
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- ============================================================================

SET SERVEROUTPUT ON;

-- ============================================================================
-- T1 - trg_valider_fenetre
-- Regles : RG-S06, RG-G03
-- Bloque la creation d'une fenetre si le satellite est Desorbite ou si la
-- station est en Maintenance.
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_valider_fenetre
BEFORE INSERT ON FENETRE_COM
FOR EACH ROW
DECLARE
    v_statut_satellite SATELLITE.statut%TYPE;
    v_statut_station STATION_SOL.statut%TYPE;
BEGIN
    SELECT statut
    INTO v_statut_satellite
    FROM SATELLITE
    WHERE id_satellite = :NEW.id_satellite;

    IF v_statut_satellite = 'Désorbité' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insertion interdite : satellite désorbité.');
    END IF;

    SELECT statut
    INTO v_statut_station
    FROM STATION_SOL
    WHERE code_station = :NEW.code_station;

    IF v_statut_station = 'Maintenance' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insertion interdite : station en maintenance.');
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_valider_fenetre;

-- Tests commentes :
-- Cas valide attendu : insertion acceptee.
-- INSERT INTO FENETRE_COM (datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
-- VALUES (TIMESTAMP '2024-02-01 10:00:00', 300, 70, NULL, 'Planifiée', 'SAT-001', 'GS-KIR-01');
-- ROLLBACK;
--
-- Cas erreur ORA-20001 attendu : SAT-005 est Désorbité.
-- INSERT INTO FENETRE_COM (datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
-- VALUES (TIMESTAMP '2024-02-01 10:00:00', 300, 70, NULL, 'Planifiée', 'SAT-005', 'GS-KIR-01');
--
-- Cas erreur ORA-20002 attendu : GS-SGP-01 est en Maintenance.
-- INSERT INTO FENETRE_COM (datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
-- VALUES (TIMESTAMP '2024-02-01 10:00:00', 300, 70, NULL, 'Planifiée', 'SAT-001', 'GS-SGP-01');

-- ============================================================================
-- T2 - trg_no_chevauchement
-- Regles : RG-F02, RG-F03
-- Verifie qu'une fenetre ne chevauche aucune autre fenetre du meme satellite
-- ni aucune autre fenetre de la meme station.
--
-- Implementation en COMPOUND TRIGGER : une requete sur FENETRE_COM dans un
-- trigger ligne classique provoquerait une erreur de table mutante Oracle.
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_no_chevauchement
FOR INSERT OR UPDATE ON FENETRE_COM
COMPOUND TRIGGER
    TYPE t_fenetre IS RECORD (
        id_fenetre FENETRE_COM.id_fenetre%TYPE,
        datetime_debut FENETRE_COM.datetime_debut%TYPE,
        duree FENETRE_COM.duree%TYPE,
        id_satellite FENETRE_COM.id_satellite%TYPE,
        code_station FENETRE_COM.code_station%TYPE
    );

    TYPE t_fenetres IS TABLE OF t_fenetre INDEX BY PLS_INTEGER;

    g_fenetres t_fenetres;

    AFTER EACH ROW IS
        v_index PLS_INTEGER;
    BEGIN
        v_index := g_fenetres.COUNT + 1;
        g_fenetres(v_index).id_fenetre := :NEW.id_fenetre;
        g_fenetres(v_index).datetime_debut := :NEW.datetime_debut;
        g_fenetres(v_index).duree := :NEW.duree;
        g_fenetres(v_index).id_satellite := :NEW.id_satellite;
        g_fenetres(v_index).code_station := :NEW.code_station;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_nb_chevauchements NUMBER;
    BEGIN
        FOR i IN 1 .. g_fenetres.COUNT LOOP
            SELECT COUNT(*)
            INTO v_nb_chevauchements
            FROM FENETRE_COM f
            WHERE (f.id_satellite = g_fenetres(i).id_satellite
                   OR f.code_station = g_fenetres(i).code_station)
              AND (g_fenetres(i).id_fenetre IS NULL
                   OR f.id_fenetre <> g_fenetres(i).id_fenetre)
              AND f.datetime_debut < g_fenetres(i).datetime_debut + NUMTODSINTERVAL(g_fenetres(i).duree, 'SECOND')
              AND g_fenetres(i).datetime_debut < f.datetime_debut + NUMTODSINTERVAL(f.duree, 'SECOND');

            IF v_nb_chevauchements > 0 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Insertion ou mise a jour interdite : chevauchement de fenetres.');
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END trg_no_chevauchement;
/
SHOW ERRORS TRIGGER trg_no_chevauchement;

-- Tests commentes :
-- Cas erreur ORA-20003 attendu : SAT-001 a deja une fenetre le 2024-01-15 a 09:14 pendant 420 s.
-- INSERT INTO FENETRE_COM (datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
-- VALUES (TIMESTAMP '2024-01-15 09:16:00', 120, 60, NULL, 'Planifiée', 'SAT-001', 'GS-TLS-01');
--
-- Cas erreur ORA-20003 attendu : GS-KIR-01 a deja une fenetre le 2024-01-16 a 08:30 pendant 540 s.
-- INSERT INTO FENETRE_COM (datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
-- VALUES (TIMESTAMP '2024-01-16 08:31:00', 120, 60, NULL, 'Planifiée', 'SAT-002', 'GS-KIR-01');

-- ============================================================================
-- T3 - trg_volume_realise
-- Regle : RG-F05
-- Force volume_donnees a NULL si la fenetre n'est pas Realisee.
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_volume_realise
BEFORE INSERT OR UPDATE ON FENETRE_COM
FOR EACH ROW
BEGIN
    IF :NEW.statut <> 'Réalisée' THEN
        :NEW.volume_donnees := NULL;
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_volume_realise;

-- Tests commentes :
-- Cas attendu : volume_donnees sera force a NULL car statut = Planifiee.
-- INSERT INTO FENETRE_COM (datetime_debut, duree, elevation_max, volume_donnees, statut, id_satellite, code_station)
-- VALUES (TIMESTAMP '2024-02-02 12:00:00', 300, 65, 999, 'Planifiée', 'SAT-002', 'GS-KIR-01');
-- SELECT volume_donnees FROM FENETRE_COM WHERE datetime_debut = TIMESTAMP '2024-02-02 12:00:00';
-- ROLLBACK;

-- ============================================================================
-- T4 - trg_mission_terminee
-- Regles : RG-M04 et rappel RG-S06 pour les nouvelles participations.
-- Bloque l'ajout d'un satellite a une mission terminee. Bloque aussi l'ajout
-- d'un satellite actuellement Desorbite a une nouvelle participation.
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_mission_terminee
BEFORE INSERT ON PARTICIPATION
FOR EACH ROW
DECLARE
    v_statut_mission MISSION.statut_mission%TYPE;
    v_statut_satellite SATELLITE.statut%TYPE;
BEGIN
    SELECT statut_mission
    INTO v_statut_mission
    FROM MISSION
    WHERE id_mission = :NEW.id_mission;

    IF v_statut_mission = 'Terminée' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Insertion interdite : mission terminee.');
    END IF;

    SELECT statut
    INTO v_statut_satellite
    FROM SATELLITE
    WHERE id_satellite = :NEW.id_satellite;

    IF v_statut_satellite = 'Désorbité' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insertion interdite : satellite désorbité.');
    END IF;
END;
/
SHOW ERRORS TRIGGER trg_mission_terminee;

-- Tests commentes :
-- Cas erreur ORA-20004 attendu : MSN-DEF-2022 est Terminée.
-- INSERT INTO PARTICIPATION (id_satellite, id_mission, role_satellite)
-- VALUES ('SAT-004', 'MSN-DEF-2022', 'Satellite de test');
--
-- Cas erreur ORA-20001 attendu : SAT-005 est Désorbité.
-- INSERT INTO PARTICIPATION (id_satellite, id_mission, role_satellite)
-- VALUES ('SAT-005', 'MSN-ARC-2023', 'Satellite de test');

-- ============================================================================
-- T5 - trg_historique_statut
-- Trace les changements de statut des satellites dans HISTORIQUE_STATUT.
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_historique_statut
AFTER UPDATE OF statut ON SATELLITE
FOR EACH ROW
WHEN (OLD.statut <> NEW.statut)
BEGIN
    INSERT INTO HISTORIQUE_STATUT (
        id_satellite,
        ancien_statut,
        nouveau_statut,
        date_changement,
        motif
    ) VALUES (
        :OLD.id_satellite,
        :OLD.statut,
        :NEW.statut,
        SYSTIMESTAMP,
        'Changement de statut satellite'
    );
END;
/
SHOW ERRORS TRIGGER trg_historique_statut;

-- Tests commentes :
-- Cas attendu : une ligne est ajoutee dans HISTORIQUE_STATUT.
-- UPDATE SATELLITE SET statut = 'En veille' WHERE id_satellite = 'SAT-001';
-- SELECT * FROM HISTORIQUE_STATUT WHERE id_satellite = 'SAT-001' ORDER BY date_changement DESC;
-- ROLLBACK;

-- Fin du script L2-C.
