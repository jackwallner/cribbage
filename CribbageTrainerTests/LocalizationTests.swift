import XCTest
@testable import CribbageTrainer

/// The string catalog compiles into one .lproj per language, and the plural
/// rules survive the trip. A key that fell back to English would still pass a
/// "not empty" check, so these compare against the catalog's own wording.
final class LocalizationTests: XCTestCase {
    static let languages = ["de"]
    private let de = Locale(identifier: "de_DE")

    private func bundle(_ language: String) -> Bundle? {
        for host in [Bundle.main] + Bundle.allBundles {
            if let path = host.path(forResource: language, ofType: "lproj"), let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return nil
    }

    func testEveryLanguageShips() {
        for language in Self.languages {
            XCTAssertNotNil(bundle(language), "\(language).lproj is missing")
        }
    }

    func testGermanCopyIsTranslated() throws {
        let bundle = try XCTUnwrap(bundle("de"))
        XCTAssertEqual(String(localized: "Get Started", bundle: bundle, locale: de), "Los geht's")
        XCTAssertEqual(String(localized: "7 days free, then \("6,99 €/Monat"). Auto-renews until canceled.", bundle: bundle, locale: de),
                       "7 Tage gratis, dann 6,99 €/Monat. Verlängert sich automatisch bis zur Kündigung.")
    }

    func testGermanPluralsPickTheRightForm() throws {
        let bundle = try XCTUnwrap(bundle("de"))
        XCTAssertEqual(String(localized: "\(1) drills done", bundle: bundle, locale: de), "1 Übung erledigt")
        XCTAssertEqual(String(localized: "\(3) drills done", bundle: bundle, locale: de), "3 Übungen erledigt")
        XCTAssertEqual(String(localized: "Locked. \(1) drills, included with \("Cribbage+")", bundle: bundle, locale: de),
                       "Gesperrt. 1 Übung, in Cribbage+ enthalten")
        XCTAssertEqual(String(localized: "\(2) of \(5) drills done", bundle: bundle, locale: de), "2 von 5 Übungen erledigt")
    }

    func testEnglishCountsAreSingularForOne() throws {
        let bundle = try XCTUnwrap(bundle("en"))
        let en = Locale(identifier: "en_US")
        XCTAssertEqual(String(localized: "\(1) drills done", bundle: bundle, locale: en), "1 drill done")
        XCTAssertEqual(String(localized: "\(4) drills done", bundle: bundle, locale: en), "4 drills done")
        XCTAssertEqual(String(localized: "\(1) of \(1) drills done", bundle: bundle, locale: en), "1 of 1 drill done")
    }
}

/// Runs the app's own string builders under a German process, so a catalog
/// key whose interpolation type differs from the source (%lld against %@)
/// shows up as English here. Skipped unless the test run is German:
/// `gh-sim test --only CribbageTrainerTests/GermanRuntimeTests
///  --testarg -testLanguage --testarg de --testarg -testRegion --testarg DE`.
@MainActor
final class GermanRuntimeTests: XCTestCase {
    override func setUpWithError() throws {
        try XCTSkipUnless(Locale.preferredLanguages.first?.hasPrefix("de") == true, "German test run only")
    }

    func testCardNames() {
        XCTAssertEqual(PlayingCard.h(11).spokenName, "Herz-Bube")
        XCTAssertEqual(PlayingCard.s(1).spokenName, "Pik-Ass")
        XCTAssertEqual(PlayingCard.c(12).spokenName, "Kreuz-Dame")
        XCTAssertEqual(PlayingCard.d(7).spokenName, "Karo 7")
    }

    func testPeggingSummaries() {
        XCTAssertEqual(PeggingScoring.score(pile: [.c(4), .d(5)], play: .h(6))?.summary,
                       "2 für die Fünfzehn und 3 für eine Folge aus 3 Karten")
        XCTAssertEqual(PeggingScoring.score(pile: [.c(7), .d(7)], play: .h(7))?.summary, "6 für einen Drilling")
        let explanation = PeggingQuestionGenerator.explain(
            pile: [.c(4), .d(5)], play: .h(6),
            result: PeggingScoring.score(pile: [.c(4), .d(5)], play: .h(6))!
        )
        XCTAssertTrue(explanation.hasPrefix("Der Stand geht von 9 auf 15."), explanation)
    }

    func testGeneratedExplanations() {
        let count = HandCountGenerator.explain(hand: [.c(5), .d(5), .h(10), .s(11)], starter: .c(2))
        XCTAssertTrue(count.hasPrefix("Zähl alles mit der Startkarte:"), count)
        XCTAssertTrue(count.contains("Punkte insgesamt"), count)
        let run = HandGenerator.explain([.c(3), .d(4), .h(5), .s(9), .c(12)], answer: .runs)
        XCTAssertTrue(run.hasPrefix("Die Ränge bilden eine Folge für 3 Punkte."), run)
        let fifteens = HandGenerator.explain([.c(5), .d(10), .h(2), .s(8), .c(13)], answer: .fifteens)
        XCTAssertTrue(fifteens.hasPrefix("Kombinationen mit der Summe Fünfzehn"), fifteens)
    }

    func testEndlessPrompts() throws {
        let peg = try XCTUnwrap(EndlessPractice.items(for: .pegScore, count: 1).first)
        XCTAssertTrue(peg.prompt.hasPrefix("Bisher gespielt:"), peg.prompt)
        let legal = try XCTUnwrap(EndlessPractice.items(for: .pegging, count: 1).first)
        XCTAssertTrue(legal.prompt.hasPrefix("Der Stand ist"), legal.prompt)
        XCTAssertTrue(legal.explanation.hasPrefix("Der Stand ist"), legal.explanation)
        let hand = try XCTUnwrap(EndlessPractice.items(for: .countHand, count: 1).first)
        XCTAssertTrue(hand.choices.allSatisfy { $0.hasSuffix(" Punkte") || $0.hasSuffix(" Punkt") }, "\(hand.choices)")
    }

    func testCountLabelsAndPricing() {
        XCTAssertEqual(CribbageMinuteContent.drill.kind.countLabel, "0 Fragen")
        XCTAssertEqual(PaywallPricing.terms(amount: "69,99 €", plan: .lifetime), "69,99 € einmalig. Kein Abo, nichts verlängert sich.")
        XCTAssertEqual(MasteryLevel.learning.title, "Am Lernen")
    }
}
