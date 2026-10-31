package com.jackwallner.cribbage

import com.jackwallner.cribbage.content.CribbageMinuteCategory
import com.jackwallner.cribbage.content.CribbageMinuteContent
import com.jackwallner.cribbage.content.DrillLibrary
import com.jackwallner.cribbage.content.EndlessPractice
import com.jackwallner.cribbage.content.HandGenerator
import com.jackwallner.cribbage.content.PracticeSkill
import com.jackwallner.cribbage.content.QuickItem
import com.jackwallner.cribbage.content.SessionBuilder
import com.jackwallner.cribbage.model.ChoiceShuffle
import com.jackwallner.cribbage.model.DrillKind
import com.jackwallner.cribbage.model.HandCategory
import com.jackwallner.cribbage.model.HandCategory.FIFTEENS
import com.jackwallner.cribbage.model.HandCategory.FLUSHES
import com.jackwallner.cribbage.model.HandCategory.NOBS
import com.jackwallner.cribbage.model.HandCategory.PAIRS
import com.jackwallner.cribbage.model.HandCategory.RUNS
import com.jackwallner.cribbage.model.HandScoring
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.PlayingCard.Companion.c
import com.jackwallner.cribbage.model.PlayingCard.Companion.d
import com.jackwallner.cribbage.model.PlayingCard.Companion.h
import com.jackwallner.cribbage.model.PlayingCard.Companion.s
import com.jackwallner.cribbage.model.StableSeededGenerator
import java.time.LocalDate
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Holds the Kotlin generators to the iOS output, plus ports of iOS
 * `HandGeneratorTests` and `CribbageMinuteContentTests`. The shared daily
 * challenge has to deal the same cards on both platforms.
 */
class GeneratorParityTest {
    private val parity = ParityFixtures.json

    private fun assertItem(label: String, expected: JSONObject, actual: QuickItem) {
        assertEquals(label, expected.getString("id"), actual.id)
        assertEquals(label, expected.getString("prompt"), actual.prompt)
        assertEquals(label, expected.getJSONArray("tiles").strings(), codes(actual.tiles))
        assertEquals(label, expected.getJSONArray("choices").strings(), actual.choices)
        assertEquals(label, expected.getInt("answerIndex"), actual.answerIndex)
        assertEquals(label, expected.getString("explanation"), actual.explanation)
        assertEquals(label, expected.getString("sourceLabel"), actual.sourceLabel)
        assertEquals(label, expected.getString("roomID"), actual.roomID)
        assertEquals(label, expected.getString("trackingID"), actual.trackingID)
        assertEquals(label, expected.getBoolean("isReviewable"), actual.isReviewable)
    }

    @Test
    fun seededStreamMatchesSwift() {
        val streams = parity.getJSONObject("streams")
        for (seed in streams.keys()) {
            val generator = StableSeededGenerator(seed)
            assertEquals("seed '$seed'", streams.getJSONArray(seed).strings(), (0 until 8).map { generator.next().toString() })
        }
    }

    @Test
    fun permutationsMatchSwift() {
        val permutations = parity.getJSONObject("permutations")
        for (key in permutations.keys()) {
            val (seed, count) = key.split("|")
            assertEquals(key, permutations.getJSONArray(key).ints(), ChoiceShuffle.permutation(count.toInt(), seed))
        }
    }

    @Test
    fun handBatchesMatchSwift() {
        val hands = parity.getJSONObject("hands")
        for (seed in hands.keys()) {
            val expected = hands.getJSONArray(seed).objects()
            val actual = HandGenerator.batch(7, seed)
            assertEquals(seed, expected.size, actual.size)
            expected.zip(actual).forEachIndexed { index, (json, hand) ->
                val label = "$seed #$index"
                assertEquals(label, json.getJSONArray("tiles").strings(), codes(hand.tiles))
                assertEquals(label, json.getString("answer"), hand.answer.raw)
                assertEquals(label, json.getJSONArray("choices").strings(), hand.choices.map { it.raw })
                assertEquals(label, json.getString("explanation"), hand.explanation)
            }
        }
    }

