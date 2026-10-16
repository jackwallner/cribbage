package com.jackwallner.cribbage.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.jackwallner.cribbage.content.DrillLibrary
import com.jackwallner.cribbage.content.PracticeSkill
import com.jackwallner.cribbage.content.SessionBuilder
import com.jackwallner.cribbage.data.PracticeRecordStore
import com.jackwallner.cribbage.ui.LocalGraph
import com.jackwallner.cribbage.ui.components.symbol
import com.jackwallner.cribbage.ui.nav.LocalNavigator
import com.jackwallner.cribbage.ui.nav.PracticeMode
import com.jackwallner.cribbage.ui.nav.Route
import com.jackwallner.cribbage.ui.nav.SessionPurpose
import com.jackwallner.cribbage.ui.theme.CapsuleBar
import com.jackwallner.cribbage.ui.theme.DayPickerRow
import com.jackwallner.cribbage.ui.theme.CribbageSwitch
import com.jackwallner.cribbage.ui.theme.TimePickerRow
import com.jackwallner.cribbage.ui.theme.Eyebrow
import com.jackwallner.cribbage.ui.theme.IconBadge
import com.jackwallner.cribbage.ui.theme.Crib
import com.jackwallner.cribbage.ui.theme.CribbageScreen
import com.jackwallner.cribbage.ui.theme.CribbageType
import com.jackwallner.cribbage.ui.theme.PrimaryCTA
import com.jackwallner.cribbage.ui.theme.Readable
import com.jackwallner.cribbage.ui.theme.navBarPadding
import com.jackwallner.cribbage.ui.theme.pressable
import com.jackwallner.cribbage.ui.theme.rounded
import com.jackwallner.cribbage.ui.theme.themedCard
import kotlin.math.roundToInt

private fun percent(fraction: Double) = "${(fraction * 100).roundToInt()}%"

/** One tap between Home and the first dealt hand. */
@Composable
fun EndlessPickerScreen() {
    val graph = LocalGraph.current
    val navigator = LocalNavigator.current
    val colors = Crib.colors
    CribbageScreen("Endless Practice", onBack = { navigator.pop() }) {
        Readable(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
            Column(Modifier.padding(horizontal = 16.dp).padding(navBarPadding()), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(
                    Modifier.fillMaxWidth().padding(top = 12.dp).background(colors.jade.copy(alpha = 0.10f), rounded(16.dp)).padding(14.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    Icon(symbol("infinity"), null, tint = colors.jade, modifier = Modifier.size(20.dp))
                    Text(
                        "Every hand here is dealt fresh the moment you see it, so you can practise for as long as you like without repeating a question.",
                        style = CribbageType.subheadline,
                        color = colors.inkSecondary,
                    )
                }
                PracticeSkill.entries.forEach { skill ->
                    val record = graph.records.records[skill.raw]
                    Row(
                        Modifier.fillMaxWidth().testTag("skill-${skill.raw}").pressable {
                            navigator.push(Route.Practice(PracticeMode.Endless(skill)))
                        }.themedCard().padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(14.dp),
                    ) {
                        IconBadge(skill.icon, colors.jade, size = 48.dp, iconSize = 24.dp, corner = 14.dp, alpha = 0.12f)
                        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                            Text(skill.title, style = CribbageType.headline, color = colors.ink)
                            Text(skill.subtitle, style = CribbageType.subheadline, color = colors.inkSecondary)
                            if (record != null && record.attempts > 0) {
                                Text("${percent(record.accuracy)} across ${record.attempts} answered", style = CribbageType.caption2, color = colors.inkTertiary)
                            }
                        }
                        Icon(symbol("chevron.right"), null, tint = colors.inkTertiary, modifier = Modifier.size(18.dp))
                    }
                }
            }
        }
    }
}

/**
 * Practice history: overall accuracy, a bar per room, and the weak spot worth
 * working on next. Free for everyone.
 */
