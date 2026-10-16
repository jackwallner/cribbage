package com.jackwallner.cribbage

import com.jackwallner.cribbage.model.HandScoring
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.PlayingCard.Companion.c
import com.jackwallner.cribbage.model.PlayingCard.Companion.d
import com.jackwallner.cribbage.model.PlayingCard.Companion.h
import com.jackwallner.cribbage.model.PlayingCard.Companion.s
import com.jackwallner.cribbage.model.racked
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Ports of iOS `HandScoringTests`, plus every scoring result iOS recorded in the parity export. */
class ScoringParityTest {
    @Test
    fun perfectTwentyNine() = assertEquals(29, HandScoring.score(listOf(c(5), d(5), h(5), s(11)), s(5)))

    @Test
    fun twentyEightWhenTheJackMissesTheStarterSuit() = assertEquals(28, HandScoring.score(listOf(c(5), d(5), h(5), h(11)), s(5)))

    @Test
    fun handFlushScoresFourWithoutTheStarter() {
        val hand = listOf(h(2), h(5), h(8), h(11))
        assertEquals(4, HandScoring.flush(hand, null, isCrib = false))
        assertEquals(8, HandScoring.score(hand))
    }

    @Test
    fun cribFlushNeedsAllFiveCards() {
        val crib = listOf(h(2), h(5), h(8), h(11))
        assertEquals(4, HandScoring.score(crib, c(9), isCrib = true))
        assertEquals(10, HandScoring.score(crib, h(9), isCrib = true))
    }

    @Test
    fun fiveCardRunAndItsFifteen() = assertEquals(7, HandScoring.score(listOf(c(1), d(2), h(3), s(4)), c(5)))

    @Test
    fun doubleDoubleRun() {
        val hand = listOf(c(3), d(3), h(4), s(4))
        assertEquals(12, HandScoring.runs(hand + c(5)))
        assertEquals(20, HandScoring.score(hand, c(5)))
    }

    @Test
    fun acesAreLowAndRunsDoNotWrap() {
        val hand = listOf(c(12), d(13), h(1), s(2))
        assertEquals(0, HandScoring.runs(hand))
        assertEquals(0, HandScoring.score(hand))
    }

    @Test
    fun nobsOnlyCountsWhenTheSuitMatches() {
        val hand = listOf(h(11), c(2), d(6), s(8))
        assertEquals(3, HandScoring.score(hand, h(3)))
        assertEquals(2, HandScoring.score(hand, c(3)))
    }

    @Test
    fun fourOfAKindIsSixPairs() {
        val hand = listOf(c(7), d(7), h(7), s(7))
        assertEquals(12, HandScoring.pairs(hand))
        assertEquals(12, HandScoring.score(hand, c(13)))
    }

    @Test
    fun courtCardsAreWorthTenTowardFifteen() {
        for (rank in 10..13) assertEquals(2, HandScoring.fifteens(listOf(c(5), d(rank))))
        assertEquals(0, HandScoring.pairs(listOf(c(10), d(11), h(12), s(13))))
    }

    @Test
    fun doubleRunOfThree() {
        val hand = listOf(c(4), d(4), h(5), s(6))
        assertEquals(6, HandScoring.runs(hand))
        assertEquals(12, HandScoring.score(hand))
    }

    @Test
    fun averageWithCutIgnoresDeadCards() {
        val hand = listOf(c(5), d(5), c(10), d(12))
        val average = HandScoring.averageWithCut(hand, listOf(h(6), s(7)))
        assertTrue(average > HandScoring.score(hand))
        assertTrue(average < 29)
    }

    @Test
    fun deckMatchesIos() {
        assertEquals(52, PlayingCard.standardDeck.size)
        assertEquals(52, PlayingCard.standardDeck.toSet().size)
        assertEquals("C1", PlayingCard.standardDeck.first().code)
        assertEquals("S13", PlayingCard.standardDeck.last().code)
    }

    /** 300 seeded deals scored on iOS: every component and the total must match. */
    @Test
    fun everyRecordedScoreMatchesSwift() {
        val scores = ParityFixtures.json.getJSONArray("scores").objects()
        assertEquals(300, scores.size)
        for (entry in scores) {
            val hand = entry.getJSONArray("hand").cards()
            val starter = PlayingCard.fromCode(entry.getString("starter"))
            val isCrib = entry.getBoolean("isCrib")
            val all = hand + starter
            val label = "${codes(hand)} + ${starter.code}"
            assertEquals(label, entry.getInt("score"), HandScoring.score(hand, starter, isCrib))
            assertEquals(label, entry.getInt("bare"), HandScoring.score(hand))
            assertEquals(label, entry.getInt("fifteens"), HandScoring.fifteens(all))
            assertEquals(label, entry.getInt("pairs"), HandScoring.pairs(all))
            assertEquals(label, entry.getInt("runs"), HandScoring.runs(all))
            assertEquals(label, entry.getInt("flush"), HandScoring.flush(hand, starter, isCrib))
            assertEquals(label, entry.getInt("nobs"), HandScoring.nobs(hand, starter))
        }
    }

    /** Every discard of every authored deal, for both roles, valued exactly as on iOS. */
    @Test
    fun discardValuesMatchSwift() {
        val discards = ParityFixtures.json.getJSONArray("discards").objects()
        val scenarios = com.jackwallner.cribbage.content.DrillLibrary.rooms.flatMap { room ->
            room.drills.flatMap { (it.kind as? com.jackwallner.cribbage.model.DrillKind.Discard)?.scenarios.orEmpty() }
        }.associateBy { it.id }
        assertEquals(scenarios.size * 2, discards.size)
        for (entry in discards) {
            val scenario = scenarios.getValue(entry.getString("id"))
            val isDealer = entry.getBoolean("isDealer")
            val expected = entry.getJSONArray("values").objects().associate {
                it.getJSONArray("discard").strings() to it.getDouble("value")
            }
            val actual = HandScoring.rankedDiscards(scenario.deal, isDealer)
            assertEquals(15, actual.size)
            for (option in actual) {
                val key = codes(option.discard.racked)
                assertEquals("${scenario.id} $key dealer=$isDealer", expected.getValue(key), option.value, 1e-9)
            }
            assertEquals(expected.values.max(), actual.first().value, 1e-9)
        }
    }
}
