/// An actor-isolated guardrail pipeline: runs configured PII detectors and
/// content policy rules over text before it reaches an LLM provider
/// (``GuardrailPhase/preRequest``) and after a reply comes back
/// (``GuardrailPhase/postResponse``), redacting or blocking as needed and
/// recording a trace event for every screening.
public actor GuardrailPipeline {
    private let policy: GuardrailPolicy
    private let clock: any GuardrailClock
    private let recorder: (any GuardrailEventRecorder)?

    public init(
        policy: GuardrailPolicy = GuardrailPolicy(),
        clock: any GuardrailClock = SystemGuardrailClock(),
        recorder: (any GuardrailEventRecorder)? = nil
    ) {
        self.policy = policy
        self.clock = clock
        self.recorder = recorder
    }

    /// Screens `text` before it's sent to an LLM provider.
    public func screenRequest(_ text: String) async -> GuardrailOutcome {
        await screen(text, phase: .preRequest)
    }

    /// Screens `text` after it comes back from an LLM provider.
    public func screenResponse(_ text: String) async -> GuardrailOutcome {
        await screen(text, phase: .postResponse)
    }

    private func screen(_ text: String, phase: GuardrailPhase) async -> GuardrailOutcome {
        let piiMatches = mergedNonOverlappingMatches(in: text)
        var findings: [GuardrailFinding] = piiMatches.map {
            GuardrailFinding(
                category: $0.category.rawValue,
                severity: .warn,
                detail: "detected \($0.category.rawValue)"
            )
        }
        findings.append(contentsOf: policy.contentPolicyRules.compactMap { $0.evaluate(text) })

        let sanitizedText = redact(text, matches: piiMatches)
        let verdict = decideVerdict(findings: findings, wasRedacted: !piiMatches.isEmpty)

        let outcome = GuardrailOutcome(
            phase: phase,
            originalText: text,
            sanitizedText: sanitizedText,
            findings: findings,
            verdict: verdict
        )

        if let recorder {
            await recorder.record(
                GuardrailEvent(timestamp: clock.now(), phase: phase, verdict: verdict, findingCount: findings.count)
            )
        }

        return outcome
    }

    private func mergedNonOverlappingMatches(in text: String) -> [PIIMatch] {
        let allMatches = policy.piiDetectors.flatMap { $0.findMatches(in: text) }
        let sorted = allMatches.sorted { $0.range.lowerBound < $1.range.lowerBound }

        var kept: [PIIMatch] = []
        for match in sorted {
            if let last = kept.last, match.range.lowerBound < last.range.upperBound {
                continue
            }
            kept.append(match)
        }
        return kept
    }

    private func redact(_ text: String, matches: [PIIMatch]) -> String {
        guard !matches.isEmpty else { return text }

        var result = text
        for match in matches.sorted(by: { $0.range.lowerBound > $1.range.lowerBound }) {
            result.replaceSubrange(match.range, with: policy.redactionPlaceholder(match.category))
        }
        return result
    }

    private func decideVerdict(findings: [GuardrailFinding], wasRedacted: Bool) -> GuardrailVerdict {
        if let blocking = findings.first(where: { $0.severity == .block }) {
            return .blocked(reason: blocking.detail)
        }
        return wasRedacted ? .redacted : .allow
    }
}
