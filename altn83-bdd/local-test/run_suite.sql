WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET VERIFY OFF

PROMPT ===== Phase 2 =====
@/workspace/altn83-bdd/phase-2/L2-A_DDL_Tables.sql
@/workspace/altn83-bdd/phase-2/L2-B_DML_Donnees.sql
@/workspace/altn83-bdd/phase-2/L2-C_Triggers.sql
@/workspace/altn83-bdd/phase-2/L2-D_Controle_Schema.sql

PROMPT ===== Phase 3 =====
@/workspace/altn83-bdd/phase-3/L3-A_Paliers_1_5.sql
@/workspace/altn83-bdd/phase-3/L3-B_pkg_nanoOrbit_SPEC.sql
@/workspace/altn83-bdd/phase-3/L3-C_pkg_nanoOrbit_BODY.sql
@/workspace/altn83-bdd/phase-3/L3-D_Validation_pkg_nanoOrbit.sql

PROMPT ===== Final object status =====
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN (
    'PKG_NANOORBIT',
    'TRG_VALIDER_FENETRE',
    'TRG_NO_CHEVAUCHEMENT',
    'TRG_VOLUME_REALISE',
    'TRG_MISSION_TERMINEE',
    'TRG_HISTORIQUE_STATUT'
)
ORDER BY object_type, object_name;

EXIT SUCCESS