@Composable
fun StatsScreen() {
    val graph = LocalGraph.current
    val navigator = LocalNavigator.current
    val colors = Crib.colors
    val records = graph.records
    val progress = graph.progress
    val roomStats = records.roomStats()
    CribbageScreen("Your Progress", onBack = { navigator.pop() }) {
        Readable(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
            Column(Modifier.padding(horizontal = 16.dp).padding(navBarPadding()), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                if (records.totalAttempts == 0) {
                    Column(
                        Modifier.fillMaxWidth().padding(top = 12.dp).themedCard().padding(28.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        Icon(symbol("chart.bar.fill"), null, tint = colors.jade.copy(alpha = 0.5f), modifier = Modifier.size(40.dp))
                        Text("No practice yet", style = CribbageType.headline, color = colors.ink)
                        Text(
                            "Answer a few questions and your accuracy for every room shows up here.",
                            style = CribbageType.subheadline,
                            color = colors.inkSecondary,
                            textAlign = TextAlign.Center,
                        )
                    }
                } else {
                    Row(
                        Modifier.fillMaxWidth().padding(top = 12.dp).themedCard().padding(vertical = 18.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        StatMetric(percent(records.overallAccuracy), "accuracy", colors.jade, Modifier.weight(1f))
                        Divider()
                        StatMetric("${records.totalAttempts}", "answered", colors.ink, Modifier.weight(1f))
                        Divider()
                        StatMetric("${records.bestChallengeScore}", "best challenge", colors.coral, Modifier.weight(1f))
                    }
                    val weakest = records.weakestRoom()
                    if (weakest != null && roomStats.size > 1) {
                        IconCard("target", colors.coral, "Work on ${weakest.name}", "${percent(weakest.accuracy)} right across ${weakest.attempts} questions, your lowest so far.")
                    }
                    AccuracyBreakdown(roomStats)
                }
                val sessions = progress.totalSessions
                IconCard("flame.fill", colors.coral, "${progress.streakCount}-day streak", "$sessions drill${if (sessions == 1) "" else "s"} finished")
            }
        }
    }
}

@Composable
private fun Divider() {
    Box(Modifier.width(1.dp).height(34.dp).background(Crib.colors.rule))
}

@Composable
private fun StatMetric(value: String, caption: String, color: Color, modifier: Modifier) {
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(3.dp)) {
        Text(value, style = CribbageType.display(26.sp), color = color)
        Text(caption, style = CribbageType.caption, color = Crib.colors.inkSecondary, textAlign = TextAlign.Center)
    }
}

@Composable
private fun IconCard(icon: String, tint: Color, title: String, body: String) {
    val colors = Crib.colors
    Row(
        Modifier.fillMaxWidth().themedCard(16.dp).padding(14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        IconBadge(icon, tint, alpha = 0.13f)
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(title, style = CribbageType.headline, color = colors.ink)
            Text(body, style = CribbageType.caption, color = colors.inkSecondary)
        }
    }
}

@Composable
private fun barColor(fraction: Double): Color {
    val colors = Crib.colors
    return when {
        fraction >= 0.8 -> colors.bamGreen
        fraction >= 0.6 -> colors.gold
        else -> colors.coral
    }
}

@Composable
private fun AccuracyBreakdown(stats: List<PracticeRecordStore.RoomStat>) {
    val colors = Crib.colors
    Column(Modifier.fillMaxWidth().themedCard().padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        Eyebrow("BY ROOM")
        stats.forEach { stat ->
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Row {
                    Text(stat.name, style = CribbageType.subheadline.copy(fontWeight = FontWeight.SemiBold), color = colors.ink, modifier = Modifier.weight(1f))
                    Text(percent(stat.accuracy), style = CribbageType.subheadline.copy(fontWeight = FontWeight.Bold), color = barColor(stat.accuracy))
                }
                CapsuleBar(stat.accuracy.toFloat(), barColor(stat.accuracy))
                Text("${stat.correct} of ${stat.attempts} right", style = CribbageType.caption2, color = colors.inkTertiary)
            }
        }
    }
}

