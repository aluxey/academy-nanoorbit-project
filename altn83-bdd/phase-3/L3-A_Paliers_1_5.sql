-- ============================================================================
-- NanoOrbit - Phase 3 - Livrable L3-A
-- Fichier : L3-A_Paliers_1_5.sql
-- Objet   : Exercices PL/SQL paliers 1 a 5, exercices 1 a 16
-- SGBD    : Oracle 23ai
-- Schema  : NANOORBIT_ADMIN
-- Prerequis : Phase 2 executee, donnees chargees, triggers operationnels
-- ============================================================================

SET SERVEROUTPUT ON;

-- ============================================================================
-- Palier 1 - Bloc anonyme
-- ============================================================================

-- Ex. 1 : Afficher un message de bienvenue et le nombre de satellites,
-- stations et missions de la base.
DECLARE
    v_nb_satellites NUMBER;
    v_nb_stations NUMBER;
    v_nb_missions NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_nb_satellites FROM SATELLITE;
    SELECT COUNT(*) INTO v_nb_stations FROM STATION_SOL;
    SELECT COUNT(*) INTO v_nb_missions FROM MISSION;

    DBMS_OUTPUT.PUT_LINE('Bienvenue dans NanoOrbit');
    DBMS_OUTPUT.PUT_LINE('Satellites : ' || v_nb_satellites);
    DBMS_OUTPUT.PUT_LINE('Stations   : ' || v_nb_stations);
    DBMS_OUTPUT.PUT_LINE('Missions   : ' || v_nb_missions);
END;
/

-- Resultat attendu : Satellites = 5, Stations = 3, Missions = 3.

-- Ex. 2 : Recuperer et afficher les caracteristiques du satellite SAT-001.
DECLARE
    v_nom SATELLITE.nom_satellite%TYPE;
    v_statut SATELLITE.statut%TYPE;
    v_format SATELLITE.format_cubesat%TYPE;
    v_batterie SATELLITE.capacite_batterie%TYPE;
BEGIN
    SELECT nom_satellite, statut, format_cubesat, capacite_batterie
    INTO v_nom, v_statut, v_format, v_batterie
    FROM SATELLITE
    WHERE id_satellite = 'SAT-001';

    DBMS_OUTPUT.PUT_LINE('SAT-001 : ' || v_nom || ', statut=' || v_statut ||
                         ', format=' || v_format || ', batterie=' || v_batterie || ' Wh');
END;
/

-- Resultat attendu : NanoOrbit-Alpha, Opérationnel, 3U, 20 Wh.

-- ============================================================================
-- Palier 2 - Variables et types
-- ============================================================================

-- Ex. 3 : Lire une ligne complete de SATELLITE avec %ROWTYPE.
DECLARE
    v_satellite SATELLITE%ROWTYPE;
BEGIN
    SELECT *
    INTO v_satellite
    FROM SATELLITE
    WHERE id_satellite = 'SAT-004';

    DBMS_OUTPUT.PUT_LINE(v_satellite.id_satellite || ' - ' || v_satellite.nom_satellite);
    DBMS_OUTPUT.PUT_LINE('Statut : ' || v_satellite.statut);
    DBMS_OUTPUT.PUT_LINE('Capacite batterie : ' || v_satellite.capacite_batterie || ' Wh');
END;
/

-- Resultat attendu : SAT-004, statut En veille, batterie 40 Wh.

-- Ex. 4 : Gerer les NULL avec NVL sur la resolution instrument.
DECLARE
    v_ref INSTRUMENT.ref_instrument%TYPE := 'INS-AIS-01';
    v_modele INSTRUMENT.modele%TYPE;
    v_resolution VARCHAR2(30);
BEGIN
    SELECT modele, NVL(TO_CHAR(resolution), 'N/A')
    INTO v_modele, v_resolution
    FROM INSTRUMENT
    WHERE ref_instrument = v_ref;

    DBMS_OUTPUT.PUT_LINE(v_ref || ' - ' || v_modele || ' - resolution=' || v_resolution);
END;
/

-- Resultat attendu : resolution=N/A pour INS-AIS-01.

-- ============================================================================
-- Palier 3 - Structures de controle
-- ============================================================================

-- Ex. 5 : IF/ELSIF - Categoriser un satellite selon son statut et sa duree de vie.
DECLARE
    v_id SATELLITE.id_satellite%TYPE := 'SAT-005';
    v_statut SATELLITE.statut%TYPE;
    v_duree SATELLITE.duree_vie_prevue%TYPE;
    v_categorie VARCHAR2(100);
