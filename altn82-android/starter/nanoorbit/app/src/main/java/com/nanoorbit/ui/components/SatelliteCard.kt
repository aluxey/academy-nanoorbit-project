package com.nanoorbit.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
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
            .padding(horizontal = 8.dp, vertical = 4.dp)
            .clickable(
                enabled = !disabled
            ){
                onClick()
            },
        shape = RoundedCornerShape(10.dp),
        border = BorderStroke(
            1.dp,
            if (disabled) {
                MaterialTheme.colorScheme.outline.copy(alpha = 0.45f)
            } else {
                MaterialTheme.colorScheme.outlineVariant
            }
        ),
        colors = CardDefaults.cardColors(
            containerColor =
                if(disabled)
                    Color.LightGray
                else
                    MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = satellite.nomSatellite,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold
            )

            StatusBadge(
                satellite.statut
            )

            LabelValueRow(
                label = "ID",
                value = satellite.idSatellite
            )

            LabelValueRow(
                label = "Format",
                value = satellite.formatCubesat.name
            )

            LabelValueRow(
                label = "Orbite",
                value = satellite.idOrbite.toString()
            )

            if (disabled) {
                Text(
                    text = "Satellite desorbite",
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}

@Composable
private fun LabelValueRow(
    label: String,
    value: String
) {
    Row {
        Text(
            text = "$label:",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.width(6.dp))
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium
        )
    }
}
