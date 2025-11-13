## Foundation Models Roadmap — VermögensKompass

Last updated: 2025-02-15

### Current integrations
- On-device heuristics drive crisis summaries (`Services/CrisisSummaryGenerator.swift`) and macro chart annotations (`Services/MacroChartInsightEngine.swift`).
- No network calls to third-party LLMs to preserve privacy guarantees.

### Monitoring plan
1. **WWDC + Apple Newsroom** — Track sessions labelled “Foundation Models” / “Apple Intelligence” each June; capture API diffs in this file.
2. **Xcode release notes** — After every Xcode beta, verify if new `FoundationModels` frameworks expose higher fidelity summarization or chart explanation endpoints.
3. **Feedback Assistant** — File/track FBs for any missing functionality (e.g., multilingual summaries) and note responses here.

### Adoption checklist for future APIs
- [ ] Evaluate memory/runtime impact on devices as small as iPhone 15.
- [ ] Update privacy policy to mention on-device generative summaries when the feature goes live.
- [ ] Add automated regression tests that validate fallback to heuristic summaries when the FM runtime is unavailable.

### Open questions
- Will Apple expose a dedicated API for chart annotation inside Charts? (watch `doc://com.apple.documentation/documentation/Charts` release notes.)
- Can crisis summaries cite sources automatically when using Apple Intelligence? pending API docs.
