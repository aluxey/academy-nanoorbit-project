package com.nanoorbit.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutSatellite

@Composable
fun SatelliteCard(
    satellite: Satellite,
    onClick: () -> Unit
){

    val disabled =
        satellite.statut == StatutSatellite.DESORBITE

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
            .clickable(
                enabled = !disabled
            ){
                onClick()
            },

        colors = CardDefaults.cardColors(
            containerColor =
                if(disabled)
                    Color.LightGray
                else
                    MaterialTheme.colorScheme.surface
        )
    ) {

        Column(
            Modifier.padding(16.dp)
        ) {

            Text(
                satellite.nomSatellite,
                style = MaterialTheme.typography.titleMedium
            )

            Spacer(
                Modifier.height(8.dp)
            )

            StatusBadge(
                satellite.statut
            )

            Text(
                "Format : ${satellite.formatCubesat}"
            )

            Text(
                "Orbite : ${satellite.idOrbite}"
            )

            if(disabled){
                Text(
                    "DÉSORBITÉ"
                )
            }

        }
    }
}