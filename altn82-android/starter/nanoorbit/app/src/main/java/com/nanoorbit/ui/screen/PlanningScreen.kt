package com.nanoorbit.ui.screen

import android.app.DatePickerDialog
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.nanoorbit.model.MockData
import com.nanoorbit.model.StatutFenetre
import com.nanoorbit.ui.components.FenetreCard
import com.nanoorbit.viewmodel.NanoOrbitViewModel
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import java.util.Calendar

@Composable
fun PlanningScreen(
    vm: NanoOrbitViewModel = viewModel()
){
    val context = LocalContext.current

    var stationSelected by remember {
        mutableStateOf<String?>(null)
    }

    var selectedSatelliteId by remember { mutableStateOf<String?>(null) }
    var selectedStationCode by remember { mutableStateOf<String?>(null) }
    var satelliteMenuExpanded by remember { mutableStateOf(false) }
    var stationMenuExpanded by remember { mutableStateOf(false) }
    var dureeInput by remember { mutableStateOf("") }
    var selectedDate by remember { mutableStateOf<LocalDate?>(null) }
    var timeInput by remember { mutableStateOf("12:00") }
    var formError by remember { mutableStateOf<String?>(null) }

    val fenetres by vm.fenetres.collectAsStateWithLifecycle()
    val planningMessage by vm.planningMessage.collectAsStateWithLifecycle()
    val satellites by vm.satellites.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        vm.loadFenetres()
    }

    val filtered =
        fenetres.filter {
            stationSelected == null || it.codeStation == stationSelected
        }

    val totalDuree = filtered.sumOf { it.duree }
    val dateLabel = selectedDate?.toString() ?: "Aucune date selectionnee"
    val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")

    LazyColumn(
        modifier = Modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                FilterChip(
                    selected = stationSelected == null,
                    onClick = { stationSelected = null },
                    label = { Text("Toutes") }
                )

                MockData.stations.forEach { station ->
                    FilterChip(
                        selected = stationSelected == station.codeStation,
                        onClick = { stationSelected = station.codeStation },
                        label = { Text(station.nomStation) }
                    )
                }
            }
        }

        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Ajouter une fenetre",
                        style = MaterialTheme.typography.titleSmall
                    )

                    Column {
                        Button(
                            onClick = { satelliteMenuExpanded = true },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                if (selectedSatelliteId == null) {
                                    "Choisir un satellite"
                                } else {
                                    "Satellite: $selectedSatelliteId"
                                }
                            )
                        }
                        DropdownMenu(
                            expanded = satelliteMenuExpanded,
                            onDismissRequest = { satelliteMenuExpanded = false }
                        ) {
                            satellites.forEach { sat ->
                                DropdownMenuItem(
                                    text = { Text("${sat.idSatellite} - ${sat.nomSatellite}") },
                                    onClick = {
                                        selectedSatelliteId = sat.idSatellite
                                        satelliteMenuExpanded = false
                                    }
                                )
                            }
                        }
                    }

                    Column {
                        Button(
                            onClick = { stationMenuExpanded = true },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                if (selectedStationCode == null) {
                                    "Choisir une station"
                                } else {
                                    "Station: $selectedStationCode"
                                }
                            )
                        }
                        DropdownMenu(
                            expanded = stationMenuExpanded,
                            onDismissRequest = { stationMenuExpanded = false }
                        ) {
                            MockData.stations.forEach { station ->
                                DropdownMenuItem(
                                    text = { Text("${station.codeStation} - ${station.nomStation}") },
                                    onClick = {
                                        selectedStationCode = station.codeStation
                                        stationMenuExpanded = false
                                    }
                                )
                            }
                        }
                    }

                    OutlinedTextField(
                        value = dureeInput,
                        onValueChange = { dureeInput = it },
                        label = { Text("Duree (secondes)") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )

                    Text("Date debut: $dateLabel")

                    Button(
                        onClick = {
                            val now = Calendar.getInstance()
                            DatePickerDialog(
                                context,
                                { _, year, month, dayOfMonth ->
                                    selectedDate = LocalDate.of(
                                        year,
                                        month + 1,
                                        dayOfMonth
                                    )
                                },
                                now.get(Calendar.YEAR),
                                now.get(Calendar.MONTH),
                                now.get(Calendar.DAY_OF_MONTH)
                            ).show()
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Choisir la date")
                    }

                    OutlinedTextField(
                        value = timeInput,
                        onValueChange = { timeInput = it },
                        label = { Text("Heure (HH:mm)") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )

                    formError?.let {
                        Text(
                            text = it,
                            color = MaterialTheme.colorScheme.error
                        )
                    }

                    Button(
                        onClick = {
                            formError = null

                            val parsedDuree = dureeInput.trim().toIntOrNull()
                            val parsedTime = runCatching {
                                LocalTime.parse(timeInput.trim(), timeFormatter)
                            }.getOrNull()

                            if (selectedDate == null) {
                                formError = "Choisis une date de debut."
                                return@Button
                            }
                            if (parsedTime == null) {
                                formError = "Heure invalide. Format attendu: HH:mm"
                                return@Button
                            }
                            if (parsedDuree == null || parsedDuree <= 0) {
                                formError = "Duree invalide."
                                return@Button
                            }
                            if (selectedSatelliteId == null || selectedStationCode == null) {
                                formError = "Le satellite et la station doivent etre selectionnes."
                                return@Button
                            }

                            vm.addFenetrePlanning(
                                datetimeDebut = LocalDateTime.of(selectedDate, parsedTime),
                                duree = parsedDuree,
                                idSatellite = selectedSatelliteId!!,
                                codeStation = selectedStationCode!!
                            )

                            selectedSatelliteId = null
                            selectedStationCode = null
                            dureeInput = ""
                            selectedDate = null
                            timeInput = "12:00"
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Ajouter la fenetre")
                    }
                }
            }
        }

        item {
            Text("Contact total : $totalDuree s")
        }

        planningMessage?.let { message ->
            item {
                Text(
                    text = message,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }

        if (filtered.isEmpty()) {
            item {
                Text("Aucune fenetre a afficher.")
            }
        } else {
            items(filtered) { f ->
                val station =
                    MockData.stations.find { it.codeStation == f.codeStation }

                val canMarkRealisee =
                    f.statut != StatutFenetre.REALISEE &&
                        f.datetimeDebut.toLocalDate().isBefore(LocalDate.now())

                FenetreCard(
                    fenetre = f,
                    nomStation = station?.nomStation ?: f.codeStation,
                    onValidateRealisee = {
                        vm.markFenetreAsRealisee(f.idFenetre)
                    },
                    canValidateRealisee = canMarkRealisee
                )
            }
        }
    }
}
