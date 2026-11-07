import ObjectiveC
import UserNotifications

/// Test-only stand-in for `UNUserNotificationCenter`: swizzles the three
/// methods AppSettings calls so nothing reaches iOS and every request is kept.
/// Authorization is always granted.
final class FakeNotificationCenter: @unchecked Sendable {
    private(set) var requests: [UNNotificationRequest] = []
    private(set) var removed: [String] = []
    private var saved: [(Method, IMP)] = []

    var added: [String] { requests.map(\.identifier) }

    func lastTrigger(_ id: String) -> DateComponents? {
        (requests.last { $0.identifier == id }?.trigger as? UNCalendarNotificationTrigger)?.dateComponents
    }

    static func install() -> FakeNotificationCenter {
        let fake = FakeNotificationCenter()
        let cls: AnyClass = UNUserNotificationCenter.self
        let addBlock: @convention(block) (AnyObject, UNNotificationRequest, ((Error?) -> Void)?) -> Void = { _, request, done in
            fake.requests.append(request)
            done?(nil)
        }
        let removeBlock: @convention(block) (AnyObject, [String]) -> Void = { _, ids in
            fake.removed.append(contentsOf: ids)
        }
        let authBlock: @convention(block) (AnyObject, UInt, @escaping (Bool, Error?) -> Void) -> Void = { _, _, done in
            done(true, nil)
        }
        fake.swap(cls, #selector(UNUserNotificationCenter.add(_:withCompletionHandler:)), addBlock)
        fake.swap(cls, #selector(UNUserNotificationCenter.removePendingNotificationRequests(withIdentifiers:)), removeBlock)
        fake.swap(cls, #selector(UNUserNotificationCenter.requestAuthorization(options:completionHandler:)), authBlock)
        return fake
    }

    private func swap(_ cls: AnyClass, _ selector: Selector, _ block: Any) {
        guard let method = class_getInstanceMethod(cls, selector) else { return }
        saved.append((method, method_getImplementation(method)))
        method_setImplementation(method, imp_implementationWithBlock(block))
    }

    func uninstall() {
        for (method, imp) in saved { method_setImplementation(method, imp) }
        saved = []
    }
}