BEGIN
    SELECT statut, duree_vie_prevue
    INTO v_statut, v_duree
    FROM SATELLITE
    WHERE id_satellite = v_id;

    IF v_statut = 'Désorbité' THEN
        v_categorie := 'Retire de la constellation';
    ELSIF v_statut = 'Défaillant' THEN
        v_categorie := 'Intervention prioritaire';
    ELSIF v_statut = 'En veille' THEN
        v_categorie := 'Surveillance operationnelle';
    ELSIF v_duree >= 60 THEN
        v_categorie := 'Satellite operationnel longue duree';
    ELSE
        v_categorie := 'Satellite operationnel courte duree';
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_id || ' : ' || v_categorie);
END;
/

-- Resultat attendu : SAT-005 retire de la constellation.

-- Ex. 6 : CASE - Afficher le type d'orbite et calculer la vitesse orbitale.
DECLARE
    v_id SATELLITE.id_satellite%TYPE := 'SAT-003';
    v_type_orbite ORBITE.type_orbite%TYPE;
    v_altitude ORBITE.altitude%TYPE;
    v_periode ORBITE.periode_orbitale%TYPE;
    v_description VARCHAR2(100);
    v_vitesse NUMBER;
BEGIN
    SELECT o.type_orbite, o.altitude, o.periode_orbitale
    INTO v_type_orbite, v_altitude, v_periode
    FROM SATELLITE s
    JOIN ORBITE o ON o.id_orbite = s.id_orbite
    WHERE s.id_satellite = v_id;

    v_description := CASE v_type_orbite
        WHEN 'SSO' THEN 'Orbite heliosynchrone'
        WHEN 'LEO' THEN 'Orbite basse'
        WHEN 'MEO' THEN 'Orbite moyenne'
        WHEN 'GEO' THEN 'Orbite geostationnaire'
        ELSE 'Orbite inconnue'
    END;

    v_vitesse := (2 * ACOS(-1) * (6371 + v_altitude)) / v_periode;

    DBMS_OUTPUT.PUT_LINE(v_id || ' : ' || v_description ||
                         ', vitesse approx=' || ROUND(v_vitesse, 2) || ' km/min');
END;
/

-- Resultat attendu : SAT-003 en SSO, vitesse orbitale approx calculee.

-- Ex. 7 : Boucle FOR - Grille des volumes attendus pour GS-TLS-01.
DECLARE
    v_debit_mbps STATION_SOL.debit_max%TYPE;
    v_volume_mo NUMBER;
BEGIN
    SELECT debit_max
    INTO v_debit_mbps
    FROM STATION_SOL
    WHERE code_station = 'GS-TLS-01';

    FOR v_minutes IN 5 .. 15 LOOP
        v_volume_mo := (v_debit_mbps * v_minutes * 60) / 8;
        DBMS_OUTPUT.PUT_LINE(v_minutes || ' min -> ' || ROUND(v_volume_mo, 1) || ' Mo');
    END LOOP;
END;
/

-- Resultat attendu : volumes croissants pour 5 a 15 minutes avec debit 150 Mbps.

-- ============================================================================
-- Palier 4 - Curseurs
-- ============================================================================

-- Ex. 8 : SQL%ROWCOUNT - Mettre a jour plusieurs satellites et afficher le nombre.
BEGIN
    UPDATE SATELLITE
    SET statut = 'En veille'
    WHERE statut = 'Défaillant';

    DBMS_OUTPUT.PUT_LINE('Satellites mis a jour : ' || SQL%ROWCOUNT);

    ROLLBACK;
END;
/

-- Resultat attendu avec le jeu initial : 0 ligne modifiee.

-- Ex. 9 : Cursor FOR Loop - Satellites avec orbite, statut et instruments.
BEGIN
    FOR r_sat IN (
        SELECT s.id_satellite,
               s.nom_satellite,
               s.statut,
               o.type_orbite,
               COUNT(e.ref_instrument) AS nb_instruments
        FROM SATELLITE s
        JOIN ORBITE o ON o.id_orbite = s.id_orbite
        LEFT JOIN EMBARQUEMENT e ON e.id_satellite = s.id_satellite
        GROUP BY s.id_satellite, s.nom_satellite, s.statut, o.type_orbite
        ORDER BY s.id_satellite
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r_sat.id_satellite || ' - ' || r_sat.nom_satellite ||
                             ' - ' || r_sat.statut || ' - ' || r_sat.type_orbite ||
                             ' - instruments=' || r_sat.nb_instruments);
    END LOOP;
