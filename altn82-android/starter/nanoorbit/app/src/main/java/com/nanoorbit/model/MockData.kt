package com.nanoorbit.model

import java.time.LocalDate
import java.time.LocalDateTime

object MockData {

    val orbites = listOf(

        Orbite(
            1,
            TypeOrbite.SSO,
            550.0,
            97.6,
            "Arctique"
        ),

        Orbite(
            2,
            TypeOrbite.SSO,
            600.0,
            98.2,
            "Europe"
        ),

        Orbite(
            3,
            TypeOrbite.LEO,
            450.0,
            51.6,
            "Atlantique"
        )
    )

    val satellites = listOf(

        Satellite(
            "SAT-001",
            "NanoClimate-1",
            StatutSatellite.OPERATIONNEL,
            FormatCubeSat.U3,
            1,
            LocalDate.of(2023,5,10),
            4.5
        ),

        Satellite(
            "SAT-002",
            "NanoClimate-2",
            StatutSatellite.EN_VEILLE,
            FormatCubeSat.U6,
            2
        ),

        Satellite(
            "SAT-003",
            "NanoIce",
            StatutSatellite.OPERATIONNEL,
            FormatCubeSat.U3,
            1
        ),

        Satellite(
            "SAT-004",
            "NanoCoast",
            StatutSatellite.DEFAILLANT,
            FormatCubeSat.U12,
            3
        ),

        // Obligatoire sujet
        Satellite(
            "SAT-005",
            "LegacySat",
            StatutSatellite.DESORBITE,
            FormatCubeSat.U1,
            3
        )
    )

    val instruments = listOf(

        Instrument(
            "INS-01",
            "Camera",
            "HyperCam",
            0.8,
            20.0
        ),

        Instrument(
            "INS-02",
            "Thermique",
            "ThermoScan",
            1.4,
            15.0
        ),

        Instrument(
            "INS-03",
            "Radar",
            "MiniSAR",
            null,
            30.0
        ),

        Instrument(
            "INS-04",
            "Spectrometre",
            "SpecX",
            0.5,
            18.0
        )
    )

    val stations = listOf(

        StationSol(
            "FR-TLS",
            "Toulouse",
            43.6045,
            1.4440
        ),

        StationSol(
            "SG-SIN",
            "Singapore",
            1.3521,
            103.8198
        ),

        StationSol(
            "CA-MTL",
            "Montreal",
            45.5017,
            -73.5673
        )
    )

    val fenetres = listOf(

        FenetreCom(
            1,
            LocalDateTime.now().plusHours(1),
            500,
            StatutFenetre.PLANIFIEE,
            "SAT-001",
            "FR-TLS"
        ),

        FenetreCom(
            2,
            LocalDateTime.now().plusHours(2),
            300,
            StatutFenetre.PLANIFIEE,
            "SAT-002",
            "SG-SIN"
        ),

        FenetreCom(
            3,
            LocalDateTime.now().minusHours(4),
            600,
            StatutFenetre.REALISEE,
            "SAT-003",
            "CA-MTL",
            800.0
        ),

        FenetreCom(
            4,
            LocalDateTime.now().minusHours(8),
            250,
            StatutFenetre.REALISEE,
            "SAT-001",
            "FR-TLS",
            350.0
        ),

        FenetreCom(
            5,
            LocalDateTime.now().minusDays(1),
            720,
            StatutFenetre.REALISEE,
            "SAT-004",
            "SG-SIN",
            1200.0
        )

    )

    val anomalies = listOf(
        Anomalie(
            idAnomalie = 1,
            idSatellite = "SAT-001",
            dateSignalement = LocalDateTime.now().minusDays(2),
            description = "Instabilite de telemetrie detectee.",
            statut = "OUVERTE"
        )
    )
}
