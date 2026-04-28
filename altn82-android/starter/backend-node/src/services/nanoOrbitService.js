const oracledb = require("oracledb");
const { getConnection } = require("../db/oracle");

async function withConnection(callback) {
  const connection = await getConnection();
  try {
    return await callback(connection);
  } finally {
    await connection.close();
  }
}

async function getSatellites() {
  return withConnection(async (conn) => {
    const result = await conn.execute(
      `
      SELECT
        ID_SATELLITE,
        NOM_SATELLITE AS NOM,
        STATUT,
        FORMAT_CUBESAT,
        ID_ORBITE,
        DATE_LANCEMENT,
        MASSE
      FROM SATELLITE
      ORDER BY ID_SATELLITE
      `,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );
    return result.rows;
  });
}

async function getFenetres() {
  return withConnection(async (conn) => {
    const result = await conn.execute(
      `
      SELECT ID_FENETRE, DATETIME_DEBUT, DUREE, STATUT, ID_SATELLITE, CODE_STATION, VOLUME_DONNEES
      FROM FENETRE_COM
      ORDER BY DATETIME_DEBUT
      `,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );
    return result.rows;
  });
}

async function addFenetre({ datetimeDebut, duree, idSatellite, codeStation, volumeDonnees = null }) {
  return withConnection(async (conn) => {
    const result = await conn.execute(
      `
      INSERT INTO FENETRE_COM (DATETIME_DEBUT, DUREE, ELEVATION_MAX, VOLUME_DONNEES, STATUT, ID_SATELLITE, CODE_STATION)
      VALUES (:datetimeDebut, :duree, 45, :volumeDonnees, 'Planifiée', :idSatellite, :codeStation)
      RETURNING ID_FENETRE INTO :idFenetre
      `,
      {
        datetimeDebut: new Date(datetimeDebut),
        duree,
        idSatellite,
        codeStation,
        volumeDonnees,
        idFenetre: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
      },
      { autoCommit: true }
    );

    const idFenetre = result.outBinds.idFenetre[0];
    return getFenetreById(conn, idFenetre);
  });
}

async function getFenetreById(conn, idFenetre) {
  const result = await conn.execute(
    `
    SELECT ID_FENETRE, DATETIME_DEBUT, DUREE, STATUT, ID_SATELLITE, CODE_STATION, VOLUME_DONNEES
    FROM FENETRE_COM
    WHERE ID_FENETRE = :idFenetre
    `,
    { idFenetre },
    { outFormat: oracledb.OUT_FORMAT_OBJECT }
  );
  return result.rows[0] || null;
}

async function markFenetreAsRealisee(idFenetre) {
  return withConnection(async (conn) => {
    const result = await conn.execute(
      `
      UPDATE FENETRE_COM
      SET STATUT = 'Réalisée'
      WHERE ID_FENETRE = :idFenetre
        AND STATUT <> 'Réalisée'
        AND TRUNC(DATETIME_DEBUT) < TRUNC(SYSDATE)
      `,
      { idFenetre },
      { autoCommit: true }
    );
    return result.rowsAffected === 1;
  });
}

async function getAnomaliesForSatellite(satelliteId) {
  return withConnection(async (conn) => {
    const result = await conn.execute(
      `
      SELECT
        ID_HISTORIQUE AS ID_ANOMALIE,
        ID_SATELLITE,
        DATE_CHANGEMENT AS DATE_SIGNALEMENT,
        MOTIF AS DESCRIPTION,
        NOUVEAU_STATUT AS STATUT
      FROM HISTORIQUE_STATUT
      WHERE ID_SATELLITE = :satelliteId
      ORDER BY DATE_CHANGEMENT DESC
      `,
      { satelliteId },
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );
    return result.rows;
  });
}

async function addAnomalie({ satelliteId, description }) {
  return withConnection(async (conn) => {
    const satellite = await conn.execute(
      `
      SELECT STATUT
      FROM SATELLITE
      WHERE ID_SATELLITE = :satelliteId
      `,
      { satelliteId },
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );

    if (!satellite.rows.length) {
      throw new Error(`Satellite introuvable: ${satelliteId}`);
    }

    const ancienStatut = satellite.rows[0].STATUT;
    const nouveauStatut = ancienStatut === "Défaillant" ? "En veille" : "Défaillant";

    const result = await conn.execute(
      `
      INSERT INTO HISTORIQUE_STATUT (ID_SATELLITE, ANCIEN_STATUT, NOUVEAU_STATUT, MOTIF)
      VALUES (:satelliteId, :ancienStatut, :nouveauStatut, :description)
      RETURNING ID_HISTORIQUE INTO :idAnomalie
      `,
      {
        satelliteId,
        ancienStatut,
        nouveauStatut,
        description: description.trim(),
        idAnomalie: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
      },
      { autoCommit: true }
    );

    const idAnomalie = result.outBinds.idAnomalie[0];
    const one = await conn.execute(
      `
      SELECT
        ID_HISTORIQUE AS ID_ANOMALIE,
        ID_SATELLITE,
        DATE_CHANGEMENT AS DATE_SIGNALEMENT,
        MOTIF AS DESCRIPTION,
        NOUVEAU_STATUT AS STATUT
      FROM HISTORIQUE_STATUT
      WHERE ID_HISTORIQUE = :idAnomalie
      `,
      { idAnomalie },
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );
    return one.rows[0] || null;
  });
}

async function markAnomalieAsTraitee(idAnomalie) {
  return withConnection(async (conn) => {
    const result = await conn.execute(
      `
      UPDATE HISTORIQUE_STATUT
      SET NOUVEAU_STATUT = 'Opérationnel'
      WHERE ID_HISTORIQUE = :idAnomalie
        AND NOUVEAU_STATUT <> 'Opérationnel'
      `,
      { idAnomalie },
      { autoCommit: true }
    );
    return result.rowsAffected === 1;
  });
}

module.exports = {
  getSatellites,
  getFenetres,
  addFenetre,
  markFenetreAsRealisee,
  getAnomaliesForSatellite,
  addAnomalie,
  markAnomalieAsTraitee
};
