package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.MockData

@Composable
fun MapScreen(){

    Column(
        Modifier.padding(16.dp)
    ){

        Text(
            "Carte OpenStreetMap"
        )

        MockData.stations.forEach {

            Card(
                Modifier.padding(8.dp)
            ){

                Column(
                    Modifier.padding(16.dp)
                ){

                    Text(
                        it.nomStation
                    )

                    Text(
                        "${it.latitude}, ${it.longitude}"
                    )

                }

            }

        }

        FloatingActionButton(
            onClick = {

                /*
                future GPS centering
                */
            }
        ){

            Text("GPS")

        }

    }

}