package com.jackwallner.cribbage.content

import com.jackwallner.cribbage.model.HandCategory
import com.jackwallner.cribbage.model.HandScoring
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.RandomSource
import com.jackwallner.cribbage.model.StableSeededGenerator
import com.jackwallner.cribbage.model.Suit
import com.jackwallner.cribbage.model.SystemRandomSource
import com.jackwallner.cribbage.model.nextInt
import com.jackwallner.cribbage.model.racked
import com.jackwallner.cribbage.model.randomElement
import com.jackwallner.cribbage.model.shuffledSwift

/**
 * Port of iOS `HandGenerator`: original five-card hands that foreground one
 * scoring shape. Of the three categories offered, exactly one is present.
 * Every draw comes from the RandomSource in the same order as the Swift
 * original, so a seeded batch deals the same cards as iOS
 * (`GeneratorParityTest`).
 */
object HandGenerator {
    val generatableCategories: List<HandCategory> = HandCategory.entries

    fun presentCategories(cards: List<PlayingCard>): List<HandCategory> = HandCategory.entries.filter { it.isPresent(cards) }

    data class GeneratedHand(
        val tiles: List<PlayingCard>,
        val answer: HandCategory,
        val choices: List<HandCategory>,
        val explanation: String,
    )

    private fun fill(cards: List<PlayingCard>, count: Int, blocked: Set<Int>, source: RandomSource): List<PlayingCard> {
        val result = cards.toMutableList()
        val pool = PlayingCard.standardDeck.shuffledSwift(source).toMutableList()
        while (result.size < count && pool.isNotEmpty()) {
            val next = pool.removeAt(pool.size - 1)
            if (next in result || next.rankValue in blocked) continue
            result += next
        }
        return result
    }

    /** The seed ranks plus the ranks on either side, so filler cannot extend a run or pair. */
    private fun neighbors(ranks: List<Int>): Set<Int> = buildSet {
        for (rank in ranks) {
            add(rank)
            add(rank - 1)
            add(rank + 1)
        }
    }

    private fun deal(target: HandCategory, source: RandomSource): List<PlayingCard> = when (target) {
        HandCategory.FLUSHES -> {
            val suit = Suit.entries.randomElement(source) ?: Suit.HEARTS
            val ranks = (1..13).toList().shuffledSwift(source).take(4)
            val suited = ranks.map { PlayingCard.Standard(it, suit) }
            val others = Suit.entries.filter { it != suit }
            val oddRank = (1..13).filter { it !in ranks }.randomElement(source) ?: 1
            val odd = PlayingCard.Standard(oddRank, others.randomElement(source) ?: Suit.CLUBS)
            suited + odd
        }
        HandCategory.RUNS -> {
            val length = listOf(3, 3, 4, 5).randomElement(source) ?: 3
            val start = source.nextInt(1..(14 - length))
            val sequence = (start until start + length).toList()
            val run = sequence.map { PlayingCard.Standard(it, Suit.entries.randomElement(source) ?: Suit.CLUBS) }
            fill(run, 5, neighbors(sequence), source)
        }
        HandCategory.PAIRS -> {
            val rank = source.nextInt(1..13)
            val copies = listOf(2, 2, 3).randomElement(source) ?: 2
            val pair = Suit.entries.shuffledSwift(source).take(copies).map { PlayingCard.Standard(rank, it) }
            fill(pair, 5, neighbors(listOf(rank)), source)
        }
        HandCategory.NOBS -> {
            val jack = PlayingCard.Standard(11, Suit.entries.randomElement(source) ?: Suit.HEARTS)
            fill(listOf(jack), 5, neighbors(listOf(11)), source)
        }
        HandCategory.FIFTEENS -> {
            val anchor = listOf(2, 5, 6, 7, 9).randomElement(source) ?: 5
            val partner = minOf(15 - anchor, 10)
            if (partner == anchor) {
                fill(emptyList(), 5, emptySet(), source)
            } else {
                val first = PlayingCard.Standard(anchor, Suit.entries.randomElement(source) ?: Suit.CLUBS)
                val second = PlayingCard.Standard(partner, Suit.entries.randomElement(source) ?: Suit.DIAMONDS)
                fill(listOf(first, second), 5, neighbors(listOf(anchor, partner)), source)
            }
        }
    }

    fun hand(target: HandCategory, attempts: Int = 200, source: RandomSource = SystemRandomSource): GeneratedHand? {
        repeat(attempts) {
            val cards = deal(target, source)
            if (cards.size != 5 || cards.toSet().size != 5) return@repeat
            val present = presentCategories(cards)
            if (target !in present) return@repeat
            val distractors = HandCategory.entries.filter { it !in present }.shuffledSwift(source).take(2)
            if (distractors.size != 2) return@repeat
            return GeneratedHand(
                tiles = cards.racked,
                answer = target,
                choices = (listOf(target) + distractors).shuffledSwift(source),
                explanation = explain(cards, target),
            )
        }
        return null
    }

    fun batch(count: Int): List<GeneratedHand> = batch(count, SystemRandomSource)

    /** A reproducible batch: the same seed deals the same hands as iOS on every device. */
    fun batch(count: Int, seed: String): List<GeneratedHand> = batch(count, StableSeededGenerator(seed))

    private fun batch(count: Int, source: RandomSource): List<GeneratedHand> {
        val targets = mutableListOf<HandCategory>()
        while (targets.size < count) targets += generatableCategories.shuffledSwift(source)
        return targets.take(count).mapNotNull { hand(it, source = source) }.shuffledSwift(source)
    }

    fun explain(cards: List<PlayingCard>, answer: HandCategory): String = when (answer) {
        HandCategory.FLUSHES ->
            if (HandScoring.longestSuitCount(cards) == 5) "All five cards share a suit, so the flush alone is 5 points."
            else "Four cards share a suit for a 4-point hand flush, and a matching cut would make it 5."
        HandCategory.RUNS -> "The ranks build a run worth ${HandScoring.runs(cards)} points. Suits never matter for a run, and aces stay low."
        HandCategory.PAIRS -> "Matching ranks are worth ${HandScoring.pairs(cards)} points here. Three of a rank is three separate pairs, not one score."
        HandCategory.FIFTEENS -> "Combinations totaling fifteen are worth ${HandScoring.fifteens(cards)} points here. Court cards count 10 and the ace counts 1."
        HandCategory.NOBS -> "The hand holds a jack, so his nobs is live: one point if the cut comes up in that jack's suit."
    }
}
