package com.nanoorbit.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(
    entities = [
        SatelliteEntity::class,
        FenetreEntity::class
    ],
    version = 1
)
abstract class NanoOrbitDatabase :
    RoomDatabase(){

    abstract fun dao():
            NanoOrbitDao

}