END;
/

-- Resultat attendu : 5 satellites listes avec leur nombre d'instruments.

-- Ex. 10 : Curseur explicite OPEN/FETCH/CLOSE - Satellites operationnels avec
-- leur station de communication la plus recente.
DECLARE
    CURSOR c_sat IS
        SELECT s.id_satellite,
               s.nom_satellite,
               MAX(f.datetime_debut) AS derniere_fenetre
        FROM SATELLITE s
        LEFT JOIN FENETRE_COM f ON f.id_satellite = s.id_satellite
        WHERE s.statut = 'Opérationnel'
        GROUP BY s.id_satellite, s.nom_satellite
        ORDER BY s.id_satellite;

    v_id SATELLITE.id_satellite%TYPE;
    v_nom SATELLITE.nom_satellite%TYPE;
    v_derniere FENETRE_COM.datetime_debut%TYPE;
    v_station STATION_SOL.code_station%TYPE;
BEGIN
    OPEN c_sat;
    LOOP
        FETCH c_sat INTO v_id, v_nom, v_derniere;
        EXIT WHEN c_sat%NOTFOUND;

        IF v_derniere IS NULL THEN
            DBMS_OUTPUT.PUT_LINE(v_id || ' - ' || v_nom || ' - aucune fenetre');
        ELSE
            SELECT code_station
            INTO v_station
            FROM FENETRE_COM
            WHERE id_satellite = v_id
              AND datetime_debut = v_derniere;

            DBMS_OUTPUT.PUT_LINE(v_id || ' - ' || v_nom || ' - derniere station=' || v_station);
        END IF;
    END LOOP;
    CLOSE c_sat;
END;
/

-- Resultat attendu : SAT-001, SAT-002 et SAT-003 avec leur derniere station.

-- Ex. 11 : Curseur parametre - Fenetres d'une station et volume total.
DECLARE
    CURSOR c_fenetres_station(p_code_station STATION_SOL.code_station%TYPE) IS
        SELECT id_fenetre, datetime_debut, statut, NVL(volume_donnees, 0) AS volume
        FROM FENETRE_COM
        WHERE code_station = p_code_station
        ORDER BY datetime_debut;

    v_total NUMBER := 0;
BEGIN
    FOR r_fenetre IN c_fenetres_station('GS-TLS-01') LOOP
        v_total := v_total + r_fenetre.volume;
        DBMS_OUTPUT.PUT_LINE('Fenetre ' || r_fenetre.id_fenetre || ' - ' ||
                             r_fenetre.statut || ' - volume=' || r_fenetre.volume);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Volume total GS-TLS-01 : ' || v_total || ' Mo');
END;
/

-- Resultat attendu : fenetres de GS-TLS-01 et volume total realise.

-- ============================================================================
-- Palier 5 - Procedures et fonctions standalone
-- ============================================================================

-- Ex. 12 : Exceptions predefinies - SELECT INTO securise sur SATELLITE.
DECLARE
    v_id SATELLITE.id_satellite%TYPE := 'SAT-999';
    v_nom SATELLITE.nom_satellite%TYPE;
BEGIN
    SELECT nom_satellite
    INTO v_nom
    FROM SATELLITE
    WHERE id_satellite = v_id;

    DBMS_OUTPUT.PUT_LINE(v_id || ' : ' || v_nom);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Aucun satellite trouve pour ' || v_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
END;
/

-- Resultat attendu : aucun satellite trouve pour SAT-999.

-- Ex. 13 : RAISE_APPLICATION_ERROR - Validation d'une fenetre avant insertion.
DECLARE
    v_id_satellite SATELLITE.id_satellite%TYPE := 'SAT-001';
    v_code_station STATION_SOL.code_station%TYPE := 'GS-KIR-01';
    v_datetime TIMESTAMP := TIMESTAMP '2024-02-05 10:00:00';
    v_duree NUMBER := 300;
    v_statut_satellite SATELLITE.statut%TYPE;
    v_statut_station STATION_SOL.statut%TYPE;
    v_nb_chevauchements NUMBER;
