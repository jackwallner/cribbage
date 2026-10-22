package com.jackwallner.cribbage.model

/**
 * Standard cribbage scoring for a four-card hand plus an optional starter,
 * ported line for line from iOS `HandScoring`. A hand flush needs four cards
 * of one suit (five with a matching starter), a crib flush needs all five.
 * Aces are low and a run never wraps.
 */
object HandScoring {

    /** 2 points for every distinct combination of cards totaling fifteen. */
    fun fifteens(cards: List<PlayingCard>): Int {
        val values = cards.map { it.cribbageValue }
        if (values.size >= 31) return 0
        var total = 0
        for (mask in 1 until (1 shl values.size)) {
            var sum = 0
            for (index in values.indices) if (mask and (1 shl index) != 0) sum += values[index]
            if (sum == 15) total += 2
        }
        return total
    }

    /** 2 points per pair, counting every distinct pair of matching ranks. */
    fun pairs(cards: List<PlayingCard>): Int =
        cards.groupingBy { it.rankValue }.eachCount().values.sumOf { it * (it - 1) }

    /** The longest run of three or more, multiplied by the ways duplicates form it. */
    fun runs(cards: List<PlayingCard>): Int {
        val counts = cards.groupingBy { it.rankValue }.eachCount()
        val ranks = counts.keys.sorted()
        if (ranks.size < 3) return 0
        for (length in ranks.size downTo 3) {
            var total = 0
            for (start in 0..(ranks.size - length)) {
                val window = ranks.subList(start, start + length)
                if (window[length - 1] - window[0] != length - 1) continue
                total += length * window.fold(1) { acc, rank -> acc * (counts[rank] ?: 0) }
            }
            if (total > 0) return total
        }
        return 0
    }

    /** How many cards share the most common suit in the layout. */
    fun longestSuitCount(cards: List<PlayingCard>): Int =
        cards.mapNotNull { (it as? PlayingCard.Standard)?.suit }.groupingBy { it }.eachCount().values.maxOrNull() ?: 0

    /** A hand flush is 4 for four matching cards, 5 when the starter matches. A crib flush needs all five. */
    fun flush(hand: List<PlayingCard>, starter: PlayingCard?, isCrib: Boolean): Int {
        if (hand.size != 4) return 0
        val suits = mutableSetOf<Suit>()
        for (card in hand) {
            val standard = card as? PlayingCard.Standard ?: return 0
            suits += standard.suit
        }
        if (suits.size != 1) return 0
        val suit = suits.first()
        if ((starter as? PlayingCard.Standard)?.suit == suit) return 5
        return if (isCrib) 0 else 4
    }

    /** One point for a jack in the hand whose suit matches the starter. */
    fun nobs(hand: List<PlayingCard>, starter: PlayingCard?): Int {
        val starterSuit = (starter as? PlayingCard.Standard)?.suit ?: return 0
        return if (hand.any { it is PlayingCard.Standard && it.rank == 11 && it.suit == starterSuit }) 1 else 0
    }

    /** The full count for a hand, with or without the starter card. */
    fun score(hand: List<PlayingCard>, starter: PlayingCard? = null, isCrib: Boolean = false): Int {
        val all = hand + listOfNotNull(starter)
        return fifteens(all) + pairs(all) + runs(all) + flush(hand, starter, isCrib) + nobs(hand, starter)
    }

    /** The average count across every starter still live once the six dealt cards are known. */
    fun averageWithCut(hand: List<PlayingCard>, dead: List<PlayingCard>): Double {
        val excluded = (hand + dead).toSet()
        val live = PlayingCard.standardDeck.filter { it !in excluded }
        if (live.isEmpty()) return 0.0
        return live.sumOf { score(hand, it) }.toDouble() / live.size
    }

    private fun rankOnlyScore(ranks: List<Int>): Int {
        val cards = ranks.map { PlayingCard.Standard(it, Suit.CLUBS) }
        return fifteens(cards) + pairs(cards) + runs(cards)
    }

