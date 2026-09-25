package com.lpav.market.ui.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RangeSlider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lpav.market.ui.components.LpavTextField

@Composable
fun PriceFilterSection(
    onApplyFilter: (min: Double?, max: Double?) -> Unit,
    modifier: Modifier = Modifier
) {
    var minPrice by remember { mutableStateOf("") }
    var maxPrice by remember { mutableStateOf("") }
    var sliderRange by remember { mutableStateOf(0f..10000f) }

    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = "Precio",
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            LpavTextField(
                value = minPrice,
                onValueChange = { minPrice = it },
                label = "M\u00EDnimo",
                modifier = Modifier.weight(1f)
            )
            LpavTextField(
                value = maxPrice,
                onValueChange = { maxPrice = it },
                label = "M\u00E1ximo",
                modifier = Modifier.weight(1f)
            )
        }
        Spacer(modifier = Modifier.height(8.dp))
        RangeSlider(
            value = sliderRange,
            onValueChange = {
                sliderRange = it
                minPrice = it.start.toInt().toString()
                maxPrice = it.endInclusive.toInt().toString()
            },
            valueRange = 0f..10000f,
            steps = 9
        )
        Spacer(modifier = Modifier.height(8.dp))
        Button(
            onClick = {
                val min = minPrice.toDoubleOrNull()
                val max = maxPrice.toDoubleOrNull()
                onApplyFilter(min, max)
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Aplicar filtro")
        }
    }
}
