package com.nanoorbit.data

import com.nanoorbit.model.MockData
import com.nanoorbit.model.Satellite
import kotlinx.coroutines.delay

class NanoOrbitRepository(
    private val api: NanoOrbitApi? = null
) {

    /*
    Lien ALTN83 Q3 :
    stratégie simplifiée cache-first.
    Si serveur indisponible :
    retour des données mock/cache.
    */

    suspend fun getSatellites(): List<Satellite> {

        delay(500)

        return try {

            api?.getSatellites()
                ?: MockData.satellites

        } catch(e: Exception){

            /*
            fallback hors-ligne
             */
            MockData.satellites
        }
    }

}