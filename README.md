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

1. Download `CopyPrompt-1.0.0.dmg` from [Releases](https://github.com/fbal98/CopyPrompt/releases)
2. Open the DMG and drag CopyPrompt to Applications
3. Launch from Applications folder
4. Grant accessibility permissions if prompted

### Build from Source

```bash
# Clone repository
git clone https://github.com/fbal98/CopyPrompt.git
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

1. **First Launch**: On first run, you'll see a privacy notice (all data stays local)
2. **Add Prompts**: Open Settings (Cmd+,) → click + New → enter title and body → Save
3. **Search & Copy**: Click menu bar icon → type to search → press Enter to copy → panel auto-closes

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

### Building

```bash
# Debug build
xcodebuild -scheme CopyPrompt -configuration Debug build

# Release build
./Scripts/release.sh
```

See [CLAUDE.md](CLAUDE.md) for complete architecture, project structure, and development guidelines.

## Troubleshooting

**App won't open**: The app needs to be notarized. If building from source, right-click the app and select "Open".

**Panel doesn't appear**: Check System Settings → Privacy & Security and grant accessibility permissions.

**Prompts not saving**: Ensure the app has write access to `~/Library/Application Support/CopyPrompt/`. Check Console.app for error messages.

**Slow search**: Enable metrics in Settings to view actual timings. If search is consistently > 50ms, file an issue.

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

- **Issues**: [GitHub Issues](https://github.com/fbal98/CopyPrompt/issues)
- **Discussions**: [GitHub Discussions](https://github.com/fbal98/CopyPrompt/discussions)
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
