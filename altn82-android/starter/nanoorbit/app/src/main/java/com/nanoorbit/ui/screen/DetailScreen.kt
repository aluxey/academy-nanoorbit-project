package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.nanoorbit.model.MockData
import com.nanoorbit.ui.components.InstrumentItem
import com.nanoorbit.ui.components.StatusBadge
import com.nanoorbit.viewmodel.NanoOrbitViewModel
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DetailScreen(
    satelliteId: String,
    onBack:()->Unit,
    vm: NanoOrbitViewModel = viewModel()
){

    val sat =
        MockData.satellites.find{
            it.idSatellite == satelliteId
        }

    if(sat == null){
        Text("Satellite introuvable")
        return
    }

    var anomalyText by remember {
        mutableStateOf("")
    }

    var showDialog by remember {
        mutableStateOf(false)
    }

    val anomalies by vm.anomalies.collectAsStateWithLifecycle()
    val dtFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")

    LaunchedEffect(satelliteId) {
        vm.loadAnomaliesForSatellite(satelliteId)
    }

    Scaffold(

        topBar = {

            TopAppBar(

                title = {
                    Text(
                        sat.nomSatellite
                    )
                },

                navigationIcon = {

                    IconButton(
                        onClick = onBack
                    ){
                        Text("<")
                    }

                }

            )

        }

    ){ padding ->

        LazyColumn(
            modifier =
                Modifier
                    .padding(padding)
                    .padding(16.dp)
        ){

            item {

                StatusBadge(
                    sat.statut
                )

                Text(
                    "Format ${sat.formatCubesat}"
                )

                Text(
                    "Orbite ${sat.idOrbite}"
                )

                Text(
                    "Masse ${sat.masse ?: "N/A"}"
                )

            }

            item {

                Spacer(
                    Modifier.height(16.dp)
                )

                Text(
                    "Instruments"
                )

                MockData.instruments.forEach {

                    InstrumentItem(
                        instrument = it,
                        etatFonctionnement =
                            "Nominal"
                    )

                }

            }

            item {
                Spacer(Modifier.height(16.dp))

                Button(
                    onClick = {
                        showDialog = true
                    }
                ){
                    Text("Signaler anomalie")
                }
            }

            item {
                Spacer(Modifier.height(16.dp))
                Text("Anomalies")
            }

            if (anomalies.isEmpty()) {
                item {
                    Text("Aucune anomalie signalee.")
                }
            } else {
                items(anomalies) { anomaly ->
                    val isTraitee = anomaly.statut == "TRAITEE"
                    Card(
                        modifier = Modifier
                            .padding(top = 8.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = if (isTraitee) {
                                Color(0xFFE8F5E9)
                            } else {
                                Color(0xFFFFEBEE)
                            }
                        )
                    ) {
                        androidx.compose.foundation.layout.Column(
                            modifier = Modifier.padding(12.dp)
                        ) {
                            Text("Statut: ${anomaly.statut}")
                            Text("Date: ${anomaly.dateSignalement.format(dtFormat)}")
                            Text("Description: ${anomaly.description}")
                            if (!isTraitee) {
                                Spacer(Modifier.height(8.dp))
                                Button(
                                    onClick = {
                                        vm.markAnomalyAsTraitee(
                                            satelliteId = satelliteId,
                                            anomalyId = anomaly.idAnomalie
                                        )
                                    }
                                ) {
                                    Text("Definir comme traitee")
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    if(showDialog){

        AlertDialog(

            onDismissRequest = {
                showDialog = false
            },

            title = {
                Text("Anomalie")
            },

            text = {

                OutlinedTextField(
                    value = anomalyText,
                    onValueChange = {
                        anomalyText = it
                    },
                    label = {
                        Text("Description")
                    }
                )

            },

            confirmButton = {

                Button(
                    onClick = {
                        vm.addAnomalyToSatellite(
                            satelliteId = satelliteId,
                            description = anomalyText
                        )
                        anomalyText = ""
                        showDialog = false
                    }
                ){
                    Text("Envoyer")
                }

            }

        )
    }

}