BEGIN
    SELECT statut INTO v_statut_satellite FROM SATELLITE WHERE id_satellite = v_id_satellite;
    SELECT statut INTO v_statut_station FROM STATION_SOL WHERE code_station = v_code_station;

    IF v_statut_satellite <> 'Opérationnel' THEN
        RAISE_APPLICATION_ERROR(-20101, 'Satellite non operationnel.');
    END IF;

    IF v_statut_station <> 'Active' THEN
        RAISE_APPLICATION_ERROR(-20102, 'Station non active.');
    END IF;

    SELECT COUNT(*)
    INTO v_nb_chevauchements
    FROM FENETRE_COM f
    WHERE (f.id_satellite = v_id_satellite OR f.code_station = v_code_station)
      AND f.datetime_debut < v_datetime + NUMTODSINTERVAL(v_duree, 'SECOND')
      AND v_datetime < f.datetime_debut + NUMTODSINTERVAL(f.duree, 'SECOND');

    IF v_nb_chevauchements > 0 THEN
        RAISE_APPLICATION_ERROR(-20103, 'Chevauchement detecte.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Fenetre validee avant insertion.');
END;
/

-- Resultat attendu : fenetre validee avant insertion.

-- Ex. 14 : Procedure socle - afficher_statut_satellite.
CREATE OR REPLACE PROCEDURE afficher_statut_satellite(p_id IN SATELLITE.id_satellite%TYPE)
IS
    v_nom SATELLITE.nom_satellite%TYPE;
    v_statut SATELLITE.statut%TYPE;
    v_type_orbite ORBITE.type_orbite%TYPE;
BEGIN
    SELECT s.nom_satellite, s.statut, o.type_orbite
    INTO v_nom, v_statut, v_type_orbite
    FROM SATELLITE s
    JOIN ORBITE o ON o.id_orbite = s.id_orbite
    WHERE s.id_satellite = p_id;

    DBMS_OUTPUT.PUT_LINE(p_id || ' - ' || v_nom || ' - ' || v_statut || ' - orbite=' || v_type_orbite);

    FOR r_ins IN (
        SELECT i.ref_instrument, i.type_instrument, e.etat_fonctionnement
        FROM EMBARQUEMENT e
        JOIN INSTRUMENT i ON i.ref_instrument = e.ref_instrument
        WHERE e.id_satellite = p_id
        ORDER BY i.ref_instrument
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  Instrument : ' || r_ins.ref_instrument || ' - ' ||
                             r_ins.type_instrument || ' - ' || r_ins.etat_fonctionnement);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Satellite introuvable : ' || p_id);
END;
/
SHOW ERRORS PROCEDURE afficher_statut_satellite;

BEGIN
    afficher_statut_satellite('SAT-001');
END;
/

-- Ex. 15 : Procedure socle - mettre_a_jour_statut.
CREATE OR REPLACE PROCEDURE mettre_a_jour_statut(
    p_id IN SATELLITE.id_satellite%TYPE,
    p_statut IN SATELLITE.statut%TYPE,
    p_ancien_statut OUT SATELLITE.statut%TYPE
)
IS
BEGIN
    SELECT statut
    INTO p_ancien_statut
    FROM SATELLITE
    WHERE id_satellite = p_id;

    UPDATE SATELLITE
    SET statut = p_statut
    WHERE id_satellite = p_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20110, 'Satellite introuvable : ' || p_id);
END;
/
SHOW ERRORS PROCEDURE mettre_a_jour_statut;

DECLARE
    v_ancien SATELLITE.statut%TYPE;
BEGIN
    mettre_a_jour_statut('SAT-004', 'Opérationnel', v_ancien);
    DBMS_OUTPUT.PUT_LINE('Ancien statut SAT-004 : ' || v_ancien);
    ROLLBACK;
END;
/

-- Ex. 16 : Fonction socle - calculer_volume_session.
CREATE OR REPLACE FUNCTION calculer_volume_session(p_id_fenetre IN FENETRE_COM.id_fenetre%TYPE)
RETURN NUMBER
IS
    v_duree FENETRE_COM.duree%TYPE;
    v_debit STATION_SOL.debit_max%TYPE;
    v_volume NUMBER;
BEGIN
    SELECT f.duree, st.debit_max
    INTO v_duree, v_debit
    FROM FENETRE_COM f
    JOIN STATION_SOL st ON st.code_station = f.code_station
    WHERE f.id_fenetre = p_id_fenetre;

    v_volume := (v_debit * v_duree) / 8;
    RETURN ROUND(v_volume, 1);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20120, 'Fenetre introuvable : ' || p_id_fenetre);
END;
/
SHOW ERRORS FUNCTION calculer_volume_session;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Volume theorique fenetre 1 : ' || calculer_volume_session(1) || ' Mo');
END;
/

-- Fin du livrable L3-A.
