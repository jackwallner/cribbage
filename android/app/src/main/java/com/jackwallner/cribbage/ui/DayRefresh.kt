package com.jackwallner.cribbage.ui

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LifecycleEventEffect
import java.time.Duration
import java.time.LocalDate
import java.time.ZonedDateTime
import kotlinx.coroutines.delay

object DayRefresh {
    /** How long a screen waits to turn over: one second past the next local midnight. */
    fun millisUntilNextDay(now: ZonedDateTime): Long {
        val midnight = now.toLocalDate().plusDays(1).atStartOfDay(now.zone)
        return maxOf(1_000L, Duration.between(now, midnight).toMillis() + 1_000L)
    }
}

/**
 * Today, kept current while the screen stays up. A screen that read the day
 * once kept yesterday's (the Get Started card, the streak, the Minute's score)
 * until something else redrew it, and returning the next morning redraws
 * nothing. Refreshed on return to the app, at midnight, and on a clock or
 * time zone change.
 */
@Composable
fun rememberToday(): LocalDate {
    val clock = LocalGraph.current.clock
    val context = LocalContext.current
    var today by remember { mutableStateOf(clock.today()) }
    LifecycleEventEffect(Lifecycle.Event.ON_START) { today = clock.today() }
    LaunchedEffect(Unit) {
        while (true) {
            delay(DayRefresh.millisUntilNextDay(ZonedDateTime.now(clock.clock)))
            today = clock.today()
        }
    }
    DisposableEffect(context) {
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                today = clock.today()
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
        }
        ContextCompat.registerReceiver(context, receiver, filter, ContextCompat.RECEIVER_NOT_EXPORTED)
        onDispose { context.unregisterReceiver(receiver) }
    }
    return today
}
