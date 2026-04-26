package com.nanoorbit.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.OnConflictStrategy

@Dao
interface NanoOrbitDao {

    @Query(
        "SELECT * FROM satellites"
    )
    suspend fun getSatellites():
            List<SatelliteEntity>

    @Insert(
        onConflict=
            OnConflictStrategy.REPLACE
    )
    suspend fun insertSatellites(
        sats:
        List<SatelliteEntity>
    )

}