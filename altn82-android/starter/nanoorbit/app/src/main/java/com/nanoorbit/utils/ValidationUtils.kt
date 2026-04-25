package com.nanoorbit.utils

fun validateFenetreDuration(
    duree: Int
): String? {

    return when {

        duree < 1 ->
            "Durée minimale 1 seconde"

        duree > 900 ->
            "Durée max 900 secondes (RG-F04)"

        else -> null
    }
}