    @Test
    fun cribbageMinuteMatchesSwift() {
        val minutes = parity.getJSONObject("minutes")
        for (day in minutes.keys()) {
            val expected = minutes.getJSONObject(day)
            val challenge = CribbageMinuteContent.challenge(LocalDate.parse(day))
            assertEquals(day, expected.getString("shortDate"), challenge.shortDate)
            val questions = expected.getJSONArray("questions").objects()
            assertEquals(day, questions.size, challenge.questions.size)
            questions.zip(challenge.questions).forEachIndexed { index, (json, question) ->
                assertEquals("$day #$index", json.getString("category"), question.category.raw)
                assertItem("$day #$index", json.getJSONObject("item"), question.item)
            }
        }
    }

    @Test
    fun preparedChoicePoolMatchesSwift() {
        val expected = parity.getJSONArray("memberPool").objects()
        val actual = DrillLibrary.rooms.flatMap { SessionBuilder.choiceItems(it.id, includePro = true) }.map(SessionBuilder::prepared)
        assertEquals(expected.size, actual.size)
        expected.zip(actual).forEach { (json, item) -> assertItem(item.id, json, item) }
    }

    // MARK: - iOS HandGeneratorTests

    @Test
    fun readsEachShape() {
        val flush = listOf(h(2), h(5), h(8), h(11), h(13))
        assertTrue(FLUSHES.isPresent(flush))
        assertFalse(PAIRS.isPresent(flush))
        val run = listOf(c(3), d(4), h(5), s(6), c(7))
        assertTrue(RUNS.isPresent(run))
        assertFalse(FLUSHES.isPresent(run))
        assertFalse(PAIRS.isPresent(run))
        val pairs = listOf(c(8), d(8), h(2), s(6), c(13))
        assertTrue(PAIRS.isPresent(pairs))
        assertFalse(RUNS.isPresent(pairs))
        val fifteens = listOf(c(5), d(10), h(1), s(2), c(7))
        assertTrue(FIFTEENS.isPresent(fifteens))
        assertFalse(NOBS.isPresent(fifteens))
        assertTrue(NOBS.isPresent(listOf(h(11), c(2), d(6), s(8), c(13))))
        assertFalse(NOBS.isPresent(listOf(h(12), c(2), d(6), s(8), c(13))))
    }

    @Test
    fun generatedHandsAreLegalAndUnambiguous() {
        for (target in HandGenerator.generatableCategories) {
            repeat(40) {
                val hand = HandGenerator.hand(target)
                assertNotNull("Could not deal ${target.raw}", hand)
                hand!!
                val shown = codes(hand.tiles).toString()
                assertEquals(shown, 5, hand.tiles.size)
                assertEquals(shown, 5, hand.tiles.toSet().size)
                assertEquals(target, hand.answer)
                assertEquals(shown, 3, hand.choices.size)
                assertEquals(shown, 3, hand.choices.toSet().size)
                assertEquals(shown, listOf(target), hand.choices.filter { it.isPresent(hand.tiles) })
                assertTrue(hand.explanation.isNotEmpty() && "—" !in hand.explanation)
                assertTrue(hand.tiles.all { it is PlayingCard.Standard && it.rank in 1..13 })
                assertTrue(hand.tiles.groupingBy { it.rankValue }.eachCount().values.max() <= 4)
            }
        }
    }

    @Test
    fun batchCoversEveryShape() {
        val hands = HandGenerator.batch(60)
        assertTrue(hands.size > 40)
        assertEquals(HandCategory.entries.toSet(), hands.map { it.answer }.toSet())
    }

    @Test
    fun endlessItemsAreWellFormed() {
        for (skill in PracticeSkill.entries) {
            val items = EndlessPractice.items(skill, 12)
            assertEquals(12, items.size)
            for (item in items) {
                assertTrue(item.id.startsWith(skill.itemPrefix))
                assertEquals(skill, PracticeSkill.skill(item.id))
                assertTrue(item.choices.size >= 3)
                assertTrue(item.answerIndex in item.choices.indices)
                assertEquals(item.choices.size, item.choices.toSet().size)
                assertTrue(item.explanation.isNotEmpty())
                assertNotNull(DrillLibrary.room(item.roomID))
            }
        }
    }

