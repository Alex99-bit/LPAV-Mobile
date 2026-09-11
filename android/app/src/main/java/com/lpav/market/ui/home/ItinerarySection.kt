package com.lpav.market.ui.home

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Flight
import androidx.compose.material.icons.filled.Hotel
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.lpav.market.ui.theme.Blue500
import com.lpav.market.ui.theme.Emerald500
import com.lpav.market.ui.theme.Amber500

@Composable
fun ItinerarySection(
    itineraryJson: String,
    packageId: String,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    var days by remember { mutableStateOf<List<ItineraryDay>>(emptyList()) }

    val parsedDays = remember(itineraryJson) {
        try {
            val gson = com.google.gson.Gson()
            val items = gson.fromJson(itineraryJson, Array<Map<String, Any>>::class.java)
            items?.mapNotNull { item ->
                ItineraryDay(
                    day = (item["day"] as? Double)?.toInt() ?: 0,
                    title = item["title"] as? String ?: "",
                    description = item["description"] as? String ?: "",
                    type = item["type"] as? String ?: "explorar"
                )
            } ?: generateSampleItinerary()
        } catch (e: Exception) {
            generateSampleItinerary()
        }
    }

    Column(modifier = modifier.fillMaxWidth()) {
        TextButton(
            onClick = { expanded = !expanded },
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Itinerario",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier.weight(1f)
                )
                Icon(
                    if (expanded) Icons.Filled.ExpandLess else Icons.Filled.ExpandMore,
                    "Expandir",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        AnimatedVisibility(
            visible = expanded,
            enter = expandVertically(),
            exit = shrinkVertically()
        ) {
            Column(modifier = Modifier.padding(horizontal = 8.dp)) {
                parsedDays.forEachIndexed { index, day ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        verticalAlignment = Alignment.Top
                    ) {
                        val icon = when (day.type) {
                            "vuelo" -> Icons.Filled.Flight
                            "hotel" -> Icons.Filled.Hotel
                            "comida" -> Icons.Filled.Restaurant
                            else -> Icons.Filled.Flight
                        }
                        val iconColor = when (day.type) {
                            "vuelo" -> Blue500
                            "hotel" -> Emerald500
                            "comida" -> Amber500
                            else -> Emerald500
                        }

                        Icon(
                            icon,
                            null,
                            tint = iconColor,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                "D\u00EDa ${day.day} - ${day.title}",
                                style = MaterialTheme.typography.titleSmall,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                day.description,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                    if (index < parsedDays.size - 1) {
                        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                    }
                }
            }
        }
    }
}

data class ItineraryDay(
    val day: Int,
    val title: String,
    val description: String,
    val type: String
)

private fun generateSampleItinerary(): List<ItineraryDay> = listOf(
    ItineraryDay(1, "Llegada y traslado", "Traslado al hotel y check-in", "vuelo"),
    ItineraryDay(2, "Tour guiado", "Recorrido por los principales puntos de inter\u00E9s", "explorar"),
    ItineraryDay(3, "Actividad opcional", "Tiempo libre para actividades", "explorar"),
    ItineraryDay(4, "Regreso", "Check-out y traslado al aeropuerto", "vuelo")
)
