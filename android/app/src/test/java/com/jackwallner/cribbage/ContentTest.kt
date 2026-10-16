package com.jackwallner.cribbage

import com.jackwallner.cribbage.content.CribbageContent
import com.jackwallner.cribbage.content.DrillLibrary
import com.jackwallner.cribbage.content.HowToPlayContent
import com.jackwallner.cribbage.content.SessionBuilder
import com.jackwallner.cribbage.model.DiscardScenario
import com.jackwallner.cribbage.model.DrillKind
import com.jackwallner.cribbage.model.Flashcard
import com.jackwallner.cribbage.model.HandMatchQuestion
import com.jackwallner.cribbage.model.HandScoring
import com.jackwallner.cribbage.model.PlayingCard
import com.jackwallner.cribbage.model.QuizQuestion
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Port of iOS `ContentValidityTests`, run against the exported content the app ships. */
class ContentTest {
    private val drills = DrillLibrary.rooms.flatMap { it.drills }
    private val handMatch: List<HandMatchQuestion> = drills.flatMap { (it.kind as? DrillKind.HandMatch)?.questions.orEmpty() }
    private val quiz: List<QuizQuestion> = drills.flatMap { (it.kind as? DrillKind.Quiz)?.questions.orEmpty() }
    private val discards: List<DiscardScenario> = drills.flatMap { (it.kind as? DrillKind.Discard)?.scenarios.orEmpty() }
    private val flashcards: List<Flashcard> = drills.flatMap { (it.kind as? DrillKind.Flashcards)?.cards.orEmpty() }

    @Test
    fun countsMatchIos() {
        val expected = ParityFixtures.json.getJSONObject("drillCounts")
        assertEquals(expected.length(), drills.size)
        for (drill in drills) assertEquals(drill.id, expected.getInt(drill.id), drill.kind.itemCount)
        assertEquals(listOf("card-room", "scoring-room", "discard-room", "pegging-room", "pro-tables"), DrillLibrary.rooms.map { it.id })
        assertEquals(ParityFixtures.json.getInt("lockedDrillCount"), DrillLibrary.rooms.sumOf { it.plusDrillCount })
        assertEquals(5, CribbageContent.library.categoryText.size)
        assertEquals(6, HowToPlayContent.pages.size)
    }

    @Test
    fun handMatchQuestionsShowFiveDistinctCards() {
        for (question in handMatch) {
            assertEquals(question.id, 5, question.tiles.size)
            assertEquals(question.id, 5, question.tiles.toSet().size)
        }
    }

    @Test
    fun handMatchAnswerIsAmongDistinctChoices() {
        for (question in handMatch) {
            assertTrue(question.id, question.answer in question.choices)
            assertEquals(question.id, question.choices.size, question.choices.toSet().size)
            assertTrue(question.id, question.choices.size >= 3)
        }
    }

    @Test
    fun handMatchQuestionsHaveExactlyOneCorrectAnswer() {
        for (question in handMatch) {
            val present = question.choices.filter { it.isPresent(question.tiles) }
            assertEquals("${question.id} ${codes(question.tiles)}", listOf(question.answer), present)
        }
    }

    @Test
    fun discardScenariosStateExactlyOneRole() {
        for (scenario in discards) {
            val text = scenario.situation.lowercase()
            assertNotEquals(scenario.id, "dealer" in text, "pone" in text)
        }
    }

    @Test
    fun recommendedDiscardsAreOptimal() {
        for (scenario in discards) {
            val isDealer = "dealer" in scenario.situation.lowercase()
            val best = HandScoring.rankedDiscards(scenario.deal, isDealer).first()
            val recommended = HandScoring.discardValue(scenario.deal, scenario.recommendedDiscard, isDealer)
            assertEquals(scenario.id, best.value, recommended, 0.05)
        }
    }

