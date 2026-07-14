/// Something that can flag free text against a content or safety policy —
/// profanity, leaked secrets, disallowed topics, whatever the host app cares
/// about. Conform to this to wire in a real moderation API; ``GuardrailKit``
/// ships a deterministic, phrase-list-based rule.
public protocol ContentPolicyRule: Sendable {
    func evaluate(_ text: String) -> GuardrailFinding?
}
