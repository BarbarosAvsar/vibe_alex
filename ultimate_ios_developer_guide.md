# Ultimate iOS Developer Guide
- **Status:** Active living document
- **Audience:** iOS engineers, designers, PMs, QA
- **Last updated:** 2025-12-02
- **Scope:** From ideation to App Store submission across iPhone, iPad, and Apple silicon Macs
- **Sources included:** `prototype/Featured - Apple Developer Documentation.url`, `prototype/Guidelines - App Store - Apple Developer.url`, `reference/clean_code_swift.md`, Apple Developer docs linked below

## How to Use This Guide
- Start with the **Pillars** to frame product decisions.
- Use **Design** and **Accessibility & Inclusion** when shaping UI/UX.
- Apply **Architecture & Code Quality** and **Security & Privacy** while building features.
- Run **Performance & Diagnostics** before any beta or release.
- Follow **Release & Compliance** for App Store readiness.

## Pillars
- **Human-first:** Follow Apple’s Human Interface Guidelines (HIG) for clarity, hierarchy, and affordances.
- **Privacy by default:** Ask only for data you need, explain why, and secure it end to end.
- **Inclusive & accessible:** Ship Day 1 accessibility and localization (including right-to-left).
- **Quality & reliability:** Favor native frameworks (SwiftUI/UIKit), deterministic behavior, and testable architecture.
- **Platform fit:** Respect each device class (iPhone, iPad, Mac on Apple silicon) with adaptive layouts and input models.

## Design
### Navigation & Layout
- Prefer SwiftUI stacks, lists, and tab/navigation stacks; keep the back affordance predictable.
- Respect safe areas, size classes, Dynamic Type, and large titles; avoid fixed heights.
- For iPadOS, support multiwindow/Stage Manager, keyboard shortcuts, and pointer interactions.
- For Apple silicon Macs running iOS apps, ensure controls map to pointer/keyboard and avoid touch-only affordances.

### Visual & Interaction System
- Use SF Symbols for clarity; align icon weight with text weight.
- Motion: use `withAnimation` sparingly, respect Reduce Motion; pair haptics with clear intent.
- Color: meet contrast guidelines; define semantic roles (primary, secondary, warning, success).
- Provide clear empty states and offline states.

### Content Design
- Plain language, action-first CTAs, and concise onboarding.
- Support right-to-left (RTL) by using auto-mirroring assets and avoiding hardcoded insets.
- Inclusive imagery and copy; avoid gendered or culture-specific assumptions.

## Accessibility & Inclusion
- Implement VoiceOver labels, traits, and custom actions; ensure focus order matches visual flow.
- Dynamic Type: test at largest sizes; avoid clipped text; prefer flexible `LayoutPriority`.
- Color & contrast: validate light/dark variants; never rely on color alone to convey state.
- Interaction: support Switch Control, AssistiveTouch, and Reduce Motion/Transparency.
- Localization: use `String(localized:)`, `.stringsdict` for plurals, and Xcode’s export/import for translators. Test RTL using `Xcode > Scheme > Application Language > Right to Left`.
- Inclusion guidance: follow HIG “Inclusion” for respectful language, consent, and representation.

## Architecture & Code Quality
- Embrace value types and unidirectional data flow (State/Action/Effect) to simplify reasoning.
- Break features into modules; inject dependencies via protocols to keep tests cheap.
- Concurrency: prefer `async/await` with structured concurrency; isolate shared state via actors.
- Error handling: model domain errors, surface actionable recovery UI, and log with categories.
- Testing: fast unit tests, focused UI tests for core happy paths, and snapshot tests for key screens.
- **Clean code essentials** (from `reference/clean_code_swift.md`): meaningful names, single-responsibility functions/classes, avoid magic numbers, fail fast with guards, lean protocols, minimize side effects, keep formatting tidy, and write intent-revealing code that makes comments mostly unnecessary.