    @Test
    fun poneDiscardsNeverGiftTheCrib() {
        for (scenario in discards.filter { "dealer" !in it.situation.lowercase() }) {
            val thrown = scenario.recommendedDiscard
            assertNotEquals(scenario.id, thrown[0].rankValue, thrown[1].rankValue)
            assertNotEquals(scenario.id, 15, thrown[0].cribbageValue + thrown[1].cribbageValue)
            assertFalse(scenario.id, thrown.any { it.rankValue == 5 })
        }
    }

    @Test
    fun discardDealsHaveSixStandardCardsAndRecommendTwo() {
        for (scenario in discards) {
            assertEquals(scenario.id, 6, scenario.deal.size)
            assertEquals(scenario.id, 2, scenario.recommendedDiscard.size)
            assertEquals(scenario.id, 6, scenario.deal.toSet().size)
            assertTrue(scenario.id, scenario.deal.containsAll(scenario.recommendedDiscard))
            assertTrue(scenario.id, scenario.deal.all { it is PlayingCard.Standard && it.rank in 1..13 })
        }
    }

    @Test
    fun quizAndCardChoicesAreValid() {
        for (question in quiz) {
            assertTrue(question.id, question.answerIndex in question.choices.indices)
            assertTrue(question.id, question.choices.size >= 2)
            assertEquals(question.id, question.choices.size, question.choices.toSet().size)
        }
        for (card in flashcards) {
            val choice = card.choice ?: continue
            assertEquals(card.id, 2, choice.options.size)
            assertTrue(card.id, choice.answerIndex in choice.options.indices)
            assertEquals(card.id, 2, choice.options.toSet().size)
        }
    }

    @Test
    fun allContentIDsAreUnique() {
        val ids = DrillLibrary.rooms.flatMap { room ->
            listOf(room.id) + room.drills.flatMap { drill ->
                listOf(drill.id) + when (val kind = drill.kind) {
                    is DrillKind.Flashcards -> kind.cards.map { it.id }
                    is DrillKind.Quiz -> kind.questions.map { it.id }
                    is DrillKind.HandMatch -> kind.questions.map { it.id }
                    is DrillKind.Discard -> kind.scenarios.map { it.id }
                }
            }
        }
        assertEquals(ids.size, ids.toSet().size)
    }

    @Test
    fun freeBeginnerModelIsIntact() {
        assertTrue(DrillLibrary.rooms.first().isFree)
        for (room in DrillLibrary.rooms) {
            assertTrue(room.id, room.drills.isNotEmpty())
            for (drill in room.drills) assertTrue(drill.id, drill.kind.itemCount > 0)
            if (room.id == "pro-tables") {
                assertFalse(room.isFree)
            } else {
                assertTrue(room.isFree)
                assertEquals(room.id, 1, room.drills.count { it.isPlus })
            }
            for (drill in room.drills) {
                assertFalse(room.isLocked(drill, isMember = true))
                assertEquals(!room.isFree || drill.isPlus, room.isLocked(drill, isMember = false))
            }
        }
    }

    @Test
    fun noEmDashesOrStaleTileCopy() {
        val copy = mutableListOf<String>()
        for (room in DrillLibrary.rooms) {
            copy += listOf(room.name, room.tagline)
            for (drill in room.drills) {
                copy += listOf(drill.title, drill.subtitle)
                when (val kind = drill.kind) {
                    is DrillKind.Flashcards -> kind.cards.forEach {
                        copy += listOf(it.frontTitle, it.frontSubtitle.orEmpty(), it.backTitle, it.backBody) + it.choice?.options.orEmpty()
                    }
                    is DrillKind.Quiz -> kind.questions.forEach { copy += listOf(it.prompt, it.explanation) + it.choices }
                    is DrillKind.HandMatch -> kind.questions.forEach { copy += it.explanation }
                    is DrillKind.Discard -> kind.scenarios.forEach { copy += listOf(it.situation, it.reasoning, it.tip) }
                }
            }
        }
        HowToPlayContent.pages.forEach { copy += listOf(it.title, it.body, it.tip.orEmpty()) }
        for (text in copy) {
            assertFalse("Em dash: $text", "—" in text)
            assertFalse("Stale tile copy: $text", text.contains("tile", ignoreCase = true))
            assertFalse("Stale mahjong copy: $text", text.contains("mahj", ignoreCase = true))
        }
    }

