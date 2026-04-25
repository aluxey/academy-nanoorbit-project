package com.nanoorbit.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.Instrument

@Composable
fun InstrumentItem(
    instrument: Instrument,
    etatFonctionnement: String
){

    Row(
        Modifier
            .fillMaxWidth()
            .padding(12.dp)
    ) {

        Column(
            Modifier.weight(1f)
        ) {

            Text(
                instrument.typeInstrument
            )

            Text(
                instrument.modele
            )

            Text(
                "Résolution : ${
                    instrument.resolution ?: "N/A"
                }"
            )
        }

        Text(
            etatFonctionnement
        )
    }
}