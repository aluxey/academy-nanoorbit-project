package com.nanoorbit.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope

import com.nanoorbit.data.NanoOrbitRepository
import com.nanoorbit.model.Anomalie
import com.nanoorbit.model.FenetreCom
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutSatellite

import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.LocalDateTime

class NanoOrbitViewModel(
    private val repository: NanoOrbitRepository =
        NanoOrbitRepository()
) : ViewModel() {

    private val _satellites =
        MutableStateFlow<List<Satellite>>(
            emptyList()
        )

    val satellites :
            StateFlow<List<Satellite>>
            = _satellites

    private val _isLoading =
        MutableStateFlow(false)

    val isLoading :
            StateFlow<Boolean>
            = _isLoading

    private val _errorMessage =
        MutableStateFlow<String?>(null)

    val errorMessage :
            StateFlow<String?>
            = _errorMessage

    private val _searchQuery =
        MutableStateFlow("")

    val searchQuery :
            StateFlow<String>
            = _searchQuery

    private val _selectedStatut =
        MutableStateFlow<StatutSatellite?>(
            null
        )

    val selectedStatut :
            StateFlow<StatutSatellite?>
            = _selectedStatut

    private val _fenetres =
        MutableStateFlow<List<FenetreCom>>(emptyList())

    val fenetres: StateFlow<List<FenetreCom>> =
        _fenetres

    private val _planningMessage =
        MutableStateFlow<String?>(null)

    val planningMessage: StateFlow<String?> =
        _planningMessage

    private val _anomalies =
        MutableStateFlow<List<Anomalie>>(emptyList())

    val anomalies: StateFlow<List<Anomalie>> =
        _anomalies

    private val _isOfflineMode =
        MutableStateFlow(repository.isOfflineMode())

    val isOfflineMode: StateFlow<Boolean> =
        _isOfflineMode


    /*
    Liste dérivée demandée par le sujet
     */
    val filteredSatellites =
        combine(
            satellites,
            searchQuery,
            selectedStatut
        ){ sats, query, statut ->

            sats.filter { sat ->

                val matchesQuery =
                    query.isBlank()
                            ||
                            sat.nomSatellite.contains(
                                query,
                                true
                            )

                val matchesStatut =
                    statut == null
                            ||
                            sat.statut == statut

                matchesQuery &&
                        matchesStatut
            }

        }.stateIn(
            viewModelScope,
            SharingStarted.WhileSubscribed(5000),
            emptyList()
        )



    init {
        loadSatellites()
        loadFenetres()
    }


    fun loadSatellites(){

        viewModelScope.launch {

            _isLoading.value = true
            _errorMessage.value = null

            try{

                _satellites.value =
                    repository.getSatellites()

            } catch(e: Exception){

                _errorMessage.value =
                    "Erreur réseau satellites"

            } finally {

                _isLoading.value = false

            }

        }

    }


    fun refreshSatellites(){

        loadSatellites()
        loadFenetres()

    }

    fun setOfflineMode(enabled: Boolean) {
        repository.setOfflineMode(enabled)
        _isOfflineMode.value = enabled
        refreshSatellites()
    }


    fun onSearchQueryChange(
        query: String
    ){
        _searchQuery.value = query
    }


    fun onStatutFilterChange(
        statut: StatutSatellite?
    ){
        _selectedStatut.value = statut
    }

    fun clearPlanningMessage() {
        _planningMessage.value = null
    }

    fun loadFenetres() {
        viewModelScope.launch {
            try {
                _fenetres.value = repository.getFenetres()
            } catch (_: Exception) {
                _planningMessage.value = "Erreur reseau (fenetres)."
            }
        }
    }

    fun addFenetrePlanning(
        datetimeDebut: LocalDateTime,
        duree: Int,
        idSatellite: String,
        codeStation: String
    ) {
        viewModelScope.launch {
            try {
                repository.addFenetre(
                    datetimeDebut = datetimeDebut,
                    duree = duree,
                    idSatellite = idSatellite,
                    codeStation = codeStation
                )
                _fenetres.value = repository.getFenetres()
                _planningMessage.value = "Fenetre ajoutee."
            } catch (_: Exception) {
                _planningMessage.value = "Erreur reseau lors de l'ajout."
            }
        }
    }

    fun markFenetreAsRealisee(idFenetre: Int) {
        viewModelScope.launch {
            try {
                val ok = repository.markFenetreAsRealisee(
                    idFenetre = idFenetre,
                    today = LocalDate.now()
                )
                _fenetres.value = repository.getFenetres()
                _planningMessage.value =
                    if (ok) {
                        "Fenetre passee en REALISEE."
                    } else {
                        "Impossible: seule une fenetre planifiee dans le passe peut etre validee REALISEE."
                    }
            } catch (_: Exception) {
                _planningMessage.value = "Erreur reseau lors de la mise a jour."
            }
        }
    }

    fun loadAnomaliesForSatellite(
        satelliteId: String
    ) {
        viewModelScope.launch {
            try {
                _anomalies.value =
                    repository.getAnomaliesForSatellite(satelliteId)
            } catch (_: Exception) {
                _errorMessage.value = "Erreur reseau (anomalies)."
            }
        }
    }

    fun addAnomalyToSatellite(
        satelliteId: String,
        description: String
    ) {
        if (description.isBlank()) return
        viewModelScope.launch {
            try {
                repository.addAnomalie(
                    satelliteId = satelliteId,
                    description = description
                )
                _anomalies.value =
                    repository.getAnomaliesForSatellite(satelliteId)
            } catch (_: Exception) {
                _errorMessage.value = "Erreur reseau lors de l'ajout anomalie."
            }
        }
    }

    fun markAnomalyAsTraitee(
        satelliteId: String,
        anomalyId: Int
    ) {
        viewModelScope.launch {
            try {
                repository.markAnomalieAsTraitee(anomalyId)
                _anomalies.value =
                    repository.getAnomaliesForSatellite(satelliteId)
            } catch (_: Exception) {
                _errorMessage.value = "Erreur reseau lors de la mise a jour anomalie."
            }
        }
    }

}
