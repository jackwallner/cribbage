package com.jackwallner.cribbage

import com.jackwallner.cribbage.data.AppSettings
import com.jackwallner.cribbage.data.InMemoryStore
import com.jackwallner.cribbage.data.ReminderScheduler
import java.time.DayOfWeek
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** iOS B3: a reminder that is on while notifications are off says so instead of reading on in silence. */
class ReminderRefreshTest {
    private class Recorder : ReminderScheduler {
        val calls = mutableListOf<String>()
        override fun scheduleDaily(hour: Int, minute: Int) { calls += "daily $hour:$minute" }
        override fun cancelDaily() { calls += "cancel daily" }
        override fun scheduleGameNight(day: DayOfWeek, hour: Int, minute: Int) { calls += "game night $day $hour:$minute" }
        override fun cancelGameNight() { calls += "cancel game night" }
    }

    private val defaults = InMemoryStore()

    private fun stored(daily: Boolean, gameNight: Boolean): Pair<AppSettings, Recorder> {
        defaults.putBoolean("settings.reminderEnabled", daily)
        defaults.putBoolean("settings.gameNightReminderEnabled", gameNight)
        val scheduler = Recorder()
        return AppSettings(defaults, scheduler) to scheduler
    }

    @Test
    fun launchWithNotificationsOffSaysSoAndKeepsTheChoice() {
        val (settings, scheduler) = stored(daily = true, gameNight = true)
        settings.reconcileReminders(canNotify = false)
        assertTrue("Settings shows the Open Settings message", settings.reminderPermissionDenied)
        assertTrue(settings.reminderEnabled)
        assertTrue(settings.gameNightReminderEnabled)
        assertTrue(scheduler.calls.isEmpty())
    }

    @Test
    fun gameNightReminderAloneRaisesTheMessage() {
        val (settings, _) = stored(daily = false, gameNight = true)
        settings.reconcileReminders(canNotify = false)
        assertTrue(settings.reminderPermissionDenied)
    }

    @Test
    fun notificationsBackOnClearsTheMessageAndLaysTheAlarmsAgain() {
        val (settings, scheduler) = stored(daily = true, gameNight = true)
        settings.reconcileReminders(canNotify = false)
        assertTrue("precondition", settings.reminderPermissionDenied)
        settings.reconcileReminders(canNotify = true)
        assertFalse(settings.reminderPermissionDenied)
        assertEquals(2, scheduler.calls.size)
        assertTrue(scheduler.calls.any { it == "daily 9:0" })
        assertTrue(scheduler.calls.any { it.startsWith("game night") })
    }

    @Test
    fun notificationsOffWithRemindersOffSaysNothing() {
        val (settings, scheduler) = stored(daily = false, gameNight = false)
        settings.reconcileReminders(canNotify = false)
        assertFalse(settings.reminderPermissionDenied)
        assertTrue(scheduler.calls.isEmpty())
    }
}
