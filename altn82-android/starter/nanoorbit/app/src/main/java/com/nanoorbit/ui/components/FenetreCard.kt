package com.nanoorbit.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.FenetreCom

@Composable
fun FenetreCard(
    fenetre: FenetreCom,
    nomStation: String
){

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
    ) {

        Column(
            Modifier.padding(16.dp)
        ) {

            Text(
                "Station : $nomStation"
            )

            Text(
                "Durée : ${fenetre.duree}s"
            )

            Text(
                "Statut : ${fenetre.statut}"
            )

            fenetre.volumeDonnees?.let {

                Text(
                    "Volume : $it MB"
                )

            }

        }
    }
}