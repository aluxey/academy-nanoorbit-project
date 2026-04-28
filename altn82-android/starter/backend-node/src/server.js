require('dotenv').config();
const express = require('express');
const oracledb = require('oracledb');

const app = express();
app.use(express.json());

// Configuration de la connexion (à mettre dans un fichier .env idéalement)
const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  connectString: process.env.DB_CONNECT_STRING 
};

const executeQuery  = async (query, params = {}, options = {}) => {
  let conn;
  try {
    conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(query, params, {
      outFormat: oracledb.OUT_FORMAT_OBJECT,
      autoCommit: true,
      ...options
    });
    return result;
  } catch (err) {
    throw err;
  } finally {
    if (conn) await conn.close();
  }
}

// Route Health : Vérifie si la BD répond
app.get("/health", async (req, res) => {
  try {
    const result = await executeQuery("SELECT 1 FROM DUAL");
    res.json({ status: "OK", message: result.rows });
  } catch (err) {
    res.status(500).json({
      status: "ERROR",
      message: "La base de données ne répond pas",
      error: err.message
    });
  }
});

app.get("/api/satellites", async (req, res) => {
  try {
    const result = await executeQuery(`
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
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ status: "ERROR", error: err.message });
  }
});

app.get("/api/fenetres", async (req, res) => {
  try {
    const result = await executeQuery(`
      SELECT ID_FENETRE, DATETIME_DEBUT, DUREE, STATUT, ID_SATELLITE, CODE_STATION, VOLUME_DONNEES
      FROM FENETRE_COM
      ORDER BY DATETIME_DEBUT
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ status: "ERROR", error: err.message });
  }
});

app.get("/api/satellites/:id/anomalies", async (req, res) => {
  try {
    const result = await executeQuery(
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
      { satelliteId: req.params.id }
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ status: "ERROR", error: err.message });
  }
});

app.post("/api/fenetres", async (req, res) => {
  try {
    const { datetimeDebut, duree, idSatellite, codeStation, volumeDonnees } = req.body;
    if (!datetimeDebut || !duree || !idSatellite || !codeStation) {
      return res
        .status(400)
        .json({ status: "ERROR", message: "datetimeDebut, duree, idSatellite et codeStation sont requis." });
    }

    await executeQuery(
      `
      INSERT INTO FENETRE_COM (DATETIME_DEBUT, DUREE, ELEVATION_MAX, VOLUME_DONNEES, STATUT, ID_SATELLITE, CODE_STATION)
      VALUES (:datetimeDebut, :duree, 45, :volumeDonnees, 'Planifiée', :idSatellite, :codeStation)
      `,
      {
        datetimeDebut: new Date(datetimeDebut),
        duree,
        idSatellite,
        codeStation,
        volumeDonnees: volumeDonnees ?? null
      }
    );

    return res.status(201).json({ status: "OK" });
  } catch (err) {
    return res.status(500).json({ status: "ERROR", error: err.message });
  }
});

app.patch("/api/fenetres/:id/realisee", async (req, res) => {
  try {
    const result = await executeQuery(
      `
      UPDATE FENETRE_COM
      SET STATUT = 'Réalisée'
      WHERE ID_FENETRE = :idFenetre
        AND STATUT <> 'Réalisée'
        AND TRUNC(DATETIME_DEBUT) < TRUNC(SYSDATE)
      `,
      { idFenetre: Number(req.params.id) }
    );

    if ((result.rowsAffected || 0) !== 1) {
      return res.status(409).json({ status: "ERROR", message: "Fenetre introuvable ou non eligible." });
    }

    return res.status(204).send();
  } catch (err) {
    return res.status(500).json({ status: "ERROR", error: err.message });
  }
});

app.post("/api/anomalies", async (req, res) => {
  try {
    const { satelliteId, description } = req.body;
    if (!satelliteId || !description?.trim()) {
      return res.status(400).json({ status: "ERROR", message: "satelliteId et description sont requis." });
    }

    const sat = await executeQuery(
      `SELECT STATUT FROM SATELLITE WHERE ID_SATELLITE = :satelliteId`,
      { satelliteId }
    );
    if (!sat.rows.length) {
      return res.status(404).json({ status: "ERROR", message: "Satellite introuvable." });
    }

    const ancienStatut = sat.rows[0].STATUT;
    const nouveauStatut = ancienStatut === "Défaillant" ? "En veille" : "Défaillant";

    await executeQuery(
      `
      INSERT INTO HISTORIQUE_STATUT (ID_SATELLITE, ANCIEN_STATUT, NOUVEAU_STATUT, MOTIF)
      VALUES (:satelliteId, :ancienStatut, :nouveauStatut, :description)
      `,
      {
        satelliteId,
        ancienStatut,
        nouveauStatut,
        description: description.trim()
      }
    );

    return res.status(201).json({ status: "OK" });
  } catch (err) {
    return res.status(500).json({ status: "ERROR", error: err.message });
  }
});

app.patch("/api/anomalies/:id/traitee", async (req, res) => {
  try {
    const result = await executeQuery(
      `
      UPDATE HISTORIQUE_STATUT
      SET NOUVEAU_STATUT = 'Opérationnel'
      WHERE ID_HISTORIQUE = :idAnomalie
        AND NOUVEAU_STATUT <> 'Opérationnel'
      `,
      { idAnomalie: Number(req.params.id) }
    );

    if ((result.rowsAffected || 0) !== 1) {
      return res.status(409).json({ status: "ERROR", message: "Anomalie introuvable ou deja traitee." });
    }

    return res.status(204).send();
  } catch (err) {
    return res.status(500).json({ status: "ERROR", error: err.message });
  }
});

const PORT = Number(process.env.SERVER_PORT || process.env.PORT || 3001);
app.listen(PORT, () => {
  console.log(`Serveur démarré sur http://localhost:${PORT}`);
});
