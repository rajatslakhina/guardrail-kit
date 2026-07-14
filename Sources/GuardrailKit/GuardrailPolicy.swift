/// The configured set of checks a ``GuardrailPipeline`` runs, independent of
/// its runtime state (the event recorder and clock).
public struct GuardrailPolicy: Sendable {
    public let piiDetectors: [any PIIDetector]
    public let contentPolicyRules: [any ContentPolicyRule]
    public let redactionPlaceholder: @Sendable (PIICategory) -> String

    public init(
        piiDetectors: [any PIIDetector] = GuardrailPolicy.defaultPIIDetectors,
        contentPolicyRules: [any ContentPolicyRule] = [],
        redactionPlaceholder: @escaping @Sendable (PIICategory) -> String = { "[REDACTED:\($0.rawValue)]" }
    ) {
        self.piiDetectors = piiDetectors
        self.contentPolicyRules = contentPolicyRules
        self.redactionPlaceholder = redactionPlaceholder
    }

    /// The built-in, regex-based detectors for common PII categories.
    public static let defaultPIIDetectors: [any PIIDetector] = [
        EmailAddressDetector(),
        PhoneNumberDetector(),
        CreditCardDetector(),
        SocialSecurityNumberDetector()
    ]
}
