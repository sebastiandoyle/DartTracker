# DartTracker

A darts scoring app that does the maths so you can focus on throwing. X01 game tracking, smart checkout suggestions, and a variations guide — built with SwiftUI for iOS.

## Features

- **X01 game modes** — 301, 501, 701 with 1-4 player support
- **Smart checkout calculator** — suggests optimal double-out paths from any score
- **Per-turn history** with running averages and statistics
- **Variations guide** — Cricket, Around the Clock, Killer with visual rule explanations
- **Game persistence** — resume interrupted games
- **Clean scoreboard UI** — designed for glanceable mid-game use

## Tech Stack

- SwiftUI
- SwiftData (game persistence)
- XcodeGen for project generation

## Getting Started

```bash
git clone https://github.com/sebastiandoyle/DartTracker.git
cd "Dart Tracker"
xcodegen generate
open DartTracker.xcodeproj
```

Requires Xcode 15+ and iOS 16+.

## Checkout Logic

The checkout calculator works backwards from your remaining score, finding all valid 3-dart combinations that end on a double. It prioritizes commonly used finishes (e.g., T20-T20-D20 for 180, T19-T16-D16 for 121) and displays them in order of conventional preference.

## License

MIT
