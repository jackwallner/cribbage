package com.jackwallner.cribbage.content

import com.jackwallner.cribbage.model.Room

object DrillLibrary {
    val rooms: List<Room> get() = CribbageContent.library.rooms

    fun room(id: String): Room? = rooms.firstOrNull { it.id == id }

    /** The room a drill belongs to, so drill screens can report per-room accuracy. */
    fun roomID(forDrillID: String): String =
        rooms.firstOrNull { room -> room.drills.any { it.id == forDrillID } }?.id ?: ""
}

object HowToPlayContent {
    val pages: List<HowToPlayPage> get() = CribbageContent.library.primer

    /** The room recommended at the end of the primer for an onboarding skill level. */
    fun recommendedRoom(skillLevel: String): Room {
        val roomID = when (skillLevel) {
            "basics" -> "scoring-room"
            "played" -> "discard-room"
            else -> "card-room"
        }
        return DrillLibrary.room(roomID) ?: DrillLibrary.rooms.first()
    }
}
