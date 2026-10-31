package com.jackwallner.cribbage.content

import com.jackwallner.cribbage.model.HandCategory
import com.jackwallner.cribbage.model.Drill
import com.jackwallner.cribbage.model.DrillKind
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.Suit
import java.util.UUID
import kotlin.random.Random

/** Generated practice skills. Each one becomes the same QuickItem shape as authored drills. */
enum class PracticeSkill(val raw: String, val title: String, val subtitle: String, val icon: String, val roomID: String) {
    HAND_READING("handReading", "Read the Hand", "Fresh five-card hands, unlimited reps", "rectangle.portrait.on.rectangle.portrait.angled", "scoring-room"),
    PEGGING("pegging", "Count to 31", "Practice legal plays against the running total", "number.circle.fill", "pegging-room");

    /** Every generated item carries this prefix so stats roll it up into one row. */
    val itemPrefix: String get() = "gen-$raw-"

    companion object {
        fun fromRaw(raw: String): PracticeSkill? = entries.firstOrNull { it.raw == raw }

        fun skill(forItemID: String): PracticeSkill? = entries.firstOrNull { forItemID.startsWith(it.itemPrefix) }
    }
}

object EndlessPractice {
    fun drill(skill: PracticeSkill) = Drill("endless-${skill.raw}", skill.title, skill.subtitle, DrillKind.Quiz(emptyList()))

    val challengeDrill = Drill("timed-challenge", "Timed Challenge", "Beat the clock", DrillKind.Quiz(emptyList()))

    fun items(skill: PracticeSkill, count: Int): List<QuickItem> = when (skill) {
        PracticeSkill.HAND_READING -> handItems(count)
        PracticeSkill.PEGGING -> peggingItems(count)
    }

    /** A mixed batch across every skill, for the timed challenge. */
    fun mixedItems(count: Int): List<QuickItem> {
        val skills = PracticeSkill.entries
        val perSkill = maxOf(1, count / skills.size + 1)
        return skills.flatMap { items(it, perSkill) }.shuffled().take(count)
    }

    private fun newID(skill: PracticeSkill) = skill.itemPrefix + UUID.randomUUID().toString().uppercase()

    private fun handItems(count: Int): List<QuickItem> = HandGenerator.batch(count).map { hand ->
        QuickItem(
            id = newID(PracticeSkill.HAND_READING),
            prompt = HandCategory.patternPrompt,
            tiles = hand.tiles,
            choices = hand.choices.map { it.displayName },
            answerIndex = hand.choices.indexOf(hand.answer).coerceAtLeast(0),
            explanation = hand.explanation,
            sourceLabel = "Endless Practice",
            roomID = PracticeSkill.HAND_READING.roomID,
        )
    }

    private fun peggingItems(count: Int): List<QuickItem> {
        val items = mutableListOf<QuickItem>()
        while (items.size < count) {
            val total = Random.nextInt(10, 31)
            val rank = Random.nextInt(1, 14)
            val card = PlayingCard.Standard(rank, Suit.entries.random())
            val value = card.cribbageValue
            val nextTotal = total + value
            val canPlay = nextTotal <= 31
            val choices = if (canPlay) {
                listOf("Play it, making $nextTotal", "Say go", "Reset the count")
            } else {
                listOf("Play it, making $nextTotal", "Say go", "Ask for a new card")
            }
            val explanation = if (canPlay) {
                "The running total is $total, and ${card.spokenName} is worth $value, so the legal total is $nextTotal. Check whether the play also creates 15, a pair, a run, or 31."
            } else {
                "The running total is $total, and ${card.spokenName} is worth $value, which would pass 31. You must say go if you have no legal card."
            }
            // Shuffled by id, as on iOS, so the answer is not in a fixed slot.
            items += SessionBuilder.prepared(
                QuickItem(
                    id = newID(PracticeSkill.PEGGING),
                    prompt = "The running total is $total. You hold the ${card.spokenName}. What is the legal play?",
                    tiles = listOf(card),
                    choices = choices,
                    answerIndex = if (canPlay) 0 else 1,
                    explanation = explanation,
                    sourceLabel = "Endless Practice",
                    roomID = PracticeSkill.PEGGING.roomID,
                ),
            )
        }
        return items
    }
}
