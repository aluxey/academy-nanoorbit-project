package com.nanoorbit.navigation

object Routes {

    const val DASHBOARD = "dashboard"
    const val PLANNING = "planning"
    const val MAP = "map"

    const val DETAIL = "detail/{satelliteId}"

    fun detailRoute(
        satelliteId: String
    ) = "detail/$satelliteId"

}