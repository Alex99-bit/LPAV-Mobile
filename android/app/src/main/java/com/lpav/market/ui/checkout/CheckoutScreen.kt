package com.lpav.market.ui.checkout

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lpav.market.ui.theme.PrimaryBlue
import com.lpav.market.ui.theme.SecondaryGold
import com.lpav.market.core.model.CartItem

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CheckoutScreen(
    onNavigateBack: () -> Unit,
    onOrderComplete: () -> Unit,
    viewModel: CheckoutViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var cardNumber by remember { mutableStateOf("") }
    var expiryDate by remember { mutableStateOf("") }
    var cvv by remember { mutableStateOf("") }

    LaunchedEffect(uiState.success) {
        if (uiState.success) onOrderComplete()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Checkout", color = Color.White) },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Volver", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = PrimaryBlue)
            )
        }
    ) { padding ->
        if (uiState.isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = PrimaryBlue)
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                item {
                    Text(
                        "Resumen de Pedido",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                }

                items(uiState.items) { item ->
                    CheckoutItemCard(item)
                }

                item {
                    Card(
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text("Subtotal")
                                Text("$${String.format("%.2f", uiState.subtotal)}")
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text("IVA (16%)")
                                Text("$${String.format("%.2f", uiState.iva)}")
                            }
                            Spacer(modifier = Modifier.height(8.dp))
                            HorizontalDivider()
                            Spacer(modifier = Modifier.height(8.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text("Total", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                                Text(
                                    "$${String.format("%.2f", uiState.total)}",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 18.sp,
                                    color = PrimaryBlue
                                )
                            }
                        }
                    }
                }

                item {
                    Card(shape = RoundedCornerShape(12.dp)) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text(
                                "Opción de Pago",
                                fontWeight = FontWeight.SemiBold
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Text("Pago completo", fontWeight = FontWeight.Medium)
                                    Text(
                                        "$${String.format("%.2f", uiState.total)}",
                                        color = PrimaryBlue,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                                RadioButton(
                                    selected = uiState.payFull,
                                    onClick = { viewModel.togglePayFull() },
                                    colors = RadioButtonDefaults.colors(selectedColor = PrimaryBlue)
                                )
                            }
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Text("Solo depósito (30%)", fontWeight = FontWeight.Medium)
                                    Text(
                                        "$${String.format("%.2f", uiState.depositAmount)}",
                                        color = SecondaryGold,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                                RadioButton(
                                    selected = !uiState.payFull,
                                    onClick = { viewModel.togglePayFull() },
                                    colors = RadioButtonDefaults.colors(selectedColor = PrimaryBlue)
                                )
                            }
                        }
                    }
                }

                item {
                    Card(shape = RoundedCornerShape(12.dp)) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("Fecha de Viaje", fontWeight = FontWeight.SemiBold)
                            Spacer(modifier = Modifier.height(8.dp))
                            OutlinedTextField(
                                value = uiState.travelDate,
                                onValueChange = { viewModel.updateTravelDate(it) },
                                modifier = Modifier.fillMaxWidth(),
                                placeholder = { Text("DD/MM/AAAA") },
                                leadingIcon = { Icon(Icons.Default.CalendarToday, contentDescription = null) },
                                singleLine = true,
                                shape = RoundedCornerShape(12.dp)
                            )
                            Spacer(modifier = Modifier.height(12.dp))
                            Text("Notas", fontWeight = FontWeight.SemiBold)
                            Spacer(modifier = Modifier.height(8.dp))
                            OutlinedTextField(
                                value = uiState.notes,
                                onValueChange = { viewModel.updateNotes(it) },
                                modifier = Modifier.fillMaxWidth(),
                                placeholder = { Text("Instrucciones especiales...") },
                                minLines = 2,
                                shape = RoundedCornerShape(12.dp)
                            )
                        }
                    }
                }

                item {
                    Card(shape = RoundedCornerShape(12.dp)) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("Datos de Tarjeta (Stripe)", fontWeight = FontWeight.SemiBold)
                            Spacer(modifier = Modifier.height(12.dp))
                            OutlinedTextField(
                                value = cardNumber,
                                onValueChange = { cardNumber = it },
                                modifier = Modifier.fillMaxWidth(),
                                label = { Text("Número de tarjeta") },
                                leadingIcon = { Icon(Icons.Default.CreditCard, contentDescription = null) },
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                singleLine = true,
                                shape = RoundedCornerShape(12.dp)
                            )
                            Spacer(modifier = Modifier.height(12.dp))
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = expiryDate,
                                    onValueChange = { expiryDate = it },
                                    modifier = Modifier.weight(1f),
                                    label = { Text("MM/AA") },
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                    singleLine = true,
                                    shape = RoundedCornerShape(12.dp)
                                )
                                OutlinedTextField(
                                    value = cvv,
                                    onValueChange = { cvv = it },
                                    modifier = Modifier.weight(1f),
                                    label = { Text("CVV") },
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                    singleLine = true,
                                    shape = RoundedCornerShape(12.dp)
                                )
                            }
                        }
                    }
                }

                item {
                    uiState.errorMessage?.let { error ->
                        Card(
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.errorContainer
                            )
                        ) {
                            Text(
                                error,
                                modifier = Modifier.padding(16.dp),
                                color = MaterialTheme.colorScheme.onErrorContainer
                            )
                        }
                    }
                }

                item {
                    if (uiState.isProcessing) {
                        Box(
                            modifier = Modifier.fillMaxWidth(),
                            contentAlignment = Alignment.Center
                        ) {
                            CircularProgressIndicator(color = PrimaryBlue)
                        }
                    } else {
                        Button(
                            onClick = { viewModel.processCheckout() },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(52.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Text(
                                "Pagar $${String.format("%.2f", if (uiState.payFull) uiState.total else uiState.depositAmount)}",
                                fontWeight = FontWeight.SemiBold,
                                fontSize = 16.sp
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun CheckoutItemCard(item: CartItem) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(60.dp)
                    .clip(RoundedCornerShape(8.dp))
            ) {
                item.packageImage?.let { url ->
                    coil.compose.AsyncImage(
                        model = url,
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = androidx.compose.ui.layout.ContentScale.Crop
                    )
                }
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(item.packageTitle, fontWeight = FontWeight.SemiBold, maxLines = 1)
                Text(
                    "x${item.quantity}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Text(
                "$${String.format("%.2f", item.basePrice * item.quantity)}",
                fontWeight = FontWeight.Bold,
                color = PrimaryBlue
            )
        }
    }
}
