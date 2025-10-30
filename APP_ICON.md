# App Icon Guide

## Requirements

The app icon should represent PromptDock's core functionality: a quick-access library of text prompts.

### Size Requirements
- **1024×1024 pixels** - Base size for macOS iconset
- **PNG format** with transparency
- **High resolution** (2x for Retina displays)

### Icon Design Concepts

**Option 1: Document Stack**
- Stack of documents/papers icon
- Represents library/collection of prompts
- macOS "doc.on.doc" system symbol as inspiration

**Option 2: Dock/Clipboard Hybrid**
- Clipboard with layered documents
- Represents both storage and quick access
- Clean, minimal design

**Option 3: Text Window**
- Window/panel with text lines
- Represents the search/copy interface
- Could show "T" or "ABC" for text

### Color Palette

- **Primary**: macOS accent color (adapts to user preference)
- **Background**: Subtle gradient or solid
- **Style**: Flat, modern, macOS Big Sur aesthetic
- Ensure good contrast for both light and dark menu bars

## Creating the Icon

### Using SF Symbols (Quick Option)
The app currently uses `doc.on.doc` system symbol in the menu bar. For a quick icon:

1. Open SF Symbols app
2. Find `doc.on.doc` or similar symbol
3. Export at large size
4. Add background/styling in design tool

### Professional Icon (Recommended)
Use a design tool like:
- **Sketch** - macOS app icon templates available
- **Figma** - Free, web-based
- **Adobe Illustrator** - Professional option
- **Affinity Designer** - One-time purchase

### Icon Generator
After creating 1024×1024 PNG, use an iconset generator:
```bash
# Create iconset folder structure
mkdir PromptDock.iconset

# Generate all required sizes (16, 32, 128, 256, 512, 1024)
# Each at 1x and 2x resolutions

# Convert to .icns
iconutil -c icns PromptDock.iconset
```

## Installation

1. Create app icon (1024×1024 PNG)
2. Generate iconset with all sizes
3. Place in `PromptDock/Assets.xcassets/AppIcon.appiconset/`
4. Update `Contents.json` in AppIcon.appiconset
5. Rebuild project

## Current Status

The project structure includes `Assets.xcassets/` directory ready for the app icon.

The menu bar currently shows the system `doc.on.doc` symbol, which provides a clean, recognizable appearance that fits with macOS design language.

## Notes on Visual Polish

The app already includes:

- ✅ **NSVisualEffectView** - `.hudWindow` material for translucent panel
- ✅ **Dark/Light Mode** - All colors use system semantic colors that adapt
- ✅ **Vibrancy** - Background blur with `behindWindow` blending
- ✅ **Consistent Spacing** - 8/12/16/20pt rhythm throughout
- ✅ **Typography** - System font with appropriate weights
- ✅ **Accessibility** - WCAG AA contrast ratios with semantic colors

## Testing Appearance

1. **Light Mode**
   - System Settings → Appearance → Light
   - Verify panel readability
   - Check button contrast

2. **Dark Mode**
   - System Settings → Appearance → Dark
   - Verify panel readability
   - Check button contrast

3. **Different Wallpapers**
   - Test with light/dark/colorful backgrounds
   - Verify vibrancy effect works well
   - Check menu bar icon visibility

4. **Accessibility**
   - System Settings → Accessibility → Display
   - Test with "Increase Contrast"
   - Test with "Reduce Transparency"

The semantic color system ensures the app adapts properly to all these settings automatically.