## Authentication, Privacy & Security
- **Passkeys & Sign in with Apple:** Use `AuthenticationServices` for passkeys; offer a username/password fallback only if required. Provide clear account recovery paths.
- **Keychain:** Store credentials and tokens with appropriate accessibility (e.g., `.afterFirstUnlockThisDeviceOnly` for background use, `.whenUnlocked` for foreground-only). Never store secrets in `UserDefaults`.
- **Sensitive data:** Keep everything on-device when possible. If syncing, encrypt in transit (TLS) and at rest server-side; minimize retention. Respect App Tracking Transparency if applicable.
- **Permissions:** Declare Info.plist purpose strings; request at point of need with succinct, user-benefit copy. Provide in-app explanations and settings deep links.
- **Privacy in UI:** Indicators for recording/screen capture; allow users to export/delete personal data where applicable.
- **Security frameworks:** Use CryptoKit for hashing/signing; prefer Secure Enclave for keys; validate receipts via App Store Server APIs; avoid private APIs.
- **Networking:** Enforce ATS; pin only when you own the backend and can rotate keys; handle captive portals gracefully.
- **User privacy (UIKit guidance):** Avoid unnecessary clipboard, location, microphone, camera, or photo library access. Show runtime affordances and handle denial paths elegantly.

## Data, State, and Offline
- Normalize remote responses into app models; keep parsing and rendering layers separated.
- Use `Codable` for structured payloads; validate server contracts with lightweight schema tests.
- Cache with clarity (TTL, eviction, max size). Use `FileManager` or `URLCache` appropriately; never cache secrets.
- Offline: queue mutations, reconcile on reconnect, and show sync status. Avoid silent data loss.

### External API Integration (URLSession)
- Build requests with `URLComponents` + `URLRequest`; set headers, HTTP method, timeouts, and cache policy explicitly.
- Use `URLSession.data(for:)`/`dataTask` with `async/await`; validate `HTTPURLResponse` status codes before decoding.
- Decode with `JSONDecoder` (set date strategies explicitly); map API DTOs into domain models before UI.
- Use `URLSessionConfiguration.default` for cacheable data and `.ephemeral` for sensitive flows; set `waitsForConnectivity` when appropriate.
- Keep API keys out of source control (Info.plist or env vars); proxy secrets server-side when possible.

### CRISIS External API Map
- **Metals pricing:** GoldPrice.org (`https://data-asg.goldprice.org/dbXRates/USD`) -> `MetalPriceService`.
- **Macro indicators:** World Bank API (`https://api.worldbank.org/v2/country/{ISO}/indicator/{code}`) -> `MacroIndicatorService` (inflation, GDP growth, defense spending).
- **Crisis feed:** NewsAPI.org (`/v2/top-headlines`, `/v2/everything`) + World Bank governance/GDP indicators -> `CrisisMonitorService`.
- **Market history:** Stooq CSV (`https://stooq.pl/q/d/l/?s={instrument}&i=d`) -> `MarketDataService` (equities, real estate, metals history).
- **FX rates:** Frankfurter (ECB-based, JSON) (`https://api.frankfurter.dev/v1/latest?base=EUR&symbols=USD`) -> `ExchangeRateService`.
- **Consultation submissions:** Midainvest contact endpoint (`https://api.midainvest.com/contact`) -> `ConsultationService`.
- **Benner cycle:** computed locally (explicit exception) -> `BennerCycleService`.

## Performance & Diagnostics
- Profile with Instruments (Time Profiler, Allocations, Energy, Network). Track cold/warm launch.
- Keep the main thread free: move I/O and heavy work off the main actor; batch UI updates.
- Rendering: minimize layout thrash; use `Canvas`/`Metal` judiciously; prefer lazy stacks/grids for large data.
- Memory: avoid retain cycles; audit `@StateObject` vs `@ObservedObject`; recycle images with `AsyncImage` policies.
- Logging: use `os.Logger` categories; redaction for PII; enable signposts around critical interactions.
- Performance resources: Xcode “Improving your app’s performance” docs; review iOS/iPadOS 18 release notes for regressions and API changes before each submission.

## Platform Fit
- **iPhone:** Thumb-friendly targets, tab bars for top-level, clear back navigation.
- **iPadOS 26:** Support multitasking, Stage Manager, pointer/keyboard shortcuts, and wide layouts (e.g., split view, sidebar).
- **macOS Tahoe (macOS 26):** Favor toolbar + menu commands, resizable windows, and keyboard-first navigation; use sidebars and tables where appropriate.
- **Apple silicon Macs:** Test with pointer/keyboard; ensure window resizing behaves; avoid gestures with no pointer analog.
- **watchOS 26:** Keep content glanceable, short, and tappable; use focused flows with minimal depth and avoid dense dashboards.
- **visionOS 26:** Default to windowed UI, keep content readable at distance, and avoid forced immersion; use immersive spaces only for clear spatial value.
- **Dynamic environments:** Handle orientation changes, varying refresh rates, and Low Power Mode gracefully.

