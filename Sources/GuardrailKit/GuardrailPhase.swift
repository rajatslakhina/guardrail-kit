/// Which side of an LLM turn a guardrail check runs on: before a prompt is
/// sent to a provider, or after a reply comes back.
public enum GuardrailPhase: String, Sendable, Equatable, CaseIterable {
    case preRequest
    case postResponse
}
