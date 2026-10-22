package com.jackwallner.cribbage.content

import com.jackwallner.cribbage.model.HandCategory
import com.jackwallner.cribbage.model.ChoiceShuffle
import com.jackwallner.cribbage.model.DiscardScenario
import com.jackwallner.cribbage.model.Drill
import com.jackwallner.cribbage.model.DrillKind
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.StableSeededGenerator
import java.time.LocalDate
import java.util.Locale

enum class CribbageMinuteCategory(val raw: String, val title: String, val icon: String) {
    HAND_READING("handReading", "Hand Reading", "rectangle.on.rectangle.angled"),
    DISCARDING("discarding", "The Discard", "arrow.down.circle.fill"),
    PEGGING("pegging", "Pegging", "figure.walk.motion"),
}

data class CribbageMinuteQuestion(val category: CribbageMinuteCategory, val item: QuickItem)

data class CribbageMinuteChallenge(
    val day: LocalDate,
    val dayKey: String,
    val shortDate: String,
    val questions: List<CribbageMinuteQuestion>,
) {
    val items: List<QuickItem> get() = questions.map { it.item }
}

/**
 * One shared five-question set per calendar date, identical to the iOS set for
 * the same date: two generated hand reads, one discard decision and two
 * pegging calls, all picked with the same seeds as iOS.
 */
object CribbageMinuteContent {
    const val QUESTION_COUNT = 5

    val drill = Drill("cribbage-minute", "Cribbage Minute", "Today's shared five-question challenge", DrillKind.Quiz(emptyList()), isPlus = true)

    fun key(day: LocalDate): String = String.format(Locale.US, "%04d-%02d-%02d", day.year, day.monthValue, day.dayOfMonth)

    fun challenge(day: LocalDate = LocalDate.now()): CribbageMinuteChallenge {
        val dayKey = key(day)
        val generated = generatedQuestions(dayKey)
        val middle = listOfNotNull(discardQuestion(dayKey))
        val last = roomQuestions(dayKey, "pegging-room", CribbageMinuteCategory.PEGGING, 2)
        // Interleaved so the run does not read as three separate quizzes.
        val questions = buildList {
            generated.getOrNull(0)?.let(::add)
            addAll(middle)
            last.getOrNull(0)?.let(::add)
            generated.getOrNull(1)?.let(::add)
            last.getOrNull(1)?.let(::add)
        }
        val shortDate = String.format(Locale.US, "%02d/%02d", day.monthValue, day.dayOfMonth)
        return CribbageMinuteChallenge(day, dayKey, shortDate, questions)
    }

    private fun generatedQuestions(dayKey: String): List<CribbageMinuteQuestion> =
        HandGenerator.batch(2, "cribbage-minute-$dayKey-hands").mapIndexed { index, hand ->
            val item = QuickItem(
                id = PracticeSkill.HAND_READING.itemPrefix + "minute-$dayKey-$index",
                prompt = HandCategory.patternPrompt,
                tiles = hand.tiles,
                choices = hand.choices.map { it.displayName },
                answerIndex = hand.choices.indexOf(hand.answer).coerceAtLeast(0),
                explanation = hand.explanation,
                sourceLabel = "Cribbage Minute: Hand Read",
                roomID = PracticeSkill.HAND_READING.roomID,
                trackingID = PracticeSkill.HAND_READING.raw,
                isReviewable = false,
            )
            CribbageMinuteQuestion(CribbageMinuteCategory.HAND_READING, SessionBuilder.prepared(item))
        }

    /** Built straight from the authored scenarios: the quick-session pool leaves discards out. */
    private fun discardQuestion(dayKey: String): CribbageMinuteQuestion? {
        val scenarios = DrillLibrary.rooms.flatMap { room ->
            room.drills.flatMap { (it.kind as? DrillKind.Discard)?.scenarios ?: emptyList() }
        }
        if (scenarios.isEmpty()) return null
        val generator = StableSeededGenerator("cribbage-minute-$dayKey-discard")
        val scenario = scenarios[(generator.next() % scenarios.size.toULong()).toInt()]
        val answer = label(scenario.recommendedDiscard)
        val distractors = distractorLabels(scenario, dayKey, answer)
        if (distractors.size < 2) return null
        val item = QuickItem(
            id = "cribbage-minute-discard-$dayKey",
            prompt = "${scenario.situation} Which two cards do you throw?",
            tiles = scenario.deal,
            choices = listOf(answer) + distractors,
            answerIndex = 0,
            explanation = scenario.reasoning,
            sourceLabel = "Cribbage Minute: The Discard",
            roomID = "discard-room",
            trackingID = "cribbage-minute-discard",
            isReviewable = false,
        )
        return CribbageMinuteQuestion(CribbageMinuteCategory.DISCARDING, SessionBuilder.prepared(item))
    }

    /** Every other pair from the same deal, so a wrong answer is a real alternative. */
    private fun distractorLabels(scenario: DiscardScenario, dayKey: String, answer: String): List<String> {
        val labels = mutableSetOf<String>()
        for (first in 0 until maxOf(0, scenario.deal.size - 1)) {
            for (second in first + 1 until scenario.deal.size) {
                labels += label(listOf(scenario.deal[first], scenario.deal[second]))
            }
        }
        labels -= answer
        val sorted = labels.sorted()
        val order = ChoiceShuffle.permutation(sorted.size, "cribbage-minute-$dayKey-discard-choices")
        return order.take(3).map { sorted[it] }
    }

    private fun label(cards: List<PlayingCard>): String = cards.joinToString(", ") { it.spokenName }

    /** Authored questions from one room, picked by a permutation of the day key. */
    private fun roomQuestions(dayKey: String, roomID: String, category: CribbageMinuteCategory, count: Int): List<CribbageMinuteQuestion> {
        val pool = SessionBuilder.choiceItems(roomID, includePro = true)
        if (pool.isEmpty()) return emptyList()
        val indices = ChoiceShuffle.permutation(pool.size, "cribbage-minute-$dayKey-$roomID")
        return indices.take(count).map { CribbageMinuteQuestion(category, SessionBuilder.prepared(pool[it])) }
    }
}
