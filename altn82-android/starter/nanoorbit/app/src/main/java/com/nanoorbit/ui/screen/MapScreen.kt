package com.nanoorbit.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.nanoorbit.model.MockData
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@Composable
fun MapScreen(){
    val context = LocalContext.current
    val stations = MockData.stations

    val mapView = remember {
        Configuration.getInstance().userAgentValue = context.packageName
        MapView(context).apply {
            setTileSource(TileSourceFactory.MAPNIK)
            setMultiTouchControls(true)
            controller.setZoom(2.3)
            controller.setCenter(GeoPoint(20.0, 0.0))

            stations.forEach { station ->
                overlays.add(
                    Marker(this).apply {
                        position = GeoPoint(station.latitude, station.longitude)
                        title = station.nomStation
                        subDescription = station.codeStation
                        setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                    }
                )
            }
        }
    }

    DisposableEffect(mapView) {
        onDispose {
            mapView.onDetach()
        }
    }

    Column(
        Modifier.padding(16.dp)
    ){
        Text("Carte OpenStreetMap")

        Spacer(Modifier.height(8.dp))

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
        ) {
            AndroidView(
                modifier = Modifier.fillMaxSize(),
                factory = { mapView },
                update = {
                    it.invalidate()
                }
            )
        }

        Spacer(Modifier.height(8.dp))

        MockData.stations.forEach {
            Card(
                Modifier.padding(8.dp)
            ){
                Column(
                    Modifier.padding(16.dp)
                ){
                    Text(it.nomStation)
                    Text("${it.latitude}, ${it.longitude}")
                }
            }
        }
    }
}
