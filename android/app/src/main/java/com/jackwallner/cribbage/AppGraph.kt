package com.jackwallner.cribbage

import android.content.Context
import com.jackwallner.cribbage.data.AlarmReminderScheduler
import com.jackwallner.cribbage.data.AppClock
import com.jackwallner.cribbage.data.AppSettings
import com.jackwallner.cribbage.data.ConversionDiagnostics
import com.jackwallner.cribbage.data.CribbageMinuteStore
import com.jackwallner.cribbage.data.PracticeRecordStore
import com.jackwallner.cribbage.data.ProgressStore
import com.jackwallner.cribbage.data.ReviewPromptTracker
import com.jackwallner.cribbage.data.SharedPreferencesStore
import com.jackwallner.cribbage.data.SubscriptionService
import com.jackwallner.cribbage.data.WhatsNewTracker
import kotlinx.coroutines.MainScope

/** Every long-lived object the screens share, built once per process. */
class AppGraph(context: Context) {
    val appContext: Context = context.applicationContext
    val scope = MainScope()
    val clock = AppClock()
    val defaults = SharedPreferencesStore(appContext)
    val settings = AppSettings(defaults, AlarmReminderScheduler(appContext))
    val progress = ProgressStore(defaults, clock)
    val records = PracticeRecordStore(defaults, clock)
    val minutes = CribbageMinuteStore(defaults, clock)
    val review = ReviewPromptTracker(defaults, clock)
    val diagnostics = ConversionDiagnostics(defaults, clock)
    val subscriptions = SubscriptionService(appContext, defaults, diagnostics)
    val whatsNew = WhatsNewTracker(defaults, BuildConfig.VERSION_NAME)

    /** Settings' Reset Progress: every practice stat, never onboarding or purchases. */
    fun resetProgress() {
        progress.resetAll()
        records.resetAll()
        minutes.resetAll()
    }
}
