package com.lpav.market.ui.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.grid.rememberLazyGridState
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lpav.market.core.model.TravelPackage
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.map

@Composable
fun CatalogGrid(
    packages: List<TravelPackage>,
    wishlistIds: Set<String>,
    onPackageClick: (TravelPackage) -> Unit,
    onToggleWishlist: (String) -> Unit,
    onToggleCart: (String) -> Unit,
    onLoadMore: () -> Unit,
    isLoading: Boolean = false,
    modifier: Modifier = Modifier
) {
    val gridState = rememberLazyGridState()

    LaunchedEffect(gridState) {
        snapshotFlow { gridState.layoutInfo.visibleItemsInfo.lastOrNull()?.index }
            .map { lastVisibleIndex ->
                lastVisibleIndex != null &&
                        lastVisibleIndex >= gridState.layoutInfo.totalItemsCount - 3
            }
            .distinctUntilChanged()
            .filter { it }
            .collect {
                onLoadMore()
            }
    }

    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        state = gridState,
        modifier = modifier.fillMaxWidth(),
        contentPadding = PaddingValues(bottom = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(packages, key = { it.packageId }) { pkg ->
            PackageCard(
                pkg = pkg,
                isInWishlist = wishlistIds.contains(pkg.packageId),
                onClick = { onPackageClick(pkg) },
                onToggleWishlist = { onToggleWishlist(pkg.packageId) },
                onToggleCart = { onToggleCart(pkg.packageId) }
            )
        }

        if (isLoading) {
            item(span = { GridItemSpan(2) }) {
                Box(
                    modifier = Modifier.fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
                }
            }
        }
    }
}
