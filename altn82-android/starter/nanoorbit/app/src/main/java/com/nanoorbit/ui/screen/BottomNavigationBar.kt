package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.nanoorbit.navigation.Routes

@Composable
fun NanoOrbitApp() {

    val navController =
        rememberNavController()

    Scaffold(

        bottomBar = {

            val currentRoute =
                navController
                    .currentBackStackEntryAsState()
                    .value
                    ?.destination
                    ?.route

            if(
                currentRoute != Routes.DETAIL
            ){

                NavigationBar {

                    NavigationBarItem(
                        selected =
                            currentRoute ==
                                    Routes.DASHBOARD,

                        onClick = {
                            navController.navigate(
                                Routes.DASHBOARD
                            )
                        },

                        label = {
                            Text("Dashboard")
                        },

                        icon = {}
                    )

                    NavigationBarItem(
                        selected =
                            currentRoute ==
                                    Routes.PLANNING,

                        onClick = {
                            navController.navigate(
                                Routes.PLANNING
                            )
                        },

                        label = {
                            Text("Planning")
                        },

                        icon = {}
                    )

                    NavigationBarItem(
                        selected =
                            currentRoute ==
                                    Routes.MAP,

                        onClick = {
                            navController.navigate(
                                Routes.MAP
                            )
                        },

                        label = {
                            Text("Carte")
                        },

                        icon = {}
                    )

                }

            }

        }

    ) { padding ->

        NavHost(
            navController,
            startDestination =
                Routes.DASHBOARD,
            modifier =
                Modifier.padding(padding)
        ) {

            composable(
                Routes.DASHBOARD
            ){
                DashboardScreen(
                    onSatelliteClick = {

                        navController.navigate(
                            Routes.detailRoute(it)
                        )

                    }
                )
            }

            composable(
                Routes.PLANNING
            ){
                PlanningScreen()
            }

            composable(
                Routes.MAP
            ){
                MapScreen()
            }

            composable(
                Routes.DETAIL
            ){ backStack ->

                val id =
                    backStack.arguments
                        ?.getString(
                            "satelliteId"
                        ) ?: ""

                DetailScreen(
                    satelliteId = id,
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

        }

    }

}
