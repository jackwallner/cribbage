package com.jackwallner.cribbage.data

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.jackwallner.cribbage.content.CribbageContent
import com.jackwallner.cribbage.content.CribbageMinuteCategory
import com.jackwallner.cribbage.content.CribbageMinuteChallenge
import com.jackwallner.cribbage.content.CribbageMinuteContent
import com.jackwallner.cribbage.content.WhatsNewRelease
import java.time.Instant
import java.time.LocalDate
import java.time.chrono.IsoChronology
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeFormatterBuilder
import java.time.format.FormatStyle
import java.time.temporal.WeekFields
import java.util.Locale
import org.json.JSONArray
import org.json.JSONObject

/** Month and day, no year, in a locale's own order. */
object DayLabel {
    private val segment = Regex("'[^']*'|[A-Za-z]+|[^A-Za-z']+")

    fun pattern(locale: Locale): String = runCatching {
        val long = DateTimeFormatterBuilder.getLocalizedDateTimePattern(FormatStyle.LONG, null, IsoChronology.INSTANCE, locale)
        val parts = segment.findAll(long).map { it.value }.toMutableList()
        fun isField(part: String) = part[0].isLetter() && part[0].code < 128
        val year = parts.indexOfFirst { isField(it) && it[0] in "yuUG" }
        if (year >= 0) {
            val fieldAfter = (year + 1 until parts.size).any { isField(parts[it]) }
            parts.removeAt(year)
            // Drop the separator that tied the year to its neighbour.
            if (fieldAfter) {
                while (year < parts.size && !isField(parts[year])) parts.removeAt(year)
            } else {
                while (parts.isNotEmpty() && !isField(parts.last())) parts.removeAt(parts.lastIndex)
            }
        }
        parts.joinToString("") { if (it == "MMMM" || it == "LLLL") it.take(3) else it }.trim().also { DateTimeFormatter.ofPattern(it, locale) }
    }.getOrDefault("MMM d")
}

data class CribbageMinuteResult(
    val dayKey: String,
    val shortDate: String,
    val completedAt: Long,
    val answers: List<Boolean>,
    val correctByCategory: Map<String, Int>,
    val totalByCategory: Map<String, Int>,
) {
    val score: Int get() = answers.count { it }
    val total: Int get() = answers.size

    fun correct(category: CribbageMinuteCategory) = correctByCategory[category.raw] ?: 0
    fun total(category: CribbageMinuteCategory) = totalByCategory[category.raw] ?: 0

    /**
     * The day in the reader's own order ("Jun 5", "5 Jun", "5. Juni"). The
     * stored `shortDate` is month first for everyone and stays only so saved
     * results keep decoding.
     */
    fun dateLabel(locale: Locale = Locale.getDefault()): String {
        val day = runCatching { LocalDate.parse(dayKey) }.getOrNull() ?: return shortDate
        return DateTimeFormatter.ofPattern(DayLabel.pattern(locale), locale).format(day)
    }

    fun shareText(locale: Locale = Locale.getDefault()): String {
        val grid = answers.joinToString("") { if (it) "🟩" else "⬜️" }
        return "Cribbage Minute ${dateLabel(locale)}: $score/$total\n$grid\nCan you beat me? ${StoreLinks.PLAY_LISTING_URL}"
    }

    fun toJson(): JSONObject = JSONObject().apply {
        put("dayKey", dayKey)
        put("shortDate", shortDate)
        put("completedAt", completedAt)
        put("answers", JSONArray(answers))
        put("correctByCategory", JSONObject(correctByCategory as Map<*, *>))
        put("totalByCategory", JSONObject(totalByCategory as Map<*, *>))
    }

    companion object {
        fun fromJson(json: JSONObject): CribbageMinuteResult {
            val answers = json.getJSONArray("answers")
            fun counts(key: String): Map<String, Int> {
                val obj = json.getJSONObject(key)
                return obj.keys().asSequence().associateWith { obj.getInt(it) }
            }
            return CribbageMinuteResult(
                dayKey = json.getString("dayKey"),
                shortDate = json.getString("shortDate"),
                completedAt = json.getLong("completedAt"),
                answers = (0 until answers.length()).map { answers.getBoolean(it) },
                correctByCategory = counts("correctByCategory"),
                totalByCategory = counts("totalByCategory"),
            )
        }
    }
}

class CribbageMinuteStore(private val defaults: KeyValueStore, private val clock: AppClock) {
    var results by mutableStateOf(load())
        private set

    fun result(day: LocalDate): CribbageMinuteResult? = results[CribbageMinuteContent.key(day)]

    /** Only the first attempt on a day counts. `at` is when the run began, which decides its week. */
    fun record(challenge: CribbageMinuteChallenge, answers: List<Boolean>, at: Long = clock.millis()): CribbageMinuteResult {
        results[challenge.dayKey]?.let { return it }
        val correct = mutableMapOf<String, Int>()
        val total = mutableMapOf<String, Int>()
        challenge.questions.zip(answers).forEach { (question, right) ->
            total[question.category.raw] = (total[question.category.raw] ?: 0) + 1
            if (right) correct[question.category.raw] = (correct[question.category.raw] ?: 0) + 1
        }
        val result = CribbageMinuteResult(challenge.dayKey, challenge.shortDate, at, answers, correct, total)
        results = results + (challenge.dayKey to result)
        persist()
        return result
    }

    fun completedThisWeek(today: LocalDate = clock.today()): Int {
        val fields = WeekFields.of(Locale.getDefault())
        val start = today.with(fields.dayOfWeek(), 1)
        val end = start.plusDays(7)
        return results.values.count {
            val day = Instant.ofEpochMilli(it.completedAt).atZone(clock.zone).toLocalDate()
            !day.isBefore(start) && day.isBefore(end)
        }
    }

    fun archiveDates(count: Int = 30, today: LocalDate = clock.today()): List<LocalDate> = (1..count).map { today.minusDays(it.toLong()) }

    fun resetAll() {
        results = emptyMap()
        defaults.remove(KEY)
    }

    private fun persist() {
        val json = JSONObject()
        results.forEach { (key, value) -> json.put(key, value.toJson()) }
        defaults.putString(KEY, json.toString())
    }

    private fun load(): Map<String, CribbageMinuteResult> {
        val raw = defaults.getString(KEY) ?: return emptyMap()
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return emptyMap()
        return json.keys().asSequence().associateWith { CribbageMinuteResult.fromJson(json.getJSONObject(it)) }
    }

    private companion object {
        const val KEY = "cribbageMinute.results"
    }
}

/**
 * The post-update notes, once. A fresh install never sees them: onboarding
 * marks the running version as the baseline.
 */
class WhatsNewTracker(private val defaults: KeyValueStore, val currentVersion: String) {
    val currentRelease: WhatsNewRelease?
        get() = CribbageContent.library.whatsNew.firstOrNull { it.version == currentVersion }

    fun shouldPresent(hasOnboarded: Boolean): Boolean {
        if (!hasOnboarded || currentRelease == null) return false
        return (defaults.getString(KEY) ?: "") != currentVersion
    }

    fun markSeen() = defaults.putString(KEY, currentVersion)

    fun markCurrentAsBaseline() = defaults.putString(KEY, currentVersion)

    private companion object {
        const val KEY = "whatsnew.lastSeenVersion"
    }
}
