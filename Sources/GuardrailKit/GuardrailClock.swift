import Foundation

/// An injectable source of the current time, so ``GuardrailEvent`` timestamps
/// are deterministic and testable rather than tied to the wall clock.
public protocol GuardrailClock: Sendable {
    func now() -> Date
}

/// A ``GuardrailClock`` backed by the real system clock.
public struct SystemGuardrailClock: GuardrailClock, Sendable {
    public init() {}

    public func now() -> Date {
        Date()
    }
}
