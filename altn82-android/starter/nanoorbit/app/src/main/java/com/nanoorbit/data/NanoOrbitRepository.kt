package com.nanoorbit.data

import com.nanoorbit.model.Anomalie
import com.nanoorbit.model.FenetreCom
import com.nanoorbit.model.FormatCubeSat
import com.nanoorbit.model.MockData
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutFenetre
import com.nanoorbit.model.StatutSatellite
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import java.time.LocalDate
import java.time.LocalDateTime

class NanoOrbitRepository(
    private val api: NanoOrbitApi = ApiProvider.api
) {
    companion object {
        private val _dataMode =
            MutableStateFlow(DataMode.OFFLINE)
    }

    private val fenetresStore =
        MockData.fenetres.toMutableList()
    private val anomaliesStore =
        MockData.anomalies.toMutableList()

    fun observeDataMode(): StateFlow<DataMode> = _dataMode

    fun setDataMode(mode: DataMode) {
        _dataMode.value = mode
    }

    private fun isOnlineMode(): Boolean {
        return _dataMode.value == DataMode.ONLINE
    }

    suspend fun getSatellites(): List<Satellite> {
        delay(250)
        return if (isOnlineMode()) {
            api.getSatellites().map { it.toModel() }
        } else {
            MockData.satellites
        }
    }

    suspend fun getFenetres(): List<FenetreCom> {
        return if (isOnlineMode()) {
            api.getFenetres()
                .map { it.toModel() }
                .sortedBy { it.datetimeDebut }
        } else {
            fenetresStore.sortedBy { it.datetimeDebut }
        }
    }

    suspend fun addFenetre(
        datetimeDebut: LocalDateTime,
        duree: Int,
        idSatellite: String,
        codeStation: String,
        volumeDonnees: Double? = null
    ): FenetreCom {
        return if (isOnlineMode()) {
            api.addFenetre(
                CreateFenetreRequest(
                    datetimeDebut = datetimeDebut.toString(),
                    duree = duree,
                    idSatellite = idSatellite,
                    codeStation = codeStation,
                    volumeDonnees = volumeDonnees
                )
            ).toModel()
        } else {
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
            fenetre
        }
    }

    suspend fun markFenetreAsRealisee(
        idFenetre: Int,
        today: LocalDate = LocalDate.now()
    ): Boolean {
        if (isOnlineMode()) {
            val fenetre = getFenetres().find { it.idFenetre == idFenetre }
                ?: return false
            val canMark =
                fenetre.statut != StatutFenetre.REALISEE &&
                    fenetre.datetimeDebut.toLocalDate().isBefore(today)
            if (!canMark) return false

            api.markFenetreAsRealisee(idFenetre)
            return true
        }

        val index =
            fenetresStore.indexOfFirst { it.idFenetre == idFenetre }
        if (index == -1) return false

        val current = fenetresStore[index]
        val canMark = current.datetimeDebut.toLocalDate().isBefore(today)
        if (!canMark) return false

        fenetresStore[index] =
            current.copy(statut = StatutFenetre.REALISEE)
        return true
    }

    suspend fun getAnomaliesForSatellite(
        satelliteId: String
    ): List<Anomalie> {
        return if (isOnlineMode()) {
            api.getAnomaliesForSatellite(satelliteId)
                .map { it.toModel() }
                .sortedByDescending { it.dateSignalement }
        } else {
            anomaliesStore
                .filter { it.idSatellite == satelliteId }
                .sortedByDescending { it.dateSignalement }
        }
    }

    suspend fun addAnomalie(
        satelliteId: String,
        description: String
    ): Anomalie {
        return if (isOnlineMode()) {
            api.addAnomalie(
                satelliteId = satelliteId,
                request = CreateAnomalieRequest(
                    description = description.trim()
                )
            ).toModel()
        } else {
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
            anomaly
        }
    }

    suspend fun markAnomalieAsTraitee(
        idAnomalie: Int
    ): Boolean {
        return if (isOnlineMode()) {
            api.markAnomalieAsTraitee(idAnomalie)
            true
        } else {
            val index =
                anomaliesStore.indexOfFirst { it.idAnomalie == idAnomalie }
            if (index == -1) return false

            val current = anomaliesStore[index]
            if (current.statut == "TRAITEE") return false

            anomaliesStore[index] =
                current.copy(statut = "TRAITEE")
            true
        }
    }
}

private fun SatelliteDto.toModel(): Satellite {
    return Satellite(
        idSatellite = idSatellite,
        nomSatellite = nomSatellite,
        statut = StatutSatellite.valueOf(statut),
        formatCubesat = FormatCubeSat.valueOf(formatCubesat),
        idOrbite = idOrbite,
        dateLancement = dateLancement?.let { LocalDate.parse(it) },
        masse = masse
    )
}

private fun FenetreDto.toModel(): FenetreCom {
    return FenetreCom(
        idFenetre = idFenetre,
        datetimeDebut = LocalDateTime.parse(datetimeDebut),
        duree = duree,
        statut = StatutFenetre.valueOf(statut),
        idSatellite = idSatellite,
        codeStation = codeStation,
        volumeDonnees = volumeDonnees
    )
}

private fun AnomalieDto.toModel(): Anomalie {
    return Anomalie(
        idAnomalie = idAnomalie,
        idSatellite = idSatellite,
        dateSignalement = LocalDateTime.parse(dateSignalement),
        description = description,
        statut = statut
    )
}
