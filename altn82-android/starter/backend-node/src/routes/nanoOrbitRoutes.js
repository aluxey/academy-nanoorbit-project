const express = require("express");
const service = require("../services/nanoOrbitService");

const router = express.Router();

router.get("/satellites", async (_req, res, next) => {
  try {
    const data = await service.getSatellites();
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.get("/fenetres", async (_req, res, next) => {
  try {
    const data = await service.getFenetres();
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.post("/fenetres", async (req, res, next) => {
  try {
    const { datetimeDebut, duree, idSatellite, codeStation, volumeDonnees } = req.body;
    if (!datetimeDebut || !duree || !idSatellite || !codeStation) {
      return res.status(400).json({ message: "datetimeDebut, duree, idSatellite et codeStation sont requis." });
    }
    const created = await service.addFenetre({ datetimeDebut, duree, idSatellite, codeStation, volumeDonnees });
    return res.status(201).json(created);
  } catch (err) {
    return next(err);
  }
});

router.patch("/fenetres/:id/realisee", async (req, res, next) => {
  try {
    const ok = await service.markFenetreAsRealisee(Number(req.params.id));
    if (!ok) {
      return res.status(409).json({ message: "Fenetre introuvable ou non eligible au passage en REALISEE." });
    }
    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
});

router.get("/satellites/:id/anomalies", async (req, res, next) => {
  try {
    const data = await service.getAnomaliesForSatellite(req.params.id);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

router.post("/anomalies", async (req, res, next) => {
  try {
    const { satelliteId, description } = req.body;
    if (!satelliteId || !description?.trim()) {
      return res.status(400).json({ message: "satelliteId et description sont requis." });
    }
    const created = await service.addAnomalie({ satelliteId, description });
    return res.status(201).json(created);
  } catch (err) {
    return next(err);
  }
});

router.patch("/anomalies/:id/traitee", async (req, res, next) => {
  try {
    const ok = await service.markAnomalieAsTraitee(Number(req.params.id));
    if (!ok) {
      return res.status(409).json({ message: "Anomalie introuvable ou deja traitee." });
    }
    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
