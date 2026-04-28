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

const executeQuery  = async (query, params = []) => {
  let conn;
  try {
    conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(query, params);
    return result.rows;
  } catch (err) {
    throw err;
  } finally {
    if (conn) await conn.close();
  }
}

// Route Health : Vérifie si la BD répond
app.get('/health', async (req, res) => {
  try {
    const result = await executeQuery('SELECT 1 FROM DUAL');
    res.json({ status: 'OK', message: result });
  } catch (err) {
    res.status(500).json({ status: 'ERROR', message: 'La base de données ne répond pas', error: err.message });
  }
});

// Route API 1 : Récupérer la date du serveur Oracle
app.get('/api/date', async (req, res) => {
  let conn;
  try {
    conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(`select * from satellite`);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  } finally {
    if (conn) await conn.close();
  }
});

// Route API 2 : Récupérer les informations de session
app.get('/api/session', async (req, res) => {
  let conn;
  try {
    conn = await oracledb.getConnection(dbConfig);
    const result = await conn.execute(`SELECT sid, serial#, status FROM v$session WHERE username = :user`, [dbConfig.user.toUpperCase()]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  } finally {
    if (conn) await conn.close();
  }
});

const PORT = process.env.SERVER_PORT || 3001;
app.listen(PORT, () => console.log(`Serveur démarré sur http://localhost:${PORT}`));