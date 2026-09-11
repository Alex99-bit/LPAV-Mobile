package com.lpav.market.ui.home

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

private val regions = listOf(
    null to "Todos",
    "Europa" to "Europa",
    "Asia" to "Asia",
    "Am\u00E9rica del Norte" to "Norteam\u00E9rica",
    "Am\u00E9rica del Sur" to "Sudam\u00E9rica",
    "Centroam\u00E9rica" to "Centroam\u00E9rica",
    "Caribe" to "Caribe",
    "\u00C1frica" to "\u00C1frica",
    "Ocean\u00EDa" to "Ocean\u00EDa"
)

@Composable
fun RegionFilterSection(
    selectedRegion: String?,
    onRegionSelected: (String?) -> Unit,
    modifier: Modifier = Modifier
) {
    LazyRow(
        modifier = modifier,
        contentPadding = PaddingValues(vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(regions) { (region, label) ->
            FilterChip(
                selected = selectedRegion == region,
                onClick = { onRegionSelected(region) },
                label = { Text(label) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = MaterialTheme.colorScheme.primary,
                    selectedLabelColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    }
}
