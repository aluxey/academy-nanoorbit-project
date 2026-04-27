package com.nanoorbit.data

import com.nanoorbit.model.Anomalie
import com.nanoorbit.model.FenetreCom
import com.nanoorbit.model.MockData
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutFenetre
import kotlinx.coroutines.delay
import java.time.LocalDate
import java.time.LocalDateTime

class NanoOrbitRepository(
    private val api: NanoOrbitApi? = null
) {
    private val fenetresStore =
        MockData.fenetres.toMutableList()
    private val anomaliesStore =
        MockData.anomalies.toMutableList()

    suspend fun getSatellites(): List<Satellite> {
        delay(250)
        return try {
            api?.getSatellites() ?: MockData.satellites
        } catch (_: Exception) {
            MockData.satellites
        }
    }

    suspend fun getFenetres(): List<FenetreCom> {
        return fenetresStore.sortedBy { it.datetimeDebut }
    }

    suspend fun addFenetre(
        datetimeDebut: LocalDateTime,
        duree: Int,
        idSatellite: String,
        codeStation: String,
        volumeDonnees: Double? = null
    ): FenetreCom {
        val nextId =
            (fenetresStore.maxOfOrNull { it.idFenetre } ?: 0) + 1

        val fenetre = FenetreCom(
            idFenetre = nextId,
            datetimeDebut = datetimeDebut,
            duree = duree,
            statut = StatutFenetre.PLANIFIEE,
            idSatellite = idSatellite,
            codeStation = codeStation,
            volumeDonnees = volumeDonnees
        )
        fenetresStore.add(fenetre)
        return fenetre
    }

    suspend fun markFenetreAsRealisee(
        idFenetre: Int,
        today: LocalDate = LocalDate.now()
    ): Boolean {
        val index = fenetresStore.indexOfFirst { it.idFenetre == idFenetre }
        if (index == -1) return false

        val current = fenetresStore[index]
        val canMark =
            current.statut != StatutFenetre.REALISEE &&
                current.datetimeDebut.toLocalDate().isBefore(today)
        if (!canMark) return false

        fenetresStore[index] = current.copy(statut = StatutFenetre.REALISEE)
        return true
    }

    suspend fun getAnomaliesForSatellite(
        satelliteId: String
    ): List<Anomalie> {
        return anomaliesStore
            .filter { it.idSatellite == satelliteId }
            .sortedByDescending { it.dateSignalement }
    }

    suspend fun addAnomalie(
        satelliteId: String,
        description: String
    ): Anomalie {
        val nextId =
            (anomaliesStore.maxOfOrNull { it.idAnomalie } ?: 0) + 1

        val anomaly = Anomalie(
            idAnomalie = nextId,
            idSatellite = satelliteId,
            dateSignalement = LocalDateTime.now(),
            description = description.trim(),
            statut = "OUVERTE"
        )
        anomaliesStore.add(anomaly)
        return anomaly
    }

    suspend fun markAnomalieAsTraitee(
        idAnomalie: Int
    ): Boolean {
        val index = anomaliesStore.indexOfFirst { it.idAnomalie == idAnomalie }
        if (index == -1) return false

        val current = anomaliesStore[index]
        if (current.statut == "TRAITEE") return false

        anomaliesStore[index] = current.copy(statut = "TRAITEE")
        return true
    }
}
