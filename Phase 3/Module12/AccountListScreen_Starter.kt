package com.pnc.jetpackcomposedemos//
// AccountListScreen_Starter.kt
// Module 12 — Android UI Development
// Lab Exercise: PNC Mobile — Accounts List Screen (Jetpack Compose)
//
// SCENARIO
// Build the accounts list screen for PNC Mobile Android — the final screen
// for Module 12. This exercise pulls together state (Block 1), navigation
// (Block 3), LazyColumn (Block 4), accessibility (Block 6), and animation
// (Block 7).
//
// REQUIREMENTS
// 1. Build AccountListScreen using LazyColumn and Material 3 components.
// 2. Each row shows account name, masked account number, and balance.
// 3. Tapping a row calls onAccountClick(accountId) — wiring this to actual
//    Navigation Compose is assumed to happen in a NavHost elsewhere (not
//    part of this file).
// 4. Every row must be fully readable by TalkBack as ONE combined element,
//    not three separate announcements.
// 5. Add an AnimatedVisibility confirmation banner that appears briefly
//    after a simulated refresh (a button that toggles a "Refreshed!"
//    message is sufficient to demonstrate this).
//
// The Account model below is complete. Implement the two TODOs.
//

import android.icu.text.NumberFormat
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandHorizontally
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp


// MARK: - Model (complete — no changes needed)

data class Account(
    val id: String,
    val name: String,
    val maskedNumber: String,
    val balance: Double
)

val sampleAccounts = listOf(
    Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
    Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
    Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
)

// MARK: - TODO 1: AccountListScreen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AccountListScreen(accounts: List<Account> = sampleAccounts, onAccountClick: (String) -> Unit = {}) {
    // TODO: Show a "Refresh" button. When tapped, set a boolean state to
    // true, then use AnimatedVisibility to show a "Refreshed!" confirmation
    // banner (fadeIn/fadeOut) above the list.
    //
    // Below the banner, use a LazyColumn with items(accounts, key = { it.id })
    // to render an AccountRow for each account.
    var isRefresh by remember {
        mutableStateOf(false)

    }


    Scaffold(
        topBar = {
            Column{
                TopAppBar(
                    title = {
                        Text(
                            "Accounts",
                            style = MaterialTheme.typography.headlineMedium
                        )
                    }
                )

                IconButton(
                    onClick = {
                        isRefresh = !isRefresh
                    }
                ) {
                    //refresh icon
                    Icon(Icons.Default.Refresh, contentDescription = "Refresh")
                }

                AnimatedVisibility(
                    visible = isRefresh,
                    enter = expandHorizontally(expandFrom = Alignment.Start) + fadeIn(),
                    exit = shrinkHorizontally(shrinkTowards = Alignment.End) + fadeOut()
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(MaterialTheme.colorScheme.tertiaryContainer)


                    ) {
                        Text(
                            "Refreshed!",
                            color = MaterialTheme.colorScheme.onTertiaryContainer
                        )
                    }
                }


            }
        },
    ){ innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(
                items = accounts,
                key = {account -> account.id}
            ){ account ->
                AccountRow(
                    account = account,
                    onClick = {onAccountClick(account.id)}
                )

            }
        }
    }

    }


// MARK: - TODO 2: AccountRow

@Composable
fun AccountRow(account: Account, onClick: () -> Unit) {
    // TODO: Lay out account.name, account.maskedNumber, and account.balance
    // in a Row/Column combination. Use MaterialTheme.typography styles only
    // — no hard-coded font sizes. Add
    // Modifier.semantics(mergeDescendants = true) {} and a single,
    // readable contentDescription for the whole row.
    val formattedBalance = NumberFormat.getCurrencyInstance().format(account.balance)
    Card(
        modifier = Modifier.semantics(
            mergeDescendants = true
        ) {
            contentDescription = "Account: ${account.name}, " +
                    "Account number: ${account.maskedNumber}, " +
                    "Balance: $formattedBalance"
        },
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainer
        ),
        shape = MaterialTheme.shapes.medium
    ) {

       Row(
           modifier = Modifier
               .fillMaxWidth()
               .padding(16.dp),
           horizontalArrangement = Arrangement.SpaceBetween
       ) {
           Column{
               Text(
                   text = account.name,
                   style = MaterialTheme.typography.titleMedium
               )
               Text(
                   "Account Number: ${account.maskedNumber}",
                   style = MaterialTheme.typography.bodyMedium
               )
           }
           Column{
               Text(
                   "$formattedBalance",
                   style = MaterialTheme.typography.bodyLarge
               )
           }
       }
    }
}
