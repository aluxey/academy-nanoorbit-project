package com.nanoorbit.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.nanoorbit.model.FenetreCom
import com.nanoorbit.model.StatutFenetre
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

@Composable
fun FenetreCard(
    fenetre: FenetreCom,
    nomStation: String,
    onValidateRealisee: (() -> Unit)? = null,
    canValidateRealisee: Boolean = false
){
    val dtFormat = DateTimeFormatter.ofPattern("dd/MM HH:mm")
    val isRealisee = fenetre.statut == StatutFenetre.REALISEE
    val isPlannedPast =
        fenetre.statut == StatutFenetre.PLANIFIEE &&
            fenetre.datetimeDebut.isBefore(LocalDateTime.now())

    val bgColor =
        when {
            isRealisee -> Color(0xFFE8F5E9)
            isPlannedPast -> Color(0xFFFFEBEE)
            else -> Color(0xFFFFF3E0)
        }

    val borderColor =
        when {
            isRealisee -> Color(0xFF81C784)
            isPlannedPast -> Color(0xFFE57373)
            else -> Color(0xFFFFB74D)
        }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        shape = RoundedCornerShape(10.dp),
        border = BorderStroke(
            1.dp,
            borderColor
        ),
        colors = CardDefaults.cardColors(
            containerColor = bgColor
        )
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = nomStation,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.SemiBold
                )
            }

            InfoLine(
                label = "Debut",
                value = fenetre.datetimeDebut.format(dtFormat)
            )

            InfoLine(
                label = "Duree",
                value = "${fenetre.duree}s"
            )

            InfoLine(
                label = "Statut",
                value = fenetre.statut.name
            )

            if (!isRealisee && onValidateRealisee != null) {
                Button(
                    onClick = {
                        onValidateRealisee.invoke()
                    },
                    enabled = canValidateRealisee
                ) {
                    Text("Definir comme realisee")
                }
            }

            fenetre.volumeDonnees?.let {
                InfoLine(
                    label = "Volume",
                    value = "$it MB"
                )
            }
        }
    }
}

@Composable
private fun InfoLine(
    label: String,
    value: String
) {
    Row {
        Text(
            text = "$label:",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.width(6.dp))
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium
        )
    }
}
