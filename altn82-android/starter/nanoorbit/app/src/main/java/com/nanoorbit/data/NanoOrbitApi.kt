package com.nanoorbit.data

import com.nanoorbit.model.FenetreCom
import com.nanoorbit.model.Instrument
import com.nanoorbit.model.Satellite
import retrofit2.http.GET
import retrofit2.http.Path

interface NanoOrbitApi {

    @GET("satellites")
    suspend fun getSatellites(): List<Satellite>

    @GET("satellites/{id}/instruments")
    suspend fun getSatelliteInstruments(
        @Path("id") satelliteId: String
    ): List<Instrument>

    @GET("fenetres")
    suspend fun getFenetres(): List<FenetreCom>
}