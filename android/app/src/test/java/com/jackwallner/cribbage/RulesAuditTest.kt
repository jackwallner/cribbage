package com.jackwallner.cribbage

import com.jackwallner.cribbage.content.DrillLibrary
import com.jackwallner.cribbage.model.DrillKind
import com.jackwallner.cribbage.model.HandScoring
import com.jackwallner.cribbage.model.HandCategory
import com.jackwallner.cribbage.model.PeggingRules
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.Suit
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RulesAuditTest {
    private fun card(code: String): PlayingCard {
        val rank = mapOf("A" to 1, "J" to 11, "Q" to 12, "K" to 13)[code.drop(1)] ?: code.drop(1).toInt()
        val suit = mapOf('C' to Suit.CLUBS, 'D' to Suit.DIAMONDS, 'H' to Suit.HEARTS, 'S' to Suit.SPADES).getValue(code.first())
        return PlayingCard.Standard(rank, suit)
    }
    private fun reference() = JSONObject(javaClass.getResourceAsStream("/rules-reference.json")!!.bufferedReader().readText())

    @Test fun authoritativeHandCounts() {
        for (row in reference().getJSONArray("hands").objects()) {
            val hand = row.getJSONArray("hand").strings().map(::card)
            val starter = if (row.isNull("starter")) null else card(row.getString("starter"))
            val crib = row.getBoolean("isCrib")
            val all = hand + listOfNotNull(starter)
            val expected = row.getJSONArray("components").let { a -> (0 until a.length()).map(a::getInt) }
            val actual = listOf(HandScoring.fifteens(all), HandScoring.pairs(all), HandScoring.runs(all),
                HandScoring.flush(hand, starter, crib), HandScoring.nobs(hand, starter))
            assertEquals(row.getString("id"), expected, actual)
            assertEquals(expected.sum(), HandScoring.score(hand, starter, crib))
        }
        for (count in listOf(0, 1, 2, 3, 5)) assertEquals(0, HandScoring.flush((1..count).map { PlayingCard.h(it) }, PlayingCard.h(9), false))
    }

    @Test fun peggingAndLegalGo() {
        for (row in reference().getJSONArray("pegging").objects()) {
            val a = row.getJSONArray("ranks")
            val cards = (0 until a.length()).map { PlayingCard.Standard(a.getInt(it), Suit.entries[it % 4]) }
            assertEquals(row.toString(), row.getInt("points"), PeggingRules.points(cards))
        }
        for ((total, ranks, legal) in listOf(Triple(27, listOf(4, 8), listOf(4)), Triple(30, listOf(1, 2), listOf(1)),
            Triple(31, listOf(1, 2), emptyList()), Triple(22, listOf(10, 9), listOf(9)))) {
            assertEquals(legal, PeggingRules.legal(ranks.map { PlayingCard.c(it) }, total).map { it.rankValue })
        }
        for ((total, points) in listOf(15 to 1, 30 to 1, 31 to 0)) assertEquals(points, PeggingRules.lastCard(total))
        for (rank in 1..13) assertEquals(if (rank == 11) 2 else 0, PeggingRules.heels(PlayingCard.c(rank)))
    }

    @Test fun mugginsExceptions() {
        for (kind in PeggingRules.ScoreKind.entries) {
            val eligible = kind in listOf(PeggingRules.ScoreKind.PLAY, PeggingRules.ScoreKind.HAND, PeggingRules.ScoreKind.CRIB)
            assertEquals(0, PeggingRules.muggins(8, 6, false, kind))
            assertEquals(if (eligible) 2 else 0, PeggingRules.muggins(8, 6, true, kind))
            assertEquals(0, PeggingRules.muggins(6, 8, true, kind))
        }
    }

    @Test fun cribExpectationAgainstEveryPhysicalCompletion() {
        for (codes in listOf(listOf("HJ", "H5", "C2", "D4", "S8", "CK"), listOf("H2", "H6", "H9", "HQ", "C5", "D5"))) {
            val deal = codes.map(::card)
            val discard = deal.take(2)
            val live = PlayingCard.standardDeck.filter { it !in deal }
            var sum = 0L
            var count = 0
            for (i in live.indices) for (j in i + 1 until live.size) for (k in live.indices) {
                if (k == i || k == j) continue
                sum += HandScoring.score(discard + listOf(live[i], live[j]), live[k], true)
                count++
            }
            assertEquals(45540, count)
            assertEquals(sum.toDouble() / count, HandScoring.averageCrib(discard, deal), 1e-10)
        }
    }

    @Test fun teachingUsesDealerCribAndAccMuggins() {
        val drills = DrillLibrary.rooms.flatMap { it.drills }
        val cards = drills.flatMap { (it.kind as? DrillKind.Flashcards)?.cards.orEmpty() }
        val dealer = cards.first { it.id == "decision-dealer-crib" }
        assertEquals("Build hand plus crib", dealer.choice!!.options[dealer.choice!!.answerIndex])
        assertTrue(dealer.backBody.contains("pone does not score your crib"))
        val quiz = drills.flatMap { (it.kind as? DrillKind.Quiz)?.questions.orEmpty() }
        assertTrue(quiz.first { it.id == "more-advanced-muggins" }.explanation.contains("starter jack"))
    }

    @Test fun equivalentDiscardsReceiveFullCredit() {
        val scenarios = DrillLibrary.rooms.flatMap { it.drills }.flatMap { (it.kind as? DrillKind.Discard)?.scenarios.orEmpty() }
        for ((id, codes) in listOf("master-discard-4" to listOf("C8", "DK"), "master-discard-6" to listOf("C10", "DQ"))) {
            val scenario = scenarios.first { it.id == id }
            assertTrue(codes.map(::card).toSet() != scenario.recommendedDiscard.toSet())
            assertEquals(2, HandScoring.discardMatches(codes.map(::card), scenario))
            assertEquals(2, HandScoring.discardMatches(scenario.recommendedDiscard, scenario))
            assertEquals(0, HandScoring.discardMatches(listOf(card("CA"), card("C2")), scenario))
        }
    }

    @Test fun authoredKeepArithmeticAndConditionalPatterns() {
        val scenarios = DrillLibrary.rooms.flatMap { it.drills }.flatMap { (it.kind as? DrillKind.Discard)?.scenarios.orEmpty() }.associateBy { it.id }
        for (r in reference().getJSONArray("keeps").objects()) {
            val s = scenarios.getValue(r.getString("id"))
            assertEquals(s.id, r.getInt("score"), HandScoring.score(s.deal.filter { it !in s.recommendedDiscard }))
        }
        val s = scenarios.getValue("discard-scenario-2")
        assertEquals(13, s.recommendedDiscard.sumOf { it.cribbageValue })
        assertEquals(0, HandScoring.fifteens(s.recommendedDiscard))
        assertTrue(s.reasoning.contains("total 13"))
        assertEquals("Nobs potential", HandCategory.NOBS.displayName)
        assertEquals("Flush potential", HandCategory.FLUSHES.displayName)
        assertTrue(HandCategory.patternPrompt.contains("No starter"))
        assertTrue(HandCategory.NOBS.isPresent(listOf("HJ", "C2", "D6", "S8", "CK").map(::card)))
        assertEquals(0, HandScoring.nobs(listOf("HJ", "C2", "D6", "S8").map(::card), card("C3")))
    }
}