    @Test
    fun primerPagesHaveUniqueIDsAndDistinctCards() {
        val pages = HowToPlayContent.pages
        assertEquals(pages.size, pages.map { it.id }.toSet().size)
        for (page in pages) assertEquals(page.id, page.tiles.size, page.tiles.toSet().size)
        assertEquals("card-room", HowToPlayContent.recommendedRoom("new").id)
        assertEquals("scoring-room", HowToPlayContent.recommendedRoom("basics").id)
        assertEquals("discard-room", HowToPlayContent.recommendedRoom("played").id)
    }

    private val lockedItemIDs: Set<String> by lazy {
        DrillLibrary.rooms.flatMap { room ->
            room.drills.filter { room.isLocked(it, isMember = false) }.flatMap { drill ->
                when (val kind = drill.kind) {
                    is DrillKind.Flashcards -> kind.cards.map { it.id }
                    is DrillKind.Quiz -> kind.questions.map { it.id }
                    is DrillKind.HandMatch -> kind.questions.map { it.id }
                    is DrillKind.Discard -> kind.scenarios.map { it.id }
                }
            }
        }.toSet()
    }

    @Test
    fun quickSessionPullsTenAndPrioritizesMisses() {
        val mix = SessionBuilder.quickSession(seen = emptySet(), missed = emptySet(), includePro = false)
        assertEquals(10, mix.size)
        assertEquals(10, mix.map { it.id }.toSet().size)
        val missed = mix[0].id
        assertTrue(SessionBuilder.quickSession(seen = setOf(missed), missed = setOf(missed), includePro = false).any { it.id == missed })
    }

    @Test
    fun quickSessionRespectsThePaidBoundary() {
        assertTrue(lockedItemIDs.isNotEmpty())
        val free = SessionBuilder.quickSession(200, emptySet(), emptySet(), includePro = false)
        for (item in free) assertFalse("${item.id} leaked", item.id in lockedItemIDs)
        val member = SessionBuilder.quickSession(500, emptySet(), emptySet(), includePro = true)
        assertTrue(member.any { it.id in lockedItemIDs })
        val freeIDs = ParityFixtures.json.getJSONArray("freePoolIDs").strings().toSet()
        assertEquals(freeIDs, free.map { it.id }.toSet())
    }

    @Test
    fun quickSessionItemsAreChoiceOnly() {
        val plainCards = flashcards.filter { it.choice == null }.map { it.id }.toSet()
        val discardIDs = discards.map { it.id }.toSet()
        for (item in SessionBuilder.quickSession(200, emptySet(), emptySet(), includePro = true)) {
            assertTrue(item.choices.size >= 2)
            assertTrue(item.answerIndex in item.choices.indices)
            assertFalse(item.id in plainCards)
            assertFalse(item.id in discardIDs)
        }
    }

    @Test
    fun gameNightPrepLeadsWithDueThenWeakestRoom() {
        val pool = SessionBuilder.quickSession(500, emptySet(), emptySet(), includePro = true)
        val due = pool.first { it.roomID == "pro-tables" }.id
        val prep = SessionBuilder.gameNightPrep(seen = emptySet(), missed = emptySet(), dueIDs = listOf(due), weakestRoomID = "pegging-room")
        assertEquals(10, prep.size)
        assertEquals(due, prep.first().id)
        assertTrue(prep.drop(1).take(9).all { it.roomID == "pegging-room" })
    }

    @Test
    fun reviewSessionKeepsSchedulerOrderAndDropsLockedItems() {
        val member = SessionBuilder.quickSession(500, emptySet(), emptySet(), includePro = true)
        val locked = member.first { it.id in lockedItemIDs }.id
        val free = member.first { it.id !in lockedItemIDs }.id
        assertEquals(listOf(locked, free), SessionBuilder.reviewSession(listOf(locked, free), includePro = true).map { it.id })
        assertEquals(listOf(free), SessionBuilder.reviewSession(listOf(locked, free), includePro = false).map { it.id })
    }
}
