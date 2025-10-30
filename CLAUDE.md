# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CopyPrompt is a native macOS menu bar app (minimum macOS 14.0 Sonoma) for instant access to AI prompts via fuzzy search. It's a privacy-first, 100% local app with no network access, built with Swift/SwiftUI/AppKit.

**Bundle ID**: `com.copyprompt.CopyPrompt`

## Build Commands

### Development
```bash
# Open in Xcode
open CopyPrompt.xcodeproj

# Build from command line (Debug)
xcodebuild -scheme CopyPrompt -configuration Debug build

# Build from command line (Release)
xcodebuild -scheme CopyPrompt -configuration Release build
```

### Release Build
```bash
# Full release build with signing, notarization prep, and DMG creation
./Scripts/release.sh
```

The release script:
- Cleans and builds Release configuration
- Signs with Developer ID Application certificate (if available)
- Creates a DMG installer
- Generates SHA256 checksum
- Output: `release/CopyPrompt-1.0.0.dmg`

### Code Formatting & Linting
```bash
# Format Swift code (SwiftFormat required)
swiftformat .

# Lint Swift code (SwiftLint required)
swiftlint

# Install formatters
brew install swiftformat swiftlint
```

**Configuration**:
- `.swiftformat`: Max width 120, 4-space indent, Swift 5.9
- `.swiftlint.yml`: Line length warning at 120, error at 200

## Architecture

### Core Design Principles
1. **Privacy-First**: No network entitlements, sandboxed, local-only JSON storage
2. **Performance**: Search ≤50ms per keystroke, Time-to-Copy p95 ≤3s
3. **Accessibility**: WCAG 2.2 AA compliant, full VoiceOver support, keyboard navigation
4. **Native macOS**: Uses NSStatusItem, NSPanel with vibrancy, respects dark/light mode

### Application Structure

```
CopyPromptApp (SwiftUI App)
  └─ AppDelegate (NSApplicationDelegate)
       ├─ PromptStore (ObservableObject) - Data persistence & CRUD
       ├─ StatusBarController - Menu bar integration
       │    ├─ TranslucentPanel - Search dropdown window
       │    └─ AppMenuManager - Right-click context menu
       └─ SettingsView - Prompt management UI
```

### Key Components

**Data Layer** (`Services/`):
- `PromptStore.swift`: JSON persistence with atomic writes, automatic backups (`.bak`), schema versioning, migration support
  - Location: `~/Library/Application Support/CopyPrompt/data.json`
  - Auto-backup before save: `data.json.bak`
  - Schema version tracking for future migrations

- `FuzzySearchEngine.swift`: Diacritic-insensitive fuzzy matching with scoring
  - Title matches weighted 2x vs body (1x)
  - Consecutive character bonus for better relevance
  - Query normalization: `.folding(options: .diacriticInsensitive, locale: .current).lowercased()`

- `Clipboard.swift`: NSPasteboard wrapper for plain text copy
- `AppPreferences.swift`: UserDefaults wrapper (e.g., pinned count)
- `LoginItemManager.swift`: SMAppService integration for launch-on-login
- `Metrics.swift`: Opt-in local performance tracking (Time-to-Copy, search latency)

**UI Layer** (`Features/`):
- `StatusBar/StatusBarController.swift`: Manages NSStatusItem, left-click for panel, right-click for menu
- `StatusBar/TranslucentPanel.swift`: NSPanel subclass with NSVisualEffectView for translucency
- `StatusBar/AppMenuManager.swift`: Context menu (Settings, Quit)
- `Search/SearchView.swift`: Main search interface with live filtering
- `Search/SearchContainerView.swift`: Container managing search state
- `Search/SearchRowView.swift`: Individual prompt row rendering
- `Settings/SettingsView.swift`: CRUD interface for prompts (list + drag reorder + forms)

**Models** (`Models/`):
- `Prompt.swift`: Core model (id, title, body, position, updatedAt)
- `PromptList.swift`: Container with schema versioning for migrations

### Data Flow

1. **App Launch**:
   - `AppDelegate.applicationDidFinishLaunching(_:)` loads prompts via `PromptStore.load()`
   - Creates `StatusBarController` and shows privacy notice if first run

2. **Search & Copy**:
   - User clicks status bar icon → `StatusBarController.togglePanel()` shows `TranslucentPanel`
   - User types → `FuzzySearchEngine.search(query:in:)` filters prompts
   - User clicks/presses Enter → `Clipboard.copy(_:)` copies to pasteboard, panel closes

3. **Prompt Management**:
   - Settings window shows list from `PromptStore.prompts` (sorted by `position`)
   - Add/edit/delete triggers `PromptStore.add/update/delete()` → atomic save to JSON
   - Drag reorder triggers `PromptStore.reorder(from:to:)` → updates `position` fields

### Performance Considerations

- **Search**: O(n×m) where n=prompts, m=query length. Target <50ms on 200 prompts
- **Storage**: Atomic writes with backup to prevent data loss
- **Memory**: Entire prompt list held in memory (<100 MB target)
- **Lazy UI**: SwiftUI List handles large lists efficiently

### Testing & Profiling

Refer to these docs for QA and performance:
- `QA_TEST_PLAN.md`: Comprehensive functional/accessibility/edge case testing
- `PROFILING.md`: Instruments guide for CPU/memory/I/O profiling
- `LAUNCH_CHECKLIST.md`: Pre-release verification steps

### Release & Distribution

See `RELEASE.md` for:
- Code signing with Developer ID Application
- Notarization via `xcrun notarytool`
- DMG creation and distribution workflow

## Common Development Tasks

### Adding a New Prompt Field
1. Update `Prompt.swift` model
2. Update `PromptList.swift` schema version if needed
3. Add migration logic in `PromptStore.migrate(_:to:)`
4. Update UI in `Settings/SettingsView.swift`

### Modifying Search Algorithm
- Edit `FuzzySearchEngine.swift`
- Adjust `titleWeight`/`bodyWeight` for scoring
- Test with metrics enabled in Settings

### Changing UI Layout
- Menu bar panel: `StatusBar/TranslucentPanel.swift`
- Search interface: `Search/SearchView.swift`
- Settings window: `Settings/SettingsView.swift`

### Performance Optimization
1. Enable metrics in Settings UI
2. Use Instruments (see `PROFILING.md`)
3. Target: Menu open <150ms, search <50ms, copy <50ms

## Important Notes

- **No Network Access**: App is sandboxed with no network entitlements. Never add network calls.
- **Atomic Saves**: All writes go through `PromptStore.save()` which creates backups and uses `.atomic` write option.
- **Schema Migrations**: When changing data model, increment `currentSchemaVersion` and add migration logic.
- **Accessibility**: All UI elements must have accessibility labels and keyboard support.
- **Privacy**: No analytics/telemetry except opt-in local metrics stored at `~/Library/Application Support/CopyPrompt/metrics.json`.

## Key Files to Know

- `CopyPromptApp.swift` - App entry point, AppDelegate, privacy notice
- `Services/PromptStore.swift` - All data persistence logic
- `Services/FuzzySearchEngine.swift` - Search ranking algorithm
- `Features/StatusBar/StatusBarController.swift` - Menu bar integration
- `Scripts/release.sh` - Automated release build pipeline
