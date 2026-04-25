package com.nanoorbit.model

import java.time.LocalDate
import java.time.LocalDateTime

/*
Correspondance Oracle SATELLITE.statut
CHECK (
Operationnel,
En veille,
Defaillant,
Desorbite
)
*/

enum class StatutSatellite {
    OPERATIONNEL,
    EN_VEILLE,
    DEFAILLANT,
    DESORBITE
}

enum class FormatCubeSat {
    U1, U3, U6, U12
}

enum class TypeOrbite {
    SSO,
    LEO
}

enum class StatutFenetre {
    PLANIFIEE,
    REALISEE
}

/*
TABLE ORBITE
*/
data class Orbite(
    val idOrbite: Int,
    val typeOrbite: TypeOrbite,
    val altitude: Double,
    val inclinaison: Double,
    val zoneCouverture: String? = null
)

/*
TABLE SATELLITE
dateLancement et masse nullable
*/
data class Satellite(
    val idSatellite: String,
    val nomSatellite: String,
    val statut: StatutSatellite,
    val formatCubesat: FormatCubeSat,
    val idOrbite: Int,
    val dateLancement: LocalDate? = null,
    val masse: Double? = null
)

/*
TABLE INSTRUMENT
*/
data class Instrument(
    val refInstrument: String,
    val typeInstrument: String,
    val modele: String,
    val resolution: Double? = null,
    val consommation: Double? = null
)

/*
TABLE FENETRE_COM
*/
data class FenetreCom(
    val idFenetre: Int,
    val datetimeDebut: LocalDateTime,
    val duree: Int,
    val statut: StatutFenetre,
    val idSatellite: String,
    val codeStation: String,
    val volumeDonnees: Double? = null
)

/*
TABLE STATION_SOL
*/
data class StationSol(
    val codeStation: String,
    val nomStation: String,
    val latitude: Double,
    val longitude: Double,
    val diametreAntenne: Double? = null,
    val debitMax: Double? = null
)

/*
TABLE MISSION
*/
data class Mission(
    val idMission: String,
    val nomMission: String,
    val objectif: String,
    val dateDebut: LocalDate,
    val statutMission: String,
    val dateFin: LocalDate? = null,
    val zoneGeoCible: String? = null
)