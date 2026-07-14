/// The final decision a ``GuardrailPipeline`` reaches for one screened text.
public enum GuardrailVerdict: Sendable, Equatable {
    case allow
    case redacted
    case blocked(reason: String)
}
