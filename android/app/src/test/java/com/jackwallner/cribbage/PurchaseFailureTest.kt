package com.jackwallner.cribbage

import com.jackwallner.cribbage.data.PurchaseFailure
import com.revenuecat.purchases.PurchasesErrorCode
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/** iOS B5: a purchase that threw after Google Play took the money points at Restore. */
class PurchaseFailureTest {
    @Test
    fun chargedButNotPostedPointsAtRestore() {
        for (code in listOf(PurchasesErrorCode.ProductAlreadyPurchasedError, PurchasesErrorCode.InvalidReceiptError, PurchasesErrorCode.UnknownBackendError)) {
            val message = PurchaseFailure.message(code, isMember = false)!!
            assertTrue(code.name, message.contains("tap Restore"))
            assertTrue(code.name, message.contains("You will not be charged twice"))
        }
    }

    @Test
    fun membershipThatArrivedAfterAllSaysNothing() {
        assertNull(PurchaseFailure.message(PurchasesErrorCode.UnknownBackendError, isMember = true))
        assertNull(PurchaseFailure.message(PurchasesErrorCode.StoreProblemError, isMember = true))
    }

    @Test
    fun aFailureWithNoPurchaseShowsTheError() {
        assertEquals(PurchaseFailure.GENERIC, PurchaseFailure.message(PurchasesErrorCode.StoreProblemError, isMember = false))
        assertEquals(PurchaseFailure.GENERIC, PurchaseFailure.message(PurchasesErrorCode.PurchaseNotAllowedError, isMember = false))
    }
}
