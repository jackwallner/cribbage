import XCTest
@testable import CribbageTrainer

/// What the paywall and the onboarding trial page say when the purchase call
/// throws. They used to show the SDK's own text for every throw.
final class PurchaseFailureMessageTests: XCTestCase {
    /// RevenueCat `ErrorCode` raw values (Sources/Generated/ErrorCode.swift).
    private enum Code: Int {
        case purchaseNotAllowed = 3
        case network = 10
        case paymentPending = 20
    }

    /// What `Purchases.purchase` throws: RevenueCat's public NSError, whose
    /// domain is the Swift type name.
    private func revenueCatError(_ code: Code, _ text: String) -> NSError {
        NSError(domain: "RevenueCat.ErrorCode", code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: text])
    }

    /// Ask to Buy: StoreKit returns `.pending` and RevenueCat throws
    /// "The payment is deferred."
    func testAskToBuySaysItIsWaitingForApproval() {
        let error = revenueCatError(.paymentPending, "The payment is deferred.")
        XCTAssertTrue(SubscriptionService.isPaymentPending(error))
        XCTAssertEqual(
            SubscriptionService.purchaseFailureMessage(for: error, isMember: false, storeKitHoldsPurchase: false),
            "Waiting for approval. Cribbage+ unlocks when it is approved."
        )
    }

    /// Apple charged, then RevenueCat could not post the receipt. Apple still
    /// holds the unfinished transaction, so the customer is told it went
    /// through and that Restore will not charge again.
    func testChargedButNotPostedPointsAtRestore() {
        let error = revenueCatError(.network, "Error performing request.")
        XCTAssertFalse(SubscriptionService.isPaymentPending(error))
        let message = SubscriptionService.purchaseFailureMessage(for: error, isMember: false, storeKitHoldsPurchase: true)
        XCTAssertEqual(message, SubscriptionService.purchaseNotUnlockedMessage)
        XCTAssertTrue(message?.contains("tap Restore") == true)
        XCTAssertTrue(message?.contains("You will not be charged twice.") == true)
    }

    /// A second look found the membership: nothing to say, the screen moves on.
    func testMembershipThatArrivedAfterAllSaysNothing() {
        let error = revenueCatError(.network, "Error performing request.")
        XCTAssertNil(SubscriptionService.purchaseFailureMessage(for: error, isMember: true, storeKitHoldsPurchase: true))
    }

    /// Nothing was bought: the error itself is still the honest answer.
    func testAFailureWithNoPurchaseShowsTheError() {
        let error = revenueCatError(.purchaseNotAllowed, "The device or user is not allowed to make the purchase.")
        XCTAssertEqual(
            SubscriptionService.purchaseFailureMessage(for: error, isMember: false, storeKitHoldsPurchase: false),
            "The device or user is not allowed to make the purchase."
        )
    }

    func testNoPlayerFacingTextUsesEmDashes() {
        let pending = SubscriptionService.purchaseFailureMessage(
            for: revenueCatError(.paymentPending, ""), isMember: false, storeKitHoldsPurchase: false
        )
        XCTAssertFalse(pending?.contains("\u{2014}") == true)
        XCTAssertFalse(SubscriptionService.purchaseNotUnlockedMessage.contains("\u{2014}"))
    }
}
