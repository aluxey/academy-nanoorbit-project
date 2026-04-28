package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.*
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.rememberScrollState

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
        viewModel(),
    onSatelliteClick:
        (String)->Unit = {}
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
    val isOfflineMode by
    vm.isOfflineMode.collectAsStateWithLifecycle()


    Column(
        Modifier
            .fillMaxSize()
            .padding(16.dp)
    ){
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(
                onClick = { vm.setOfflineMode(true) },
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isOfflineMode) {
                        MaterialTheme.colorScheme.primary
                    } else {
                        MaterialTheme.colorScheme.secondary
                    }
                )
            ) {
                Text("Offline")
            }

            Button(
                onClick = { vm.setOfflineMode(false) },
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (!isOfflineMode) {
                        MaterialTheme.colorScheme.primary
                    } else {
                        MaterialTheme.colorScheme.secondary
                    }
                )
            ) {
                Text("Online")
            }
        }

        Spacer(Modifier.height(12.dp))

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
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState()),
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

            Spacer(Modifier.height(8.dp))

            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                contentPadding = PaddingValues(bottom = 8.dp)
            ) {

                items(filtered){ sat ->

                    SatelliteCard(
                        satellite = sat,
                        onClick = {
                            onSatelliteClick(
                                sat.idSatellite
                            )
                        }
                    )

                }

            }

        }

    }

}