    /**
     * What a two-card discard is worth once it lands in a crib, averaged over
     * every opponent discard pair and every starter, weighted by live copies.
     * Uniform random discards, including nobs and five-card crib flushes.
     */
    fun averageCrib(discard: List<PlayingCard>, dead: List<PlayingCard>): Double {
        val live = IntArray(14) { 4 }
        val excluded = (dead + discard).toSet()
        for (card in excluded) live[card.rankValue] -= 1
        val thrown = discard.map { it.rankValue }
        var total = 0.0
        var weightSum = 0.0
        for (first in 1..13) {
            if (live[first] <= 0) continue
            for (second in first..13) {
                val pairWeight = if (first == second) {
                    (live[first] * (live[first] - 1)).toDouble() / 2
                } else {
                    (live[first] * live[second]).toDouble()
                }
                if (pairWeight <= 0) continue
                for (cut in 1..13) {
                    val used = (if (first == cut) 1 else 0) + (if (second == cut) 1 else 0)
                    val cutWeight = live[cut] - used
                    if (cutWeight <= 0) continue
                    val weight = pairWeight * cutWeight
                    total += weight * rankOnlyScore(thrown + listOf(first, second, cut))
                    weightSum += weight
                }
            }
        }
        if (weightSum == 0.0) return 0.0
        val unseen = PlayingCard.standardDeck.filter { it !in excluded }
        val nobs = unseen.sumOf { cut ->
            val suit = (cut as PlayingCard.Standard).suit
            val jack = PlayingCard.Standard(11, suit)
            when {
                jack in discard -> 1.0
                cut != jack && jack in unseen -> 2.0 / (unseen.size - 1)
                else -> 0.0
            }
        } / unseen.size
        val suits = discard.map { (it as PlayingCard.Standard).suit }
        val flush = if (discard.size == 2 && suits[0] == suits[1]) {
            val suited = unseen.count { (it as PlayingCard.Standard).suit == suits[0] }
            val n = unseen.size.toDouble()
            5.0 * suited * (suited - 1) * (suited - 2) / (n * (n - 1) * (n - 2))
        } else 0.0
        return total / weightSum + nobs + flush
    }

    /** Expected hand count plus (dealer) or minus (pone) the expected crib. */
    fun discardValue(deal: List<PlayingCard>, discard: List<PlayingCard>, isDealer: Boolean): Double {
        val keep = deal.filter { it !in discard }
        val hand = averageWithCut(keep, deal)
        val crib = averageCrib(discard, deal)
        return if (isDealer) hand + crib else hand - crib
    }

    data class RankedDiscard(val discard: List<PlayingCard>, val value: Double)

    /** Every two-card discard from a six-card deal, best first. */
    fun rankedDiscards(deal: List<PlayingCard>, isDealer: Boolean): List<RankedDiscard> {
        val results = mutableListOf<RankedDiscard>()
        for (i in deal.indices) for (j in deal.indices) {
            if (j <= i) continue
            val discard = listOf(deal[i], deal[j])
            results += RankedDiscard(discard, discardValue(deal, discard, isDealer))
        }
        return results.sortedByDescending { it.value }
    }

    fun discardMatches(chosen: List<PlayingCard>, scenario: DiscardScenario): Int {
        if (chosen.size != 2 || chosen.toSet().size != 2 || chosen.any { it !in scenario.deal }) return 0
        if (chosen.toSet() == scenario.recommendedDiscard.toSet()) return 2
        val dealer = scenario.situation.lowercase().contains("dealer")
        val expected = discardValue(scenario.deal, scenario.recommendedDiscard, dealer)
        val actual = discardValue(scenario.deal, chosen, dealer)
        return if (kotlin.math.abs(actual - expected) < 1e-9) 2 else chosen.count { it in scenario.recommendedDiscard }
    }
}
