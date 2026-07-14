/// A deterministic content policy rule: flags text containing any of a
/// configured set of banned phrases, case-insensitively. Returns the first
/// matching phrase's finding; a host app that needs every match can compose
/// several rules instead.
public struct BannedPhraseRule: ContentPolicyRule, Sendable {
    /// One banned phrase and the severity a match against it should carry.
    public struct Phrase: Sendable {
        public let text: String
        public let severity: GuardrailSeverity

        public init(_ text: String, severity: GuardrailSeverity) {
            self.text = text
            self.severity = severity
        }
    }

    private let phrases: [Phrase]

    public init(phrases: [Phrase]) {
        self.phrases = phrases
    }

    public func evaluate(_ text: String) -> GuardrailFinding? {
        let lowered = text.lowercased()
        guard let match = phrases.first(where: { lowered.contains($0.text.lowercased()) }) else {
            return nil
        }
        return GuardrailFinding(
            category: "BANNED_PHRASE",
            severity: match.severity,
            detail: "matched banned phrase \"\(match.text)\""
        )
    }
}
