package com.nanoorbit.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(
    tableName = "satellites"
)
data class SatelliteEntity(

    @PrimaryKey
    val idSatellite:String,

    val nomSatellite:String,

    val statut:String,

    val updatedAt:Long

)