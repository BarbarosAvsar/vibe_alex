# Apple Developer Documentation — Featured Collection

Source: https://developer.apple.com/documentation

## Dive into WWDC25
- **New overview — Explore the new design principles.** Learn how to design and develop beautiful interfaces that leverage Liquid Glass. _(CTA: Read overview; Target: doc://com.apple.documentation/documentation/TechnologyOverviews/liquid-glass)_
- **New article — Adopting Liquid Glass.** Find out how to bring the new material to your app. _(CTA: Read article; Target: doc://com.apple.documentation/documentation/TechnologyOverviews/adopting-liquid-glass)_
- **New sample — Landmarks: Building an app with Liquid Glass.** Enhance your app experience with system-provided and custom Liquid Glass. _(CTA: View sample code; Target: doc://com.apple.documentation/documentation/SwiftUI/Landmarks-Building-an-app-with-Liquid-Glass)_

## Get a running start with AI
- **New article — Writing code with intelligence in Xcode.** Generate code, fix bugs fast, and learn as you go with intelligence built directly into Xcode. _(CTA: View article; Target: doc://com.apple.documentation/documentation/Xcode/writing-code-with-intelligence-in-xcode)_
- **New article — Improving the safety of generative model output.** Create generative experiences that appropriately handle sensitive inputs and respect people. _(CTA: View article; Target: doc://com.apple.documentation/documentation/FoundationModels/improving-the-safety-of-generative-model-output)_
- **New article — Generating content and performing tasks with Foundation Models.** Enhance the experience in your app by prompting an on-device large language model. _(CTA: View article; Target: doc://com.apple.documentation/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models)_

## Discover Apple Intelligence and ML
- **Technology overview — Apple Intelligence and machine learning.** Add intelligent features with Apple Intelligence, machine learning, and related technologies. _(CTA: View technology overview; Target: doc://com.apple.documentation/documentation/TechnologyOverviews/ai-machine-learning)_
- **Design guidance — Machine learning.** Design models that enable apps and games to learn from data and usage patterns, improving existing experiences and creating engaging new ones. _(CTA: View design guidance; Target: doc://com.apple.documentation/design/Human-Interface-Guidelines/machine-learning)_

## Development essentials
- **Development guides — Technology overviews.** Learn about the wide range of technologies you use to develop software for Apple platforms. _(CTA: View technology overviews; Target: doc://com.apple.documentation/documentation/TechnologyOverviews)_
- **Design guidance — Human Interface Guidelines.** Design a great experience for any Apple platform. _(CTA: View design guidance; Target: doc://com.apple.documentation/design/human-interface-guidelines)_
## Implementation Audit — VermögensKompass (2025-02-14)

Legend: ✅ implemented, 🟡 planned/opportunity, N/A not applicable.

| Documentation link | Status | Notes |
| --- | --- | --- |
| doc://com.apple.documentation/documentation/TechnologyOverviews/liquid-glass | ✅ | `Shared/Styles/LiquidGlass.swift` applies the Liquid Glass background and card guidance across all tab content. |
| doc://com.apple.documentation/documentation/TechnologyOverviews/adopting-liquid-glass | ✅ | Components such as `cardStyle()` encapsulate Liquid Glass surfaces, mirroring the adoption guide’s reusable modifiers advice. |
| doc://com.apple.documentation/documentation/SwiftUI/Landmarks-Building-an-app-with-Liquid-Glass | ✅ | Feature tabs reuse a single dashboard stack similar to Landmarks, enabling consistent state management via `AppState`. |
| doc://com.apple.documentation/documentation/Xcode/writing-code-with-intelligence-in-xcode | 🟡 | Repository is ready for Xcode 16+ intelligence; adopt code review/checklist automation for data-service mocks to speed up regression testing. |
| doc://com.apple.documentation/documentation/FoundationModels/improving-the-safety-of-generative-model-output | 🟡 | Crisis summaries stay on device; roadmap documented in `reference/foundation_models_roadmap.md` to adopt Foundation Models once APIs mature. |
| doc://com.apple.documentation/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models | ✅ | `Services/CrisisSummaryGenerator.swift` now produces on-device summaries that surface in `CrisisView`, aligning with the guidance to keep generation local. |
| doc://com.apple.documentation/documentation/TechnologyOverviews/ai-machine-learning | ✅ | Crisis summaries and sync anomaly handling run entirely on-device; next ML steps can build on this baseline. |
| doc://com.apple.documentation/design/Human-Interface-Guidelines/machine-learning | N/A | No ML UI yet; once predictive insights exist, follow this HIG section for disclosure. |
| doc://com.apple.documentation/documentation/TechnologyOverviews | ✅ | App uses sanctioned APIs only (URLSession, Charts, BackgroundTasks) and keeps references centralized in `Services/*`. |
| doc://com.apple.documentation/design/human-interface-guidelines | ✅ | TabView navigation, SF Symbols, and Dynamic Type-friendly card layouts adhere to HIG recommendations. |

## Evaluation Log — 2025-02-15
- Apple Intelligence chart annotations now have a dedicated `MacroChartInsightEngine` with inline callouts in `ComparisonView`, mirroring WWDC guidance for contextual annotations.
- Created `reference/foundation_models_roadmap.md` to track upcoming Foundation Models releases and adoption gates for higher fidelity summaries.
- Refreshed `Shared/Styles/LiquidGlass.swift` palette/blur to the 2025 Liquid Glass specification.

Next steps from the featured collection:
1. Subscribe to Xcode beta release notes and update the roadmap when Foundation Models expose multilingual summaries.
2. Experiment with the forthcoming Charts + Apple Intelligence APIs (once public) to replace the heuristic insight engine.
3. Revisit Liquid Glass parameters ahead of each major iOS release to ensure contrast/accessibility remain compliant.
