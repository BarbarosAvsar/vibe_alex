# VermögensKompass 2050

SwiftUI reference app targeting the newest iOS release (18) that turns the Vibecode prototype into a fully data-backed experience. \
Key capabilities:
- Live bullion pricing from GoldPrice.org, macro indicators (inflation, GDP, defense) via the World Bank API, and crisis monitoring from the USGS earthquake feed.
- NOAA severe-weather alerts, World Bank governance risk scores, and macro-financial stress detection expand the crisis board (storms, geopolitical, finance).
- Unified “Beratung anfragen” CTA that opens the user’s native Mail composer with configurable recipient, subject, and default body.
- Modern tabbed navigation (“Übersicht”, “Vergleich”, “Edelmetalle”, “Krisen”, “Beratung”) coated with the new Liquid Glass design guidance from WWDC25 and aligned with Apple’s Human Interface Guidelines / Clean Code for Swift conventions.
- Offline cache + BackgroundTasks-powered refresh keep the dashboard usable without connectivity and trigger local alerts via UserNotifications.
- Reference documentation in `reference/` summarizing the Featured Apple docs, App Store Review Guidelines, and the Clean Code rules applied during development.

## Getting Started
1. Open `VermogensKompass/VermogensKompass.xcodeproj` with Xcode 16+.
2. Select the `VermögensKompass` scheme and an iOS 18 simulator or device.
3. Build & run (`Cmd + R`). The dashboard loads real data on launch and supports pull-to-refresh.

## Configuration
- Update the email target in `VermogensKompass/VermogensKompass/Config/AppConfig.swift`.
- All networking happens client-side; no secrets are required because the APIs are public.

## Reference Material
- `reference/apple_documentation.md` — summary of every featured document on developer.apple.com/documentation.
- `reference/app_store_guidelines.md` — condensed list of all numbered App Store Review rules (sections 1–5).
- `reference/clean_code_swift.md` — actionable takeaways from the MaatheusGois Clean Code for Swift guide.

## Continuous Integration (Option 3 from setup discussion)
- All pushes and pull requests targeting `main` automatically trigger `.github/workflows/ci.yml` on GitHub Actions’ `macos-14` runners.
- The workflow selects the hosted `Xcode_15.4.app` toolchain (current default on macOS 14 runners), resolves packages, and executes `xcodebuild clean test` for the `VermogensKompass` scheme on the iPhone 15 simulator.
- To view results, open the “Actions” tab in GitHub; failing builds annotate commits/PRs with the exact step/command output.
