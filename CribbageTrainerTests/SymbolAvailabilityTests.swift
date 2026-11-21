import UIKit
import XCTest

/// Every SF Symbol the app names must exist on its deployment target.
/// `Image(systemName:)` draws nothing for a name the running iOS does not
/// know, so a symbol from a newer SF Symbols release is a blank icon on
/// older phones, and a simulator on the newest iOS never shows it.
final class SymbolAvailabilityTests: XCTestCase {
    private let deploymentTarget = (major: 17, minor: 0)

    func testEverySymbolTheAppNamesExistsOnTheDeploymentTarget() throws {
        let availability = try loadAvailability()
        let symbols = try XCTUnwrap(availability["symbols"] as? [String: String], "no symbols table")
        let releases = try XCTUnwrap(availability["year_to_release"] as? [String: [String: String]], "no releases table")

        let names = try symbolLiteralsInAppSource(known: symbols)
        XCTAssertFalse(names.isEmpty, "found no symbol names in the app source")
        let tooNew = names.sorted().compactMap { name -> String? in
            guard let year = symbols[name], let ios = releases[year]?["iOS"] else { return nil }
            return isOnDeploymentTarget(ios) ? nil : "\(name) (iOS \(ios))"
        }
        XCTAssertEqual(tooNew, [], "symbols newer than iOS \(deploymentTarget.major).\(deploymentTarget.minor)")
    }

    private func isOnDeploymentTarget(_ version: String) -> Bool {
        let parts = version.split(separator: ".").compactMap { Int($0) }
        let major = parts.first ?? 0
        let minor = parts.count > 1 ? parts[1] : 0
        return major < deploymentTarget.major || (major == deploymentTarget.major && minor <= deploymentTarget.minor)
    }

    /// SF Symbols' own table of which release introduced each name, shipped
    /// in the simulator runtime's CoreGlyphs bundle.
    private func loadAvailability() throws -> [String: Any] {
        _ = UIImage(systemName: "star")
        let root = ProcessInfo.processInfo.environment["IPHONE_SIMULATOR_ROOT"] ?? ""
        let bundlePaths = [
            Bundle(identifier: "com.apple.CoreGlyphs")?.bundlePath,
            root + "/System/Library/CoreServices/CoreGlyphs.bundle",
            "/System/Library/CoreServices/CoreGlyphs.bundle",
        ].compactMap { $0 }
        let candidates = bundlePaths.flatMap { [$0 + "/name_availability.plist", $0 + "/Contents/Resources/name_availability.plist"] }
        for path in candidates {
            if let data = FileManager.default.contents(atPath: path),
               let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
                return plist
            }
        }
        throw NSError(domain: "SymbolAvailabilityTests", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "name_availability.plist not found in \(candidates)",
        ])
    }

    /// Every string literal in the app's Swift sources that is a symbol name.
    private func symbolLiteralsInAppSource(known: [String: String]) throws -> Set<String> {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let literal = try NSRegularExpression(pattern: "\"([a-z0-9]+(?:\\.[a-z0-9]+)*)\"")
        var names = Set<String>()
        for folder in ["CribbageTrainer", "Shared"] {
            let enumerator = FileManager.default.enumerator(at: repo.appendingPathComponent(folder), includingPropertiesForKeys: nil)
            while let url = enumerator?.nextObject() as? URL {
                guard url.pathExtension == "swift", let text = try? String(contentsOf: url, encoding: .utf8) else { continue }
                let range = NSRange(text.startIndex..., in: text)
                for match in literal.matches(in: text, range: range) {
                    guard let name = Range(match.range(at: 1), in: text).map({ String(text[$0]) }) else { continue }
                    if known[name] != nil { names.insert(name) }
                }
            }
        }
        return names
    }
}
