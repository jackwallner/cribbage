import Foundation

extension Double {
    /// A 0...1 fraction as a whole percentage in the reader's locale
    /// ("87%", "87 %").
    var percentText: String {
        formatted(.percent.precision(.fractionLength(0)).rounded(rule: .toNearestOrAwayFromZero))
    }
}