    @Test
    fun peggingItemsDescribeLegalTotals() {
        for (item in EndlessPractice.items(PracticeSkill.PEGGING, 40)) {
            val card = item.tiles.single() as PlayingCard.Standard
            assertTrue(card.rank in 1..13)
            assertTrue("running total" in item.prompt)
            val total = Regex("running total is (\\d+)").find(item.prompt)!!.groupValues[1].toInt()
            assertEquals(if (total + card.cribbageValue <= 31) 0 else 1, item.answerIndex)
        }
    }

    @Test
    fun mixedItemsDrawFromEverySkill() {
        val items = EndlessPractice.mixedItems(40)
        assertEquals(40, items.size)
        assertEquals(PracticeSkill.entries.toSet(), items.mapNotNull { PracticeSkill.skill(it.id) }.toSet())
    }

    // MARK: - iOS CribbageMinuteContentTests

    @Test
    fun challengeIsStableAndHasTheFiveQuestionMix() {
        val day = LocalDate.of(2026, 8, 9)
        val first = CribbageMinuteContent.challenge(day)
        val second = CribbageMinuteContent.challenge(day)
        assertEquals("2026-08-09", first.dayKey)
        assertEquals(first.items, second.items)
        val counts = first.questions.groupingBy { it.category }.eachCount()
        assertEquals(CribbageMinuteContent.QUESTION_COUNT, first.questions.size)
        assertEquals(2, counts[CribbageMinuteCategory.HAND_READING])
        assertEquals(1, counts[CribbageMinuteCategory.DISCARDING])
        assertEquals(2, counts[CribbageMinuteCategory.PEGGING])
        for (question in first.questions) {
            val item = question.item
            assertTrue(item.choices.size >= 2)
            assertTrue(item.answerIndex in item.choices.indices)
            assertTrue(item.explanation.isNotEmpty() && "—" !in item.explanation)
        }
        for (question in first.questions.filter { it.category == CribbageMinuteCategory.HAND_READING }) {
            assertFalse(question.item.isReviewable)
            assertEquals(PracticeSkill.HAND_READING.raw, question.item.trackingID)
        }
    }

    /**
     * The drill gives an equally good pair full credit (`discardMatches`), so the daily's multiple
     * choice must never list one as a wrong answer. Two Master Tables deals have such a twin: swap
     * the spade for the club and the hand and the crib are worth exactly the same.
     */
    @Test
    fun dailyDiscardNeverOffersAnInterchangeablePairAsWrong() {
        val scenarios = DrillLibrary.rooms.flatMap { it.drills }.flatMap { (it.kind as? DrillKind.Discard)?.scenarios.orEmpty() }
        val twins = listOf("master-discard-4" to listOf(c(8), d(13)), "master-discard-6" to listOf(c(10), d(12))).map { (id, cards) ->
            val scenario = scenarios.first { it.id == id }
            assertEquals("$id lost its twin", 2, HandScoring.discardMatches(cards, scenario))
            Triple(id, scenario, cards.joinToString(", ") { it.spokenName })
        }
        var checked = 0
        for (offset in 0 until 365) {
            val challenge = CribbageMinuteContent.challenge(LocalDate.of(2026, 11, 1).plusDays(offset.toLong()))
            val item = challenge.questions.firstOrNull { it.category == CribbageMinuteCategory.DISCARDING }?.item ?: continue
            for ((id, scenario, label) in twins) {
                if (item.tiles != scenario.deal) continue
                checked += 1
                assertEquals(challenge.dayKey, 4, item.choices.size)
                assertFalse("${challenge.dayKey} lists $label as a wrong answer to $id", label in item.choices)
            }
        }
        assertTrue("the sweep should reach both deals many times", checked > 20)
    }

    /** A day that fails to deal fails for every player at once, so sweep five years of day keys. */
    @Test
    fun everyDaySeedDealsTheFullQuestionSet() {
        var day = LocalDate.of(2026, 1, 1)
        var checked = 0
        while (day.isBefore(LocalDate.of(2031, 1, 1))) {
            val key = CribbageMinuteContent.key(day)
            assertEquals(key, 2, HandGenerator.batch(2, "cribbage-minute-$key-hands").size)
            checked += 1
            day = day.plusDays(1)
        }
        assertTrue(checked > 1800)
    }
}
