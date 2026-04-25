package com.nanoorbit.ui.components

import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.StatutSatellite

@Composable
fun StatusBadge(
    statut: StatutSatellite,
    modifier: Modifier = Modifier
) {

    val color = when(statut){
        StatutSatellite.OPERATIONNEL -> Color.Green
        StatutSatellite.EN_VEILLE -> Color(0xFFFF9800)
        StatutSatellite.DEFAILLANT -> Color.Red
        StatutSatellite.DESORBITE -> Color.Gray
    }

    Surface(
        color = color,
        shape = RoundedCornerShape(20.dp),
        modifier = modifier
    ) {
        Text(
            text = statut.name,
            modifier = Modifier.padding(
                horizontal = 12.dp,
                vertical = 6.dp
            )
        )
    }
}

@Preview
@Composable
fun BadgePreview(){
    StatusBadge(StatutSatellite.OPERATIONNEL)
}