### Adaptive Layout & Orientation
- Provide both vertical and horizontal layouts for key screens.
- Use `ViewThatFits` or `AnyLayout` to swap `VStackLayout` vs `HStackLayout` based on size class or width.
- Read `horizontalSizeClass` and `verticalSizeClass` to switch navigation patterns (tabs on compact, split view on regular).
- Avoid fixed widths/heights; rely on flexible stacks, grids, and `Layout` for adaptive composition.
- Test rotation, split view, and window resizing in previews and on-device.

## Framework & Feature How-Tos (checklists)
- **SwiftUI:** Use `NavigationStack`/`TabView`, leverage `@StateObject` for ownership, `@Environment` for dependencies, and `ViewThatFits`/`AnyLayout` for adaptive layouts. Test with Dynamic Type and RTL in previews.
- **UIKit:** Favor modern collection/table diffable data sources; adopt compositional layouts; keep view controllers thin; migrate to Auto Layout anchors/NSDiffableDataSource/Modern cell registrations.
- **Foundation & data:** Use `Codable` with validation; `URLComponents` for query building; `Measurement`/`DateComponentsFormatter` for units; `FormatStyle` APIs for localization-friendly formatting.
- **Multi-platform targets:** Share core models/services in a Swift package or shared module; use `#if os(...)` and `@available` guards for platform-only code; keep platform-specific assets and Info.plist entries separate.
- **Concurrency:** Prefer `async/await` and `Task` groups; confine shared state to actors; bridge callbacks with `CheckedContinuation`; cancel work on disappear.
- **Networking:** Use `URLSession` with `URLSessionConfiguration.ephemeral` for sensitive flows; prefer `HTTPURLResponse` status checks; adopt `NWConnection`/`Network` framework for sockets; backoff and retry with jitter.
- **Persistence:** Core Data/CloudKit for structured sync; `FileManager` for blobs; `Keychain` for secrets; make migrations idempotent and tested.
- **Core Data:** Model versioning and lightweight/heavyweight migrations; use background contexts with parent/child merges; avoid main-thread fetches; batch delete/update for large sets; add fetched results controllers or diffable data sources for UI syncing.
- **CloudKit:** Design public vs private databases; prefer CKSubscriptions over polling; handle partial failures and quota; protect PII by using the private database; use CKAsset for large blobs; provide user-visible sync state and conflict resolution rules.
- **Widgets & Live Activities:** Build with WidgetKit; keep timelines lightweight; avoid network in the widget extension; use ActivityKit for glanceable, real-time updates with proper lifetimes.
- **App Intents & Shortcuts:** Use AppIntents for Siri/Shortcuts/Spotlight actions; declare entities, provide localized vocabulary, and respect privacy (no hidden side effects).
- **Notifications:** Prefer rich content with Notification Service Extensions; respect Focus/interrupt levels; provide per-topic toggles and clear explanations.
- **App Clips:** Keep under 10 MB, single CTA, and seamless handoff to the full app; deep link to matching state.
- **Live content & streaming:** Use `AVPlayer`/HLS; honor AirPlay/PiP; handle DRM with FairPlay when required; provide fallback for offline.
- **Maps & location:** Request minimal accuracy, adopt `CLLocationPushServiceExtension` for silent updates, and explain background usage; use MapKit/MapKit JS for maps, avoid private tile services without permission.
- **Camera & photos:** Use `PHPickerViewController` instead of direct library access when possible; prefer `AVFoundation` capture with privacy overlays; handle low-light/permissions gracefully.
- **Passkeys & authentication:** Rely on `ASAuthorizationController` flows; store credential IDs securely; provide device-local sign-out; consider `ASWebAuthenticationSession` for OAuth with ephemeral sessions.
- **Payments & StoreKit 2:** Use `Product.products(for:)`, `Transaction.updates`, and `Transaction.currentEntitlements`; localize price displays; support Family Sharing/Ask to Buy; expose restore purchases.
- **Game & graphics:** Use Metal for performance-critical graphics; GameController for input; Game Center for achievements/leaderboards; respect frame pacing and energy budgets.
- **Metal:** Prefer argument buffers and resource heaps for efficiency; use MTKView/MetalFX where applicable; tune tile/compute workloads with GPU counters; fall back gracefully on older GPUs.
- **ML & intelligence:** Use Core ML/MLC/ANE where available; run on-device; fall back gracefully; include model cards and update paths; avoid privacy-invasive inference without consent.
- **Vision:** Use Vision requests for detection/classification; run on background queues; validate confidence thresholds; redact faces/license plates when required; respect on-device processing first.
- **AR & spatial:** Use ARKit/RealityKit; test lighting/anchors; provide coaching overlays; handle motion sickness (stabilized camera, low-latency).
- **Enterprise & device management:** Honor managed app config keys; separate personal vs managed data; respect data separation and MDM restrictions.
- **Media (AVFoundation):** Use capture sessions with proper session presets; manage camera/mic permissions with inline rationale; handle interruptions/route changes; use `AVAssetDownloadURLSession` for offline HLS; prefer HEVC/ProRes where supported and provide fallbacks.
- **Location & maps:** Request `whenInUse` by default; add `always` only with clear benefit; minimize high-accuracy use; throttle updates; show indicators; use geofences sparingly; MapKit for maps/search, avoid custom tiles without permission.

