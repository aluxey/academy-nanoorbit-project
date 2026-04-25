package com.nanoorbit.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope

import com.nanoorbit.data.NanoOrbitRepository
import com.nanoorbit.model.Satellite
import com.nanoorbit.model.StatutSatellite

import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

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
                    "Erreur réseau"

            } finally {

                _isLoading.value = false

            }

        }

    }


    fun refreshSatellites(){

        loadSatellites()

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

}