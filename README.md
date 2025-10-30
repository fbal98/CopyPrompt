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

