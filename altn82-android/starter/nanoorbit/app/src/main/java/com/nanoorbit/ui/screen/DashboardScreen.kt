package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.*

import androidx.compose.material3.*

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel

import com.nanoorbit.model.StatutSatellite
import com.nanoorbit.ui.components.SatelliteCard
import com.nanoorbit.viewmodel.NanoOrbitViewModel

@Composable
fun DashboardScreen(
    vm : NanoOrbitViewModel =
        viewModel()
){

    val satellites by
    vm.satellites.collectAsStateWithLifecycle()

    val filtered by
    vm.filteredSatellites
        .collectAsStateWithLifecycle()

    val loading by
    vm.isLoading.collectAsStateWithLifecycle()

    val error by
    vm.errorMessage.collectAsStateWithLifecycle()

    val query by
    vm.searchQuery.collectAsStateWithLifecycle()

    val activeStatut by
    vm.selectedStatut
        .collectAsStateWithLifecycle()


    Column(
        Modifier.padding(16.dp)
    ){

        OutlinedTextField(
            value = query,
            onValueChange = {
                vm.onSearchQueryChange(it)
            },
            label = {
                Text("Recherche")
            },
            modifier =
                Modifier.fillMaxWidth()
        )

        Spacer(
            Modifier.height(12.dp)
        )


        /*
        Chips filtres statut
         */
        Row(
            horizontalArrangement =
                Arrangement.spacedBy(8.dp)
        ){

            FilterChip(
                selected =
                    activeStatut == null,

                onClick = {
                    vm.onStatutFilterChange(
                        null
                    )
                },

                label = {
                    Text("Tous")
                }
            )

            StatutSatellite.values().forEach {

                FilterChip(
                    selected =
                        activeStatut == it,

                    onClick = {
                        vm.onStatutFilterChange(it)
                    },

                    label = {
                        Text(it.name)
                    }
                )
            }

        }

        Spacer(
            Modifier.height(12.dp)
        )

        if(loading){

            CircularProgressIndicator()

        }

        else if(error != null){

            Column {

                Text(error!!)

                Button(
                    onClick = {
                        vm.refreshSatellites()
                    }
                ){
                    Text("Réessayer")
                }

            }

        }

        else {

            val opCount =
                satellites.count {
                    it.statut ==
                            StatutSatellite.OPERATIONNEL
                }

            Card(
                modifier =
                    Modifier.fillMaxWidth()
            ){

                Column(
                    Modifier.padding(16.dp)
                ){

                    Text(
                        "$opCount/${satellites.size} satellites opérationnels"
                    )

                    Text(
                        "${filtered.size} résultat(s)"
                    )

                }

            }

            Spacer(
                Modifier.height(12.dp)
            )

            LazyColumn {

                items(filtered){ sat ->

                    SatelliteCard(
                        satellite = sat,
                        onClick = {}
                    )

                }

            }

        }

    }

}