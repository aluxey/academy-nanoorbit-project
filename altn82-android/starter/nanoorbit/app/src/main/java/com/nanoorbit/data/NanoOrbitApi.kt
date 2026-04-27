package com.nanoorbit.data

import com.nanoorbit.model.Instrument
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.PATCH
import retrofit2.http.Path

interface NanoOrbitApi {

    @GET("satellites")
    suspend fun getSatellites(): List<SatelliteDto>

    @GET("satellites/{id}/instruments")
    suspend fun getSatelliteInstruments(
        @Path("id") satelliteId: String
    ): List<Instrument>

    @GET("fenetres")
    suspend fun getFenetres(): List<FenetreDto>

    @POST("fenetres")
    suspend fun addFenetre(
        @Body request: CreateFenetreRequest
    ): FenetreDto

    @PATCH("fenetres/{id}/realisee")
    suspend fun markFenetreAsRealisee(
        @Path("id") idFenetre: Int
    )

    @GET("satellites/{id}/anomalies")
    suspend fun getAnomaliesForSatellite(
        @Path("id") satelliteId: String
    ): List<AnomalieDto>

    @POST("satellites/{id}/anomalies")
    suspend fun addAnomalie(
        @Path("id") satelliteId: String,
        @Body request: CreateAnomalieRequest
    ): AnomalieDto

    @PATCH("anomalies/{id}/traitee")
    suspend fun markAnomalieAsTraitee(
        @Path("id") idAnomalie: Int
    )
}
