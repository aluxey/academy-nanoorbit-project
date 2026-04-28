package com.nanoorbit.data

import com.google.gson.annotations.SerializedName
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.PATCH
import retrofit2.http.POST
import retrofit2.http.Path

interface NanoOrbitApi {

    @GET("satellites")
    suspend fun getSatellites(): List<SatelliteDto>

    @GET("fenetres")
    suspend fun getFenetres(): List<FenetreDto>

    @POST("fenetres")
    suspend fun addFenetre(
        @Body request: AddFenetreRequest
    ): Response<Unit>

    @PATCH("fenetres/{id}/realisee")
    suspend fun markFenetreAsRealisee(
        @Path("id") idFenetre: Int
    ): Response<Unit>

    @GET("satellites/{id}/anomalies")
    suspend fun getAnomaliesForSatellite(
        @Path("id") satelliteId: String
    ): List<AnomalieDto>

    @POST("anomalies")
    suspend fun addAnomalie(
        @Body request: AddAnomalieRequest
    ): Response<Unit>

    @PATCH("anomalies/{id}/traitee")
    suspend fun markAnomalieAsTraitee(
        @Path("id") idAnomalie: Int
    ): Response<Unit>
}

data class SatelliteDto(
    @SerializedName("ID_SATELLITE")
    val idSatellite: String,
    @SerializedName("NOM")
    val nom: String,
    @SerializedName("STATUT")
    val statut: String,
    @SerializedName("FORMAT_CUBESAT")
    val formatCubesat: String,
    @SerializedName("ID_ORBITE")
    val idOrbite: Int,
    @SerializedName("DATE_LANCEMENT")
    val dateLancement: String? = null,
    @SerializedName("MASSE")
    val masse: Double? = null
)

data class FenetreDto(
    @SerializedName("ID_FENETRE")
    val idFenetre: Int,
    @SerializedName("DATETIME_DEBUT")
    val datetimeDebut: String,
    @SerializedName("DUREE")
    val duree: Int,
    @SerializedName("STATUT")
    val statut: String,
    @SerializedName("ID_SATELLITE")
    val idSatellite: String,
    @SerializedName("CODE_STATION")
    val codeStation: String,
    @SerializedName("VOLUME_DONNEES")
    val volumeDonnees: Double? = null
)

data class AnomalieDto(
    @SerializedName("ID_ANOMALIE")
    val idAnomalie: Int,
    @SerializedName("ID_SATELLITE")
    val idSatellite: String,
    @SerializedName("DATE_SIGNALEMENT")
    val dateSignalement: String,
    @SerializedName("DESCRIPTION")
    val description: String? = null,
    @SerializedName("STATUT")
    val statut: String
)

data class AddFenetreRequest(
    val datetimeDebut: String,
    val duree: Int,
    val idSatellite: String,
    val codeStation: String,
    val volumeDonnees: Double? = null
)

data class AddAnomalieRequest(
    val satelliteId: String,
    val description: String
)
