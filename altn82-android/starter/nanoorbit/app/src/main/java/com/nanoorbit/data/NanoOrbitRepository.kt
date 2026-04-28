package com.nanoorbit.data

import com.nanoorbit.model.Anomalie
import com.nanoorbit.model.FenetreCom
import com.nanoorbit.model.FormatCubeSat
import com.nanoorbit.model.MockData
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutFenetre
import com.nanoorbit.model.StatutSatellite
import kotlinx.coroutines.delay
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.OffsetDateTime

class NanoOrbitRepository(
    private val api: NanoOrbitApi = createApi()
) {
    companion object {
        private fun createApi(): NanoOrbitApi {
            return Retrofit.Builder()
                .baseUrl("http://172.24.208.1:3001/api/")
                .addConverterFactory(GsonConverterFactory.create())
                .build()
                .create(NanoOrbitApi::class.java)
        }
    }

    // offline par defaut
    private var offlineMode = true

    private val fenetresStore = MockData.fenetres.toMutableList()
    private val anomaliesStore = MockData.anomalies.toMutableList()

    fun setOfflineMode(enabled: Boolean) {
        offlineMode = enabled
    }

    fun isOfflineMode(): Boolean = offlineMode

    suspend fun getSatellites(): List<Satellite> {
        delay(250)
        if (offlineMode) return MockData.satellites
        return api.getSatellites().map { it.toModel() }
    }

    suspend fun getFenetres(): List<FenetreCom> {
        if (offlineMode) {
            return fenetresStore.sortedBy { it.datetimeDebut }
        }
        return api.getFenetres().map { it.toModel() }.sortedBy { it.datetimeDebut }
    }

    suspend fun addFenetre(
        datetimeDebut: LocalDateTime,
        duree: Int,
        idSatellite: String,
        codeStation: String,
        volumeDonnees: Double? = null
    ): FenetreCom {
        if (offlineMode) {
            val nextId = (fenetresStore.maxOfOrNull { it.idFenetre } ?: 0) + 1
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

        val response = api.addFenetre(
            AddFenetreRequest(
                datetimeDebut = datetimeDebut.toString(),
                duree = duree,
                idSatellite = idSatellite,
                codeStation = codeStation,
                volumeDonnees = volumeDonnees
            )
        )
        if (!response.isSuccessful) {
            throw IllegalStateException("Echec addFenetre: HTTP ${response.code()}")
        }
        val fenetres = api.getFenetres().map { it.toModel() }.sortedBy { it.datetimeDebut }
        return fenetres.lastOrNull()
            ?: throw IllegalStateException("Fenetre ajoutee mais liste vide")
    }

    suspend fun markFenetreAsRealisee(
        idFenetre: Int,
        today: LocalDate = LocalDate.now()
    ): Boolean {
        if (offlineMode) {
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

        return api.markFenetreAsRealisee(idFenetre).isSuccessful
    }

    suspend fun getAnomaliesForSatellite(
        satelliteId: String
    ): List<Anomalie> {
        if (offlineMode) {
            return anomaliesStore
                .filter { it.idSatellite == satelliteId }
                .sortedByDescending { it.dateSignalement }
        }

        return api.getAnomaliesForSatellite(satelliteId)
            .map { it.toModel() }
            .sortedByDescending { it.dateSignalement }
    }

    suspend fun addAnomalie(
        satelliteId: String,
        description: String
    ): Anomalie {
        if (offlineMode) {
            val nextId = (anomaliesStore.maxOfOrNull { it.idAnomalie } ?: 0) + 1
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

        val response = api.addAnomalie(
            AddAnomalieRequest(
                satelliteId = satelliteId,
                description = description.trim()
            )
        )
        if (!response.isSuccessful) {
            throw IllegalStateException("Echec addAnomalie: HTTP ${response.code()}")
        }

        return Anomalie(
            idAnomalie = -1,
            idSatellite = satelliteId,
            dateSignalement = LocalDateTime.now(),
            description = description.trim(),
            statut = "OUVERTE"
        )
    }

    suspend fun markAnomalieAsTraitee(
        idAnomalie: Int
    ): Boolean {
        if (offlineMode) {
            val index = anomaliesStore.indexOfFirst { it.idAnomalie == idAnomalie }
            if (index == -1) return false

            val current = anomaliesStore[index]
            if (current.statut == "TRAITEE") return false

            anomaliesStore[index] = current.copy(statut = "TRAITEE")
            return true
        }

        return api.markAnomalieAsTraitee(idAnomalie).isSuccessful
    }

    private fun SatelliteDto.toModel(): Satellite {
        return Satellite(
            idSatellite = idSatellite,
            nomSatellite = nom,
            statut = when (statut.uppercase()) {
                "EN VEILLE", "EN_VEILLE" -> StatutSatellite.EN_VEILLE
                "DEFAILLANT", "DEFAILLANT(E)" -> StatutSatellite.DEFAILLANT
                "DESORBITE", "DESORBITÉ" -> StatutSatellite.DESORBITE
                else -> StatutSatellite.OPERATIONNEL
            },
            formatCubesat = when (formatCubesat.uppercase()) {
                "1U", "U1" -> FormatCubeSat.U1
                "6U", "U6" -> FormatCubeSat.U6
                "12U", "U12" -> FormatCubeSat.U12
                else -> FormatCubeSat.U3
            },
            idOrbite = idOrbite,
            dateLancement = dateLancement?.take(10)?.let { LocalDate.parse(it) },
            masse = masse
        )
    }

    private fun FenetreDto.toModel(): FenetreCom {
        return FenetreCom(
            idFenetre = idFenetre,
            datetimeDebut = parseDateTime(datetimeDebut),
            duree = duree,
            statut = if (statut.equals("Réalisée", true) || statut.equals("REALISEE", true)) {
                StatutFenetre.REALISEE
            } else {
                StatutFenetre.PLANIFIEE
            },
            idSatellite = idSatellite,
            codeStation = codeStation,
            volumeDonnees = volumeDonnees
        )
    }

    private fun AnomalieDto.toModel(): Anomalie {
        return Anomalie(
            idAnomalie = idAnomalie,
            idSatellite = idSatellite,
            dateSignalement = parseDateTime(dateSignalement),
            description = description ?: "",
            statut = statut
        )
    }

    private fun parseDateTime(raw: String): LocalDateTime {
        return runCatching { OffsetDateTime.parse(raw).toLocalDateTime() }
            .getOrElse { LocalDateTime.parse(raw.replace(" ", "T")) }
    }
}
