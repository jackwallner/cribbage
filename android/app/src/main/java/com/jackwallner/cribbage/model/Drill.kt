package com.jackwallner.cribbage.model

import com.jackwallner.cribbage.content.CribbageContent

/**
 * The five scoring shapes a player can spot in a five-card layout. Every
 * hand-match question offers three, and exactly one of the three is present.
 * Their copy lives in the exported content so it cannot drift from iOS.
 */
enum class HandCategory(val raw: String) {
    FIFTEENS("fifteens"),
    PAIRS("pairs"),
    RUNS("runs"),
    FLUSHES("flushes"),
    NOBS("nobs");

    val displayName: String get() = CribbageContent.library.categoryText.getValue(this).displayName
    val shortName: String get() = CribbageContent.library.categoryText.getValue(this).shortName
    val howToSpot: String get() = CribbageContent.library.categoryText.getValue(this).howToSpot

    /** True when this shape is in the cards. A jack counts for nobs: the cut decides it. */
    fun isPresent(cards: List<PlayingCard>): Boolean = when (this) {
        FIFTEENS -> HandScoring.fifteens(cards) > 0
        PAIRS -> HandScoring.pairs(cards) > 0
        RUNS -> HandScoring.runs(cards) > 0
        FLUSHES -> HandScoring.longestSuitCount(cards) >= 4
        NOBS -> cards.any { it.rankValue == 11 }
    }

    companion object {
        fun fromRaw(raw: String): HandCategory = entries.first { it.raw == raw }
    }
}

data class CategoryText(val displayName: String, val shortName: String, val howToSpot: String)

/** A two-option self-test on a card's front. */
data class CardChoice(val options: List<String>, val answerIndex: Int)

data class Flashcard(
    val id: String,
    val frontTitle: String,
    val frontTiles: List<PlayingCard> = emptyList(),
    val frontSubtitle: String? = null,
    val backTitle: String,
    val backBody: String,
    val choice: CardChoice? = null,
)

data class QuizQuestion(
    val id: String,
    val prompt: String,
    val tiles: List<PlayingCard> = emptyList(),
    val choices: List<String>,
    val answerIndex: Int,
    val explanation: String,
)

data class HandMatchQuestion(
    val id: String,
    val tiles: List<PlayingCard>,
    val choices: List<HandCategory>,
    val answer: HandCategory,
    val explanation: String,
)

data class DiscardScenario(
    val id: String,
    val situation: String,
    val deal: List<PlayingCard>,
    val recommendedDiscard: List<PlayingCard>,
    val reasoning: String,
    val tip: String,
)

sealed interface DrillKind {
    data class Flashcards(val cards: List<Flashcard>) : DrillKind
    data class Quiz(val questions: List<QuizQuestion>) : DrillKind
    data class HandMatch(val questions: List<HandMatchQuestion>) : DrillKind
    data class Discard(val scenarios: List<DiscardScenario>) : DrillKind

    val itemCount: Int
        get() = when (this) {
            is Flashcards -> cards.size
            is Quiz -> questions.size
            is HandMatch -> questions.size
            is Discard -> scenarios.size
        }

    val unitName: String
        get() = when (this) {
            is Flashcards -> "cards"
            is Quiz -> "questions"
            is HandMatch -> "hands"
            is Discard -> "deals"
        }
}

data class Drill(
    val id: String,
    val title: String,
    val subtitle: String,
    val kind: DrillKind,
    /** Extra practice sets inside an otherwise free room, locked behind Cribbage+. */
    val isPlus: Boolean = false,
)

data class Room(
    val id: String,
    val name: String,
    val tagline: String,
    val icon: String,
    /** A free room opens for everyone; its `isPlus` drills are the locked extras. */
    val isFree: Boolean,
    val drills: List<Drill>,
) {
    /** Drills a member unlocks here: the whole room if it is paid, otherwise the extra sets. */
    val plusDrillCount: Int get() = if (isFree) drills.count { it.isPlus } else drills.size

    fun isLocked(drill: Drill, isMember: Boolean): Boolean = !isMember && (!isFree || drill.isPlus)
}
