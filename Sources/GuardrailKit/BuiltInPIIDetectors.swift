/// Detects email addresses such as `jane.doe@example.com`.
public struct EmailAddressDetector: PIIDetector, Sendable {
    public let category = PIICategory.emailAddress

    public init() {}

    public func findMatches(in text: String) -> [PIIMatch] {
        let pattern = #/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/#
        return text.matches(of: pattern).map {
            PIIMatch(category: category, range: $0.range, matchedText: String(text[$0.range]))
        }
    }
}

/// Detects US-style phone numbers such as `555-123-4567` or `(555) 123-4567`.
public struct PhoneNumberDetector: PIIDetector, Sendable {
    public let category = PIICategory.phoneNumber

    public init() {}

    public func findMatches(in text: String) -> [PIIMatch] {
        let pattern = #/\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}/#
        return text.matches(of: pattern).map {
            PIIMatch(category: category, range: $0.range, matchedText: String(text[$0.range]))
        }
    }
}

/// Detects 16-digit credit-card-style numbers, grouped in fours with an
/// optional space or dash separator (e.g. `4111-1111-1111-1111`).
public struct CreditCardDetector: PIIDetector, Sendable {
    public let category = PIICategory.creditCard

    public init() {}

    public func findMatches(in text: String) -> [PIIMatch] {
        let pattern = #/\b(?:\d{4}[- ]?){3}\d{4}\b/#
        return text.matches(of: pattern).map {
            PIIMatch(category: category, range: $0.range, matchedText: String(text[$0.range]))
        }
    }
}

/// Detects US Social Security Numbers in `XXX-XX-XXXX` form.
public struct SocialSecurityNumberDetector: PIIDetector, Sendable {
    public let category = PIICategory.socialSecurityNumber

    public init() {}

    public func findMatches(in text: String) -> [PIIMatch] {
        let pattern = #/\b\d{3}-\d{2}-\d{4}\b/#
        return text.matches(of: pattern).map {
            PIIMatch(category: category, range: $0.range, matchedText: String(text[$0.range]))
        }
    }
}
