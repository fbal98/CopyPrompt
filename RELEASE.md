# Release Build & Distribution Guide

## Prerequisites

### Apple Developer Account
- **Required**: Apple Developer Program membership ($99/year)
- **Team ID**: Found in App Store Connect → Membership
- **Certificates**: Developer ID Application certificate

### Tools
```bash
# Install create-dmg for DMG packaging
brew install create-dmg

# Xcode Command Line Tools
xcode-select --install
```

## Step 1: Prepare for Release

### Update Version Numbers
Edit `PromptDock/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Verify Bundle ID
Ensure bundle ID matches your provisioning profile:
```
com.promptdock.PromptDock
```

### Update Entitlements
Review `PromptDock/PromptDock.entitlements`:
- ✅ App Sandbox enabled
- ✅ Network client/server disabled
- ✅ Hardened Runtime ready

## Step 2: Release Build

### Build via Command Line
```bash
# Clean build folder
rm -rf build/

# Build Release configuration
xcodebuild clean build \
  -scheme PromptDock \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)" \
  DEVELOPMENT_TEAM="TEAM_ID"

# Verify build
ls -lh build/Release/PromptDock.app
```

### Build via Xcode
1. Open `PromptDock.xcodeproj`
2. Select "PromptDock" scheme
3. Product → Archive
4. Organizer → Distribute App → Developer ID → Export

## Step 3: Code Signing

### Verify Signature
```bash
codesign -dv --verbose=4 build/Release/PromptDock.app
```

**Expected output:**
- Format: app bundle with Mach-O universal (x86_64 arm64)
- CodeDirectory: Hardened Runtime enabled
- Sealed Resources: All resources signed
- Entitlements: App Sandbox, no network

### Re-sign if Needed
```bash
codesign --force --deep --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  --entitlements PromptDock/PromptDock.entitlements \
  build/Release/PromptDock.app
```

### Verify Entitlements
```bash
codesign -d --entitlements - build/Release/PromptDock.app
```

## Step 4: Notarization

### Create Archive for Notarization
```bash
# Create ZIP archive
ditto -c -k --sequesterRsrc --keepParent \
  build/Release/PromptDock.app \
  PromptDock.zip
```

### Store Notarization Credentials
```bash
# Create app-specific password in Apple ID account
# https://appleid.apple.com → Security → App-Specific Passwords

# Store in keychain
xcrun notarytool store-credentials "PromptDock-Notary" \
  --apple-id "your.email@example.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"
```

### Submit for Notarization
```bash
# Submit and wait for completion
xcrun notarytool submit PromptDock.zip \
  --keychain-profile "PromptDock-Notary" \
  --wait

# Check status
xcrun notarytool log <submission-id> \
  --keychain-profile "PromptDock-Notary"
```

### Staple Notarization Ticket
```bash
# Staple ticket to app bundle
xcrun stapler staple build/Release/PromptDock.app

# Verify stapling
xcrun stapler validate build/Release/PromptDock.app
spctl -a -vv -t install build/Release/PromptDock.app
```

**Expected:**
- `source=Notarized Developer ID`
- `accepted`

## Step 5: Create DMG

### Using create-dmg
```bash
# Create DMG with custom settings
create-dmg \
  --volname "PromptDock" \
  --volicon "PromptDock/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "PromptDock.app" 175 190 \
  --hide-extension "PromptDock.app" \
  --app-drop-link 425 185 \
  --no-internet-enable \
  "PromptDock-1.0.0.dmg" \
  "build/Release/PromptDock.app"
```

### Sign DMG
```bash
codesign --sign "Developer ID Application: Your Name (TEAM_ID)" \
  PromptDock-1.0.0.dmg

# Verify DMG signature
codesign -dv --verbose=4 PromptDock-1.0.0.dmg
```

### Notarize DMG
```bash
# Submit DMG
xcrun notarytool submit PromptDock-1.0.0.dmg \
  --keychain-profile "PromptDock-Notary" \
  --wait

# Staple to DMG
xcrun stapler staple PromptDock-1.0.0.dmg

# Verify
spctl -a -vv -t install PromptDock-1.0.0.dmg
```

## Step 6: Verification

### Test on Clean Machine
1. Mount DMG: `open PromptDock-1.0.0.dmg`
2. Drag PromptDock.app to Applications
3. Launch from Applications folder
4. Verify no Gatekeeper warnings
5. Test all functionality

### Security Checks
```bash
# Verify Gatekeeper acceptance
spctl --assess --verbose=4 --type execute /Applications/PromptDock.app

# Check quarantine attribute (should be none after stapling)
xattr -l /Applications/PromptDock.app

# Verify sandbox
codesign -d --entitlements - /Applications/PromptDock.app | grep sandbox
```

## Step 7: Distribution

### Create Release Notes
```markdown
# PromptDock 1.0.0

## Features
- Menu bar quick access to text prompts
- Fast fuzzy search
- Drag-to-reorder organization
- Privacy-first: Local-only, no network access
- Launch on login support
- Full keyboard navigation
- VoiceOver accessible

## Installation
1. Download PromptDock-1.0.0.dmg
2. Open DMG and drag PromptDock to Applications
3. Launch from Applications folder

## Requirements
- macOS 14.0 or later
- No network connection required
```

### Generate Checksum
```bash
shasum -a 256 PromptDock-1.0.0.dmg > PromptDock-1.0.0.dmg.sha256

# Display for users
cat PromptDock-1.0.0.dmg.sha256
```

### GitHub Release
1. Tag version: `git tag v1.0.0 && git push --tags`
2. Create release on GitHub
3. Upload artifacts:
   - `PromptDock-1.0.0.dmg`
   - `PromptDock-1.0.0.dmg.sha256`
4. Add release notes

## Troubleshooting

### "App is damaged" Error
- **Cause**: Not notarized or stapled
- **Fix**: Complete notarization and stapling steps

### Gatekeeper Blocks App
- **Cause**: Signature verification failed
- **Fix**: Right-click → Open on first launch, or verify signature

### Code Signing Issues
```bash
# List available identities
security find-identity -v -p codesigning

# Check certificate validity
security find-certificate -c "Developer ID Application"
```

### Notarization Failures
```bash
# Get detailed log
xcrun notarytool log <submission-id> \
  --keychain-profile "PromptDock-Notary" \
  developer_log.json

# Common issues:
# - Missing hardened runtime
# - Unsigned frameworks
# - Invalid entitlements
```

## Automation Script

See `Scripts/release.sh` for automated release build process.

## Version History

- **1.0.0** (Initial Release)
  - First public release
  - Core functionality complete
  - Privacy-first design
  - Accessibility support
