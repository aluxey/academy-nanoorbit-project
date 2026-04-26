package com.nanoorbit.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(
    tableName="fenetres_com"
)
data class FenetreEntity(

    @PrimaryKey
    val idFenetre:Int,

    val satelliteId:String,

    val duree:Int,

    val datetimeDebut:String

)