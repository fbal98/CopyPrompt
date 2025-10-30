# CopyPrompt

**Your prompt library, one keystroke away.**

CopyPrompt is a macOS menu bar app that gives you instant access to your collection of text prompts. Search, copy, and paste with minimal friction.

## Features

- **🚀 Lightning Fast** - Fuzzy search with diacritic-insensitive matching
- **⌨️ Keyboard First** - Full keyboard navigation (arrow keys, Enter, Esc)
- **🔒 Privacy First** - 100% local, no network access, sandboxed
- **📱 Native macOS** - Translucent panels, dark/light mode, vibrancy effects
- **♿ Accessible** - VoiceOver support, WCAG 2.2 AA compliant
- **📊 Performance** - Time-to-Copy p95 ≤ 3s, search ≤ 50ms per keystroke

## Installation

### Download

1. Download `CopyPrompt-1.0.0.dmg` from [Releases](https://github.com/yourusername/CopyPrompt/releases)
2. Open the DMG and drag CopyPrompt to Applications
3. Launch from Applications folder
4. Grant accessibility permissions if prompted

### Build from Source

```bash
# Clone repository
git clone https://github.com/yourusername/CopyPrompt.git
cd CopyPrompt

# Install dependencies (optional: for linting)
brew install swiftlint swiftformat

# Open in Xcode
open CopyPrompt.xcodeproj

# Build and run (Cmd+R)
```

## Requirements

- macOS 14.0 (Sonoma) or later
- No network connection required
- ~50 MB disk space

## Quick Start

### First Launch

1. **Privacy Notice**: On first launch, you'll see a privacy notice explaining that all data stays local
2. **Add Prompts**: Open Settings (Cmd+,) and click the + button
3. **Search & Copy**: Click the menu bar icon, type to search, Enter to copy

### Adding Prompts

1. Click the PromptDock icon in the menu bar
2. Press Cmd+, or select PromptDock → Settings
3. Click the + New button
4. Enter a title and body
5. Press Save (or Enter)

### Using Prompts

1. Click the menu bar icon (or assign a global hotkey)
2. Type to search your prompts
3. Use ↑/↓ to select
4. Press Enter or click to copy
5. Panel auto-closes

## Keyboard Shortcuts

### Search Panel
- `↑` / `↓` - Navigate results
- `Enter` - Copy selected (or top) result
- `Esc` - Close panel
- `⌘,` - Open Settings

### Settings Window
- `⌘N` - New prompt
- `⌘W` - Close window
- `Delete` - Delete selected prompt (with confirmation)

## Settings

### Pinned Items
- Set how many top items appear as "Pinned" (0-10)
- Default: 3 items
- Drag to reorder prompts

### Launch on Login
- Toggle to start CopyPrompt automatically when you log in
- Uses macOS ServiceManagement (SMAppService)

### Local Metrics
- Opt-in performance tracking (stays on your device)
- View stats: Time-to-Copy (TTC), search performance
- Reset metrics anytime

## Privacy & Security

### Local-Only Storage
All your prompts are stored locally at:
```
~/Library/Application Support/CopyPrompt/data.json
```

### No Network Access
- App is sandboxed with no network entitlements
- Impossible for data to leave your device
- Verifiable: `codesign -d --entitlements - /Applications/CopyPrompt.app | grep network`

### Automatic Backups
- Backup created before every save: `data.json.bak`
- Automatic recovery if data file is corrupted
- Schema versioning for future-proof migrations

See [PRIVACY.md](PRIVACY.md) for complete privacy policy.

## Data Format

Prompts are stored as JSON:

```json
{
  "schemaVersion": 1,
  "prompts": [
    {
      "id": "UUID-HERE",
      "title": "Example Prompt",
      "body": "This is the full text that gets copied",
      "position": 0,
      "updatedAt": "2025-01-25T10:30:00Z"
    }
  ]
}
```

## Development

### Project Structure
```
PromptDock/
├── PromptDockApp.swift          # App entry point
├── Features/
│   ├── StatusBar/               # Menu bar integration
│   ├── Search/                  # Search UI and logic
│   └── Settings/                # Settings window
├── Services/
│   ├── PromptStore.swift        # JSON persistence
│   ├── FuzzySearchEngine.swift  # Search algorithm
│   ├── Clipboard.swift          # Pasteboard integration
│   ├── AppPreferences.swift     # User defaults
│   ├── LoginItemManager.swift   # Launch on login
│   └── Metrics.swift            # Performance tracking
├── Models/
│   ├── Prompt.swift             # Core data model
│   └── PromptList.swift         # Container with versioning
└── Views/
    ├── PrivacyNoticeView.swift  # First-run notice
    └── MetricsStatsView.swift   # Performance stats
```

### Building

```bash
# Debug build
xcodebuild -scheme PromptDock -configuration Debug build

# Release build
./Scripts/release.sh

# Run tests (when implemented)
xcodebuild -scheme PromptDock test
```

### Documentation

- [RELEASE.md](RELEASE.md) - Build, sign, and notarize for distribution
- [PROFILING.md](PROFILING.md) - Performance profiling guide
- [QA_TEST_PLAN.md](QA_TEST_PLAN.md) - Comprehensive test coverage
- [APP_ICON.md](APP_ICON.md) - Icon design guidelines
- [LAUNCH_CHECKLIST.md](LAUNCH_CHECKLIST.md) - Pre-release verification

## Troubleshooting

### App Won't Open
**Symptom**: "PromptDock is damaged and can't be opened"

**Solution**: The app needs to be notarized. If building from source:
1. Right-click the app
2. Select "Open"
3. Click "Open" in the security dialog

### Panel Doesn't Appear
**Symptom**: Clicking menu bar icon does nothing

**Solution**:
1. Check System Settings → Privacy & Security
2. Grant accessibility permissions if requested
3. Restart the app

### Prompts Not Saving
**Symptom**: Changes don't persist after restart

**Solution**:
1. Check file permissions: `ls -l ~/Library/Application\ Support/PromptDock/`
2. Ensure the app has write access to its container
3. Check Console.app for error messages

### Performance Issues
**Symptom**: Search feels slow with many prompts

**Solution**:
1. Enable metrics in Settings
2. View Stats to see actual timings
3. If > 50ms average, file an issue with details

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Follow existing code style (SwiftLint enforced)
4. Add tests for new functionality
5. Submit a pull request

## License

[License to be added]

## Credits

Built with:
- SwiftUI + AppKit for native macOS experience
- ServiceManagement for launch on login
- NSVisualEffectView for translucent panels

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/promptDock/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/promptDock/discussions)
- **Privacy Questions**: See [PRIVACY.md](PRIVACY.md)

## Roadmap

Potential future enhancements:
- iCloud sync (opt-in)
- Prompt categories/tags
- Import/export functionality
- Custom keyboard shortcuts
- Prompt templates with variables
- Dark/light menu bar icon variants

---

**Version**: 1.0.0
**Minimum macOS**: 14.0 (Sonoma)
**Architecture**: Universal (Apple Silicon + Intel)
