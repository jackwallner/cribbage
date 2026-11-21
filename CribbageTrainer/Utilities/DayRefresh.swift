import SwiftUI
import UIKit

extension View {
    /// Keeps `now` on the current day while the screen stays up. A screen
    /// that read `Date()` in its body kept yesterday's day (the Get Started
    /// card, the streak, the Minute's score) until something else redrew it,
    /// and returning to the app the next morning redraws nothing.
    func refreshesDay(_ now: Binding<Date>) -> some View {
        modifier(DayRefresh(now: now))
    }
}

private struct DayRefresh: ViewModifier {
    @Binding var now: Date
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onAppear { now = Date() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { now = Date() }
            }
            // Midnight with the screen up.
            .task(id: now) {
                guard let midnight = Calendar.current.nextDate(
                    after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime
                ) else { return }
                let wait = max(1, midnight.timeIntervalSinceNow + 1)
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                if !Task.isCancelled { now = Date() }
            }
            // A clock or time zone change.
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                now = Date()
            }
    }
}