## Background Execution & Notifications
- **Background tasks (BackgroundTasks):** Use `BGAppRefreshTask` for lightweight refresh and `BGProcessingTask` for heavier work; declare permitted task identifiers; schedule with earliest/budget-aware timing; cancel when not needed; keep tasks short and idempotent; respect power/thermal limits.
- **Push vs pull:** Prefer server-driven pushes to wake background work; fall back to opportunistic refresh; avoid timers for polling.
- **Location/background modes:** Request only necessary modes; provide in-app rationale; surface indicators; avoid continuous high-accuracy tracking unless essential.
- **UserNotifications framework:** Define categories/actions; support provisional/auth ephemeral prompts; use interruption levels responsibly; localize titles/bodies; attach media via notification service extensions with strict size/time budgets.
- **APNs hygiene:** Keep payloads lean; use collapse IDs and mutable-content judiciously; handle token rotation; verify device targets; avoid user-identifiable data in payloads.

## Testing & Quality Engineering
- **Unit tests:** Cover pure logic and reducers; keep fast (<100 ms); use protocol fakes instead of network.
- **UI tests:** Automate critical paths (onboarding, auth, purchase, restore, primary create/read/update flows); seed fixtures; use accessibility identifiers.
- **Snapshot tests:** Guard against visual regressions on key screens, states, and appearances.
- **Performance tests:** Track launch time, scroll hitches, and memory; gate on budget thresholds; run on representative devices/OS versions.
- **Security tests:** Validate ATS, certificate handling, Keychain accessibility, and no secret leakage to logs or pasteboard.
- **Resilience:** Fuzz inputs, test airplane mode/poor networks, background/foreground transitions, and permission denial paths.
- **Automation:** Run CI on pull requests with lint (SwiftLint/format), tests, and coverage gates; run nightly longer suites (UI/perf).

## Tooling & Delivery
- **Xcode discipline:** Use schemes for release/debug with proper signing; enable static analyzer; treat warnings as errors in CI.
- **Build & CI:** Use `xcodebuild`/`xcodebuild test` or `xcodebuild test-without-building`; cache DerivedData; sign via automatic signing or `xcodebuild -exportArchive` with a signing config.
- **Debugging:** Leverage Instruments (Leaks, Allocations, Time Profiler, Network), View Debugger, Memory Graph; use `os_signpost` for critical spans.
- **Localization pipeline:** Use Xcode export/import; maintain `.stringsdict`; automate screenshot capture per locale.
- **Beta distribution:** TestFlight internal (fast) then external (with compliance notes); capture feedback via in-app diagnostics or TestFlight feedback.
- **Release trains:** Maintain branching strategy (e.g., main + release branches); hotfix with patch bumps; keep build numbers unique and monotonic.

## StoreKit & Business Models (how-to)
- Choose the correct product types (consumable, non-consumable, non-renewing, auto-renewable, subscriptions with offers).
- Implement eligibility logic for intro/offer pricing; surface terms inline; respect regional availability and tax implications.
- Handle refunds, revocation, and subscription status changes via `Transaction.updates`.
- Provide clear value propositions in paywalls; avoid dark patterns; let users manage subscriptions in-app with links to system settings.
- Comply with App Store Business Models docs for on-device vs off-device goods; avoid steering and price obfuscation.
- **App Store Server API & notifications:** Verify receipts server-side, process App Store Server Notifications v2, and reconcile entitlements gracefully; secure server endpoints and rotate keys.

