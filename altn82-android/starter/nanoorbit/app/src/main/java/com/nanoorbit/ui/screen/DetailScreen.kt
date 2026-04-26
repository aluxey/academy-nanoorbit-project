package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.MockData
import com.nanoorbit.ui.components.InstrumentItem
import com.nanoorbit.ui.components.StatusBadge
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DetailScreen(
    satelliteId: String,
    onBack:()->Unit
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

                Spacer(
                    Modifier.height(16.dp)
                )

                Button(
                    onClick = {
                        showDialog = true
                    }
                ){

                    Text(
                        "Signaler anomalie"
                    )

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
                    }
                )

            },

            confirmButton = {

                Button(
                    onClick = {
                        showDialog = false
                    }
                ){
                    Text("Envoyer")
                }

            }

        )
    }

}