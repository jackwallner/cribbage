package com.jackwallner.cribbage.model

/** Standard two-player play scoring, reset after go or 31. */
object PeggingRules {
    fun legal(hand: List<PlayingCard>, total: Int) = hand.filter { total + it.cribbageValue <= 31 }

    fun points(sequence: List<PlayingCard>): Int {
        val last = sequence.lastOrNull() ?: return 0
        val total = sequence.sumOf { it.cribbageValue }
        if (total > 31) return 0
        val equal = sequence.asReversed().takeWhile { it.rankValue == last.rankValue }.size
        val points = (if (total == 15 || total == 31) 2 else 0) + equal * (equal - 1)
        for (length in sequence.size downTo 3) {
            val ranks = sequence.takeLast(length).map { it.rankValue }
            if (ranks.toSet().size == length && ranks.max() - ranks.min() == length - 1) return points + length
        }
        return points
    }

    fun lastCard(total: Int) = if (total == 31) 0 else 1
    fun heels(starter: PlayingCard) = if (starter.rankValue == 11) 2 else 0
    enum class ScoreKind { PLAY, HAND, CRIB, HEELS, PENALTY, MUGGINS, BACKWARD }
    fun muggins(earned: Int, pegged: Int, enabled: Boolean, kind: ScoreKind): Int =
        if (enabled && kind in listOf(ScoreKind.PLAY, ScoreKind.HAND, ScoreKind.CRIB)) maxOf(0, earned - pegged) else 0
}
