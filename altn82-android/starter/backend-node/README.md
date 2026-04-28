# NanoOrbit Backend Node (Oracle)

Backend Node.js pour reproduire les memes requetes metier que le `NanoOrbitRepository` Android, mais sur Oracle.

## Prerequis

- Node.js 20+
- Oracle DB accessible (locale ou distante)
- Oracle Instant Client si necessaire pour `oracledb` en mode thick

## Installation

```bash
cd backend-node
npm install
```

Copier `.env.example` vers `.env` puis renseigner les valeurs Oracle.
Pour une DB Oracle exposee depuis Docker, definir au minimum `ORACLE_HOST`, `ORACLE_PORT` (ton port `XXX`) et `ORACLE_SERVICE_NAME`.

## Initialisation base Oracle

Executer:

- `sql/schema.sql`
- `sql/seed.sql` (optionnel, pour charger les donnees mock)

## Lancement

```bash
npm run dev
```

Serveur: `http://localhost:3001`

## Endpoints (equivalents Android)

- `GET /api/satellites`
  - Equivalent `getSatellites()`
- `GET /api/fenetres`
  - Equivalent `getFenetres()` (tri par `datetimeDebut`)
- `POST /api/fenetres`
  - Equivalent `addFenetre(...)`
- `PATCH /api/fenetres/:id/realisee`
  - Equivalent `markFenetreAsRealisee(...)`
  - Meme regle: seulement si statut != `REALISEE` et date de debut < aujourd'hui
- `GET /api/satellites/:id/anomalies`
  - Equivalent `getAnomaliesForSatellite(...)` (tri date desc)
- `POST /api/anomalies`
  - Equivalent `addAnomalie(...)`
- `PATCH /api/anomalies/:id/traitee`
  - Equivalent `markAnomalieAsTraitee(...)`

## Exemples JSON

### POST /api/fenetres

```json
{
  "datetimeDebut": "2026-04-30T14:30:00Z",
  "duree": 420,
  "idSatellite": "SAT-001",
  "codeStation": "FR-TLS",
  "volumeDonnees": 250.5
}
```

### POST /api/anomalies

```json
{
  "satelliteId": "SAT-001",
  "description": "Perte intermittente du signal."
}
```
