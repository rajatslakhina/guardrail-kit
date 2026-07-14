/// A category of personally identifiable information a ``PIIDetector`` can
/// find in free text.
public enum PIICategory: String, Sendable, Equatable, CaseIterable {
    case emailAddress = "EMAIL_ADDRESS"
    case phoneNumber = "PHONE_NUMBER"
    case creditCard = "CREDIT_CARD"
    case socialSecurityNumber = "SOCIAL_SECURITY_NUMBER"
}

/// A single PII match found in a piece of text, with the range it occupies
/// so a caller can redact it in place.
public struct PIIMatch: Sendable, Equatable {
    public let category: PIICategory
    public let range: Range<String.Index>
    public let matchedText: String

    public init(category: PIICategory, range: Range<String.Index>, matchedText: String) {
        self.category = category
        self.range = range
        self.matchedText = matchedText
    }
}

/// Something that can scan free text for one category of personally
/// identifiable information. Conform to this to plug in a detector backed by
/// a real NER model or vendor API; ``GuardrailKit`` ships deterministic,
/// regex-based detectors for common categories.
public protocol PIIDetector: Sendable {
    var category: PIICategory { get }
    func findMatches(in text: String) -> [PIIMatch]
}
