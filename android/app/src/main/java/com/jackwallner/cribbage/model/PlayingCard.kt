package com.jackwallner.cribbage.model

// Case order matches the iOS `allCases` order. The seeded generators walk
// these lists, so reordering a case changes every shared daily challenge.

enum class Suit(val raw: String, val symbol: String) {
    CLUBS("clubs", "♣"),
    DIAMONDS("diamonds", "♦"),
    HEARTS("hearts", "♥"),
    SPADES("spades", "♠");

    val displayName: String get() = raw.replaceFirstChar { it.uppercase() }
    val isRed: Boolean get() = this == DIAMONDS || this == HEARTS
}

sealed interface PlayingCard {
    data class Standard(val rank: Int, val suit: Suit) : PlayingCard
    data object Joker : PlayingCard

    val shortLabel: String
        get() = when (this) {
            is Standard -> "${rankLabel(rank)}${suit.symbol}"
            Joker -> "Joker"
        }

    val spokenName: String
        get() = when (this) {
            is Standard -> "${rankLabel(rank)} of ${suit.displayName}"
            Joker -> "Joker"
        }

    val rankValue: Int get() = (this as? Standard)?.rank ?: 0

    /** What the card counts toward fifteen and 31: court cards are 10. */
    val cribbageValue: Int get() = (this as? Standard)?.rank?.coerceAtMost(10) ?: 0

    val sortKey: Int
        get() = when (this) {
            is Standard -> suit.ordinal * 20 + rank
            Joker -> 100
        }

    /** The card's code in the exported content, e.g. `H11` for the jack of hearts. */
    val code: String
        get() = when (this) {
            is Standard -> "${suit.raw.take(1).uppercase()}$rank"
            Joker -> "JK"
        }

    companion object {
        fun c(rank: Int): PlayingCard = Standard(rank, Suit.CLUBS)
        fun d(rank: Int): PlayingCard = Standard(rank, Suit.DIAMONDS)
        fun h(rank: Int): PlayingCard = Standard(rank, Suit.HEARTS)
        fun s(rank: Int): PlayingCard = Standard(rank, Suit.SPADES)

        fun rankLabel(rank: Int): String = when (rank) {
            1 -> "A"
            11 -> "J"
            12 -> "Q"
            13 -> "K"
            else -> rank.toString()
        }

        /** Suit by suit, ace to king, the same order as iOS `standardDeck`. */
        val standardDeck: List<PlayingCard> = Suit.entries.flatMap { suit -> (1..13).map { Standard(it, suit) } }

        private val byCode: Map<String, PlayingCard> = (standardDeck + Joker).associateBy { it.code }

        fun fromCode(code: String): PlayingCard = byCode[code] ?: error("Unknown card code $code")
    }
}

/** Sorted by suit then rank, the way the hand is fanned on screen. */
val List<PlayingCard>.racked: List<PlayingCard> get() = sortedBy { it.sortKey }
