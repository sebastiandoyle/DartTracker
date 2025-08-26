## DartTracker (iOS)

Modern, clean SwiftUI app to track darts games, calculate best checkouts, and learn popular game variations.

### Features
- Track X01 games (301/501/701), supports 1–4 players
- Smart checkout suggestions (finishes on doubles and bull)
- Clean, glanceable scoreboard and per-turn history
- Variations guide with visual explanations
- Local persistence of recent games and basic stats

### Requirements
- Xcode 15 or newer
- iOS 16.0+
- XcodeGen (optional) to generate the Xcode project

### Setup
1. Install XcodeGen if not installed:
```bash
brew install xcodegen
```
2. Generate the Xcode project:
```bash
cd "Dart Tracker"
xcodegen generate
```
3. Open the project:
```bash
open DartTracker.xcodeproj
```
4. Select an iOS Simulator and Build & Run (Cmd+R)

### App Store Submission checklist
1) Update identifiers and team
- Set `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` in `project.yml`
- Set `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`

2) App Icons
- Place a 1024x1024 PNG at `art/icon-1024.png`
- Run:
```bash
bash scripts/generate_icons.sh
```
- Verify `Assets.xcassets/AppIcon.appiconset` contains all required sizes

3) Info.plist
- `ITSAppUsesNonExemptEncryption` is set to `NO` (false) by default

4) Archive
- Open the Xcode project and choose Any iOS Device (arm64)
- Product → Archive, then Distribute to App Store Connect

5) Store listing
- Prepare screenshots (iPhone + iPad), privacy policy URL, description, keywords, support URL
- GitHub Pages (recommended): push this repo to GitHub and enable Pages with source: `docs/` directory
  - Privacy Policy URL: `https://<your-github-username>.github.io/<repo-name>/privacy-policy.html`
  - Support URL: `https://<your-github-username>.github.io/<repo-name>/support.html`




