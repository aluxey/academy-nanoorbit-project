package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.MockData
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import com.nanoorbit.ui.components.FenetreCard

@Composable
fun PlanningScreen(){

    var stationSelected by remember {
        mutableStateOf<String?>(null)
    }

    val fenetres =
        MockData.fenetres
            .sortedBy {
                it.datetimeDebut
            }
            .filter {

                stationSelected == null ||
                        it.codeStation ==
                        stationSelected
            }

    Column(
        Modifier.padding(16.dp)
    ){

        Row {

            FilterChip(
                selected =
                    stationSelected == null,

                onClick = {
                    stationSelected = null
                },

                label = {
                    Text("Toutes")
                }
            )

            MockData.stations.forEach {

                FilterChip(
                    selected =
                        stationSelected ==
                                it.codeStation,

                    onClick = {
                        stationSelected =
                            it.codeStation
                    },

                    label = {
                        Text(it.nomStation)
                    }
                )

            }

        }

        Spacer(
            Modifier.height(12.dp)
        )

        val totalDuree =
            fenetres.sumOf {
                it.duree
            }

        Text(
            "Contact total : $totalDuree s"
        )

        LazyColumn {

            items(fenetres){ f ->

                val station =
                    MockData.stations.find{
                        it.codeStation ==
                                f.codeStation
                    }

                FenetreCard(
                    f,
                    station?.nomStation ?: ""
                )

            }

        }

    }

}