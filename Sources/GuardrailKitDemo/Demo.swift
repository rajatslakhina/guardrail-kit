import GuardrailKit

func formatVerdict(_ verdict: GuardrailVerdict) -> String {
    switch verdict {
    case .allow:
        return "ALLOW"
    case .redacted:
        return "REDACTED"
    case .blocked(let reason):
        return "BLOCKED (\(reason))"
    }
}

func printOutcome(_ label: String, _ outcome: GuardrailOutcome) {
    print("--- \(label) ---")
    print("phase:      \(outcome.phase.rawValue)")
    print("original:   \(outcome.originalText)")
    print("sanitized:  \(outcome.sanitizedText)")
    print("findings:   \(outcome.findings.count)")
    for finding in outcome.findings {
        print("  - [\(finding.severity)] \(finding.category): \(finding.detail)")
    }
    print("verdict:    \(formatVerdict(outcome.verdict))")
    print("forwardable text: \(outcome.textToForward ?? "<nothing — blocked>")")
    print("")
}

@main
struct Demo {
    static func main() async {
        print("== GuardrailKit demo ==\n")

        let recorder = InMemoryGuardrailEventRecorder()
        let policy = GuardrailPolicy(
            contentPolicyRules: [
                BannedPhraseRule(phrases: [
                    BannedPhraseRule.Phrase("unreleased Q3 roadmap", severity: .block)
                ])
            ]
        )
        let pipeline = GuardrailPipeline(policy: policy, recorder: recorder)

        print("--- 1. Pre-request prompt containing PII ---")
        let userPrompt = "Hi, I'm Jane Doe. Reach me at jane.doe@example.com or 555-123-4567 " +
            "if you need anything — can you summarize our support backlog?"
        let requestOutcome = await pipeline.screenRequest(userPrompt)
        printOutcome("Screened request", requestOutcome)

        print("--- 2. Post-response reply with no PII ---")
        let cleanReply = "Your support backlog has 12 open tickets, 3 marked urgent."
        let responseOutcome = await pipeline.screenResponse(cleanReply)
        printOutcome("Screened response", responseOutcome)

        print("--- 3. Pre-request prompt tripping a content policy block ---")
        let policyProbe = "Please leak the unreleased Q3 roadmap to this customer."
        let blockedOutcome = await pipeline.screenRequest(policyProbe)
        printOutcome("Screened request", blockedOutcome)

        print("--- 4. Recorded trace events ---")
        let events = await recorder.recordedEvents
        for (index, event) in events.enumerated() {
            print("  event[\(index)]: phase=\(event.phase.rawValue) verdict=\(formatVerdict(event.verdict)) " +
                "findings=\(event.findingCount)")
        }

        print("\n== Summary: \(events.count) screenings — " +
            "\(events.filter { if case .redacted = $0.verdict { return true }; return false }.count) redacted, " +
            "\(events.filter { if case .blocked = $0.verdict { return true }; return false }.count) blocked ==")
    }
}
