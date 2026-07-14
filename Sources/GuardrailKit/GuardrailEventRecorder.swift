/// Something that can persist ``GuardrailEvent``s as they happen. Conform to
/// this to forward events into a real tracing/observability pipeline;
/// ``InMemoryGuardrailEventRecorder`` is the deterministic, testable default.
public protocol GuardrailEventRecorder: Sendable {
    func record(_ event: GuardrailEvent) async
}

/// An actor-isolated ``GuardrailEventRecorder`` that keeps every event it's
/// given in memory, in the order it was recorded.
public actor InMemoryGuardrailEventRecorder: GuardrailEventRecorder {
    private var events: [GuardrailEvent] = []

    public init() {}

    public func record(_ event: GuardrailEvent) {
        events.append(event)
    }

    public var recordedEvents: [GuardrailEvent] {
        events
    }
}