## Privacy & Data Governance (deep dive)
- Maintain a data inventory: what is collected, purpose, retention, and where stored. Reflect it in the privacy manifest and policy.
- Use Privacy Nutrition Labels accurately; ensure runtime behavior matches disclosure.
- Minimize identifiers; prefer system IDs (e.g., `CKRecord.ID`, `DeviceCheck`) over custom tracking.
- Honor deletion/export requests; provide in-app controls for data sharing and analytics opt-in.
- For kids/education apps, comply with COPPA/local laws; avoid tracking; use the Kids Category rules.
- **Privacy manifests & required reason APIs:** Ship a privacy manifest declaring data types accessed; include reasons for required reason APIs and audit use of dynamic or indirect API access; validate with Xcode and App Store Connect checks.
- **App Tracking Transparency (ATT):** Request tracking authorization only when needed, after explaining value; ensure SDKs respect the user’s ATT choice; remove tracking code paths when denied.
- **Platform integrity (App Attest/DeviceCheck):** Use App Attest or DeviceCheck to validate device/app integrity for fraud-sensitive flows; tie attestation to your backend with nonce verification; fail closed on invalid attestations.

## Domain Notes (patterns)
- **Health & fitness:** Use HealthKit with user consent; avoid storing PHI unencrypted; provide data provenance; follow ResearchKit/CareKit guidance when applicable.
- **Finance:** Strong auth, step-up verification for risky actions; avoid prefilled sensitive data; comply with regional financial rules; never cache credentials.
- **Media/creative:** Optimize AV pipelines; support background audio where appropriate; expose share/export with user control over metadata.
- **Education:** Support managed Apple IDs; offline-friendly content; respect classroom controls.
- **Enterprise/field:** Support poor connectivity/offline queues; MDM configs; audit logging without PII.

## Operations, Telemetry & Support
- **Logging:** Use `os.Logger` with categories/subsystems; redact PII; include build/version in every log payload.
- **Crash/error reporting:** Rely on system crash logs and App Store Connect metrics; if using third-party crash reporting, disclose it and strip PII.
- **Feature flags:** Use server-driven or local flags to de-risk launches; default to safe behavior.
- **Supportability:** Provide diagnostics export (redacted), contact/support entry points, and a status page link if services are required.

## Feature Playbooks
- **Onboarding:** Keep to 2–3 screens; defer permissions; add restore purchase/account recovery entries.
- **Payments:** Follow App Store business model rules; use StoreKit 2; disclose pricing clearly.
- **Notifications:** Ask after demonstrated value; provide in-app controls; use interruption levels responsibly.
- **Privacy-sensitive flows:** Show inline explanations before system prompts; provide “Not now” without penalty.
- **Passkeys:** Offer “Sign in with passkey” primary, show platform-provided sheets, and sync state across devices.

## Release & Compliance
- **Preflight checklist**
  - Design: HIG alignment, inclusive language, RTL, Dynamic Type, contrast checks.
  - Accessibility: VoiceOver labels, focus order, large text layouts, motion/flash sensitivity tests.
  - Localization: Strings exported/imported; screenshots for key locales; mirrored assets tested.
  - Security: Secrets in Keychain; ATS on; permissions justified; data minimization confirmed.
  - Performance: Instruments runs complete; cold start measured; energy impact acceptable.
  - Testing: Unit/UI tests green; crash-free beta metrics acceptable; analytics and privacy manifests validated.
- **App Store Review Guidelines (key clusters)** — see `prototype/Guidelines - App Store - Apple Developer.url` and `reference/app_store_guidelines.md` for full text.
  - Safety (1.x): no harmful, misleading, or exploitative content; moderate UGC.
  - Performance (2.x): use public APIs only; full functionality; accurate metadata/screenshots; efficient battery/network use.
  - Business (3.x): comply with in-app purchase rules; no hidden fees; clear subscriptions.
  - Design (4.x): native experience, not a web clip; adequate AR/keyboard/browser behaviors; avoid template spam.
  - Legal (5.x): honor IP, privacy, data use consent, and regional laws; truthful developer identity.