/** The weekly game-night reminder and the personalised prep session. */
@Composable
fun GameNightPrepScreen(requestNotifications: (onGranted: () -> Unit) -> Unit) {
    val graph = LocalGraph.current
    val navigator = LocalNavigator.current
    val colors = Crib.colors
    val settings = graph.settings
    val records = graph.records
    CribbageScreen("Game Night Prep", onBack = { navigator.pop() }) {
        Readable(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
            Column(Modifier.padding(16.dp).padding(navBarPadding()), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Column(
                    Modifier.fillMaxWidth().themedCard().padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    IconBadge("person.2.fill", colors.plum, size = 68.dp, iconSize = 30.dp)
                    Text("Walk in ready", style = CribbageType.display(28.sp), color = colors.ink)
                    Text(
                        "Set your usual cribbage night. The reminder opens a fresh session built from your mistakes, weakest room, and material you have not seen yet.",
                        style = CribbageType.subheadline,
                        color = colors.inkSecondary,
                        textAlign = TextAlign.Center,
                    )
                }
                Column(Modifier.fillMaxWidth().themedCard(16.dp).padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Eyebrow("WEEKLY REMINDER")
                            Text(
                                if (settings.gameNightReminderEnabled) "Prep is scheduled" else "Choose your game night",
                                style = CribbageType.headline,
                                color = colors.ink,
                            )
                        }
                        CribbageSwitch(settings.gameNightReminderEnabled, "Weekly game night reminder") { on ->
                            if (on) requestNotifications { settings.updateGameNightReminderEnabled(true) }
                            else settings.updateGameNightReminderEnabled(false)
                        }
                    }
                    Box(Modifier.fillMaxWidth().height(1.dp).background(colors.rule))
                    DayPickerRow(settings.gameNightDay) { settings.updateGameNightDay(it) }
                    TimePickerRow("Prep Reminder", settings.gameNightHour, settings.gameNightMinute) { hour, minute ->
                        settings.updateGameNightTime(hour, minute)
                    }
                    Text(
                        "At that time each ${settings.gameNightDay.displayName}, the notification opens directly into your personalized practice session.",
                        style = CribbageType.caption,
                        color = colors.inkSecondary,
                    )
                }
                val weakest = records.weakestRoom()
                val due = records.dueCount
                val copy = when {
                    due > 0 && weakest != null -> "$due due mistake${if (due == 1) "" else "s"} first, then extra work in ${weakest.name}."
                    due > 0 -> "$due due mistake${if (due == 1) "" else "s"} first, followed by material you have not seen yet."
                    weakest != null -> "Extra work in ${weakest.name}, followed by a balanced mix from the other rooms."
                    else -> "A balanced member mix now. As you answer more questions, this session will zero in on your real weak spots."
                }
                Row(Modifier.fillMaxWidth().themedCard(16.dp).padding(16.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    IconBadge("scope", colors.coral, size = 40.dp)
                    Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                        Text("What today's prep targets", style = CribbageType.headline, color = colors.ink)
                        Text(copy, style = CribbageType.subheadline, color = colors.inkSecondary)
                    }
                }
                PrimaryCTA("Start My Five-Minute Prep", Modifier.testTag("start-prep"), color = colors.plum) {
                    navigator.push(Route.Session(gameNightPrepItems(graph), SessionPurpose.GameNightPrep))
                }
                Spacer(Modifier.height(4.dp))
            }
        }
    }
}

fun gameNightPrepItems(graph: com.jackwallner.cribbage.AppGraph) = SessionBuilder.gameNightPrep(
    seen = graph.progress.seenItems,
    missed = graph.progress.missedItems,
    dueIDs = graph.records.reviewQueue(),
    weakestRoomID = graph.records.weakestRoom()?.id,
)
