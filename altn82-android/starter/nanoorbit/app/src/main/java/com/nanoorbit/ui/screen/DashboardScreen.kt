package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

import androidx.compose.material3.*

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

import com.nanoorbit.model.MockData
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutSatellite
import com.nanoorbit.model.TypeOrbite

import com.nanoorbit.ui.components.SatelliteCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen() {
    var query by remember {
        mutableStateOf("")
    }

    var isLoading by remember {
        mutableStateOf(true)
    }

    /*
    Simulation chargement
     */
    LaunchedEffect(Unit){
        kotlinx.coroutines.delay(1000)
        isLoading = false
    }

    val satellites = MockData.satellites

    /*
    Recherche par nom ou type orbite
     */
    val filteredSatellites =
        satellites.filter { sat ->

            val orbite =
                MockData.orbites
                    .find {
                        it.idOrbite == sat.idOrbite
                    }

            val typeLabel =
                orbite?.typeOrbite?.name ?: ""

            sat.nomSatellite.contains(
                query,
                ignoreCase = true
            )
                    ||
                    typeLabel.contains(
                        query,
                        ignoreCase = true
                    )
        }

    val operationalCount =
        satellites.count {
            it.statut ==
                    StatutSatellite.OPERATIONNEL
        }

    val displayedCount = filteredSatellites.size

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ){

        Text(
            text = "$operationalCount/${satellites.size} satellites opérationnels",
            style = MaterialTheme.typography.titleMedium
        )

        Spacer(
            Modifier.height(12.dp)
        )

        OutlinedTextField(
            value = query,
            onValueChange = {
                query = it
            },
            modifier = Modifier.fillMaxWidth(),
            label = {
                Text(
                    "Recherche nom ou orbite"
                )
            },
            singleLine = true
        )

        Spacer(
            Modifier.height(12.dp)
        )

        if(isLoading){

            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment =
                    androidx.compose.ui.Alignment.Center
            ){
                Column {

                    CircularProgressIndicator()

                    Spacer(
                        Modifier.height(12.dp)
                    )

                    Text(
                        "Chargement satellites..."
                    )
                }
            }

        }
        else {

            if(filteredSatellites.isEmpty()){

                Box(
                    Modifier.fillMaxSize(),
                    contentAlignment =
                        androidx.compose.ui.Alignment.Center
                ){
                    Text(
                        "Aucun satellite trouvé"
                    )
                }

            }
            else {

                LazyColumn {

                    item {

                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(8.dp)
                        ) {

                            Column(
                                Modifier.padding(16.dp)
                            ) {

                                Text(
                                    "$operationalCount/${satellites.size} satellites opérationnels"
                                )

                                Text(
                                    "$displayedCount résultat(s)"
                                )

                            }

                        }

                    }

                    items(
                        filteredSatellites
                    ){ satellite ->

                        SatelliteCard(
                            satellite = satellite,
                            onClick = {

                                /*
                                Future navigation détail
                                 */
                            }
                        )

                    }

                }

            }

        }

    }

}


@Preview(showBackground = true)
@Composable
fun DashboardPreview(){

    MaterialTheme {
        DashboardScreen()
    }

}