- **Submission**
  - Update version/build, release notes, and What’s New. Keep release notes honest about changes.
  - Attach privacy policy and data-use answers; ensure info matches in-app disclosures.
  - Upload correct screenshots and app previews per device class; follow metadata rules (no pricing in titles, no misleading claims).
  - Use TestFlight for 2–3 beta cycles; capture crash logs and fix regressions before final submission.
  - Review current iOS/iPadOS release notes and Apple’s business model rules before each upload.

## Reference Links (authoritative starting points)
- Featured documentation hub: https://developer.apple.com/documentation (`prototype/Featured - Apple Developer Documentation.url`)
- App Store guidelines hub: https://developer.apple.com/app-store/guidelines/ (`prototype/Guidelines - App Store - Apple Developer.url`)
- HIG for iOS & inclusion: https://developer.apple.com/design/human-interface-guidelines/designing-for-ios and https://developer.apple.com/design/human-interface-guidelines/inclusion
- HIG for iPadOS, macOS, watchOS, visionOS: https://developer.apple.com/design/human-interface-guidelines/designing-for-ipados, https://developer.apple.com/design/human-interface-guidelines/designing-for-macos, https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos, https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos
- Design resources: https://developer.apple.com/design/resources/#ios-apps
- Accessibility: https://developer.apple.com/documentation/accessibility
- Right-to-left & localization: https://developer.apple.com/design/human-interface-guidelines/right-to-left and https://developer.apple.com/documentation/xcode/localization
- SwiftUI tutorials: https://developer.apple.com/tutorials/swiftui/
- Develop in Swift: https://developer.apple.com/tutorials/develop-in-swift/welcome-to-develop-in-swift-tutorials
- SwiftUI adaptive layout: https://developer.apple.com/documentation/swiftui/viewthatfits, https://developer.apple.com/documentation/swiftui/anylayout, https://developer.apple.com/documentation/swiftui/layout, https://developer.apple.com/documentation/swiftui/environmentvalues/horizontalsizeclass, https://developer.apple.com/documentation/swiftui/environmentvalues/verticalsizeclass
- Privacy & security: https://developer.apple.com/documentation/uikit/protecting-the-user-s-privacy, https://developer.apple.com/documentation/authenticationservices/supporting-passkeys, https://developer.apple.com/documentation/security/keychain-services/, https://developer.apple.com/documentation/security
- Foundation: https://developer.apple.com/documentation/foundation
- Xcode & performance: https://developer.apple.com/documentation/xcode/ and https://developer.apple.com/documentation/xcode/improving-your-app-s-performance
- Platform adaptation: https://developer.apple.com/ipados/get-started/, https://developer.apple.com/documentation/apple-silicon/running-your-ios-apps-in-macos, https://developer.apple.com/documentation/uikit/mac_catalyst, https://developer.apple.com/documentation/watchkit, https://developer.apple.com/documentation/watchconnectivity, https://developer.apple.com/documentation/visionos
- App Store operations: https://developer.apple.com/app-store/submitting/, https://developer.apple.com/app-store/business-models/
- Review guidelines detail: https://developer.apple.com/app-store/review/guidelines/#design and https://developer.apple.com/app-store/review/guidelines/
- Release notes: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-26-release-notes, https://developer.apple.com/documentation/watchos-release-notes/watchos-26-release-notes, https://developer.apple.com/documentation/visionos-release-notes/visionos-26-release-notes, https://developer.apple.com/documentation/macos-release-notes/macos-26-release-notes
- Community & learning: https://developer.apple.com/videos/all-videos/ and https://developer.apple.com/forums/
- Clean code for Swift: `reference/clean_code_swift.md` (local extract) and source https://github.com/MaatheusGois/clean-code-swift
- Privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
- App Tracking Transparency: https://developer.apple.com/documentation/apptrackingtransparency/
- Background tasks: https://developer.apple.com/documentation/backgroundtasks
- Notifications: https://developer.apple.com/documentation/usernotifications
- Platform integrity: https://developer.apple.com/documentation/devicecheck
- App Store Server API: https://developer.apple.com/documentation/appstoreserverapi
- Core Data: https://developer.apple.com/documentation/coredata
- CloudKit: https://developer.apple.com/documentation/cloudkit
- Core ML: https://developer.apple.com/documentation/coreml
- Vision: https://developer.apple.com/documentation/vision
- Metal: https://developer.apple.com/documentation/metal
- AVFoundation: https://developer.apple.com/documentation/avfoundation
- MapKit: https://developer.apple.com/documentation/mapkit
- Core Location: https://developer.apple.com/documentation/corelocation

