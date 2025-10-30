# Privacy Policy

**Last Updated**: January 25, 2025
**Effective Date**: January 25, 2025

## Our Commitment

CopyPrompt is built with privacy as a core principle. We believe your data is yours, and yours alone.

## The Short Version

- **Zero data collection**: We don't collect, transmit, or store any of your data
- **No network access**: The app cannot connect to the internet
- **Local-only storage**: All data stays on your Mac
- **No analytics**: We don't track usage, crashes, or anything else
- **Open verification**: Sandboxing and network restrictions are verifiable

## Data Storage

### What We Store

CopyPrompt stores the following data **locally on your Mac**:

1. **Your Prompts**
   - Title and body text you enter
   - Position in list (for ordering)
   - Last updated timestamp
   - Location: `~/Library/Application Support/CopyPrompt/data.json`

2. **Your Preferences**
   - Number of pinned items (default: 3)
   - Launch on login preference (true/false)
   - Metrics enabled preference (true/false)
   - Privacy notice seen flag (true/false)
   - Location: `~/Library/Preferences/com.copyprompt.CopyPrompt.plist`

3. **Performance Metrics** (Optional, Opt-In Only)
   - Time-to-copy duration
   - Search keystroke duration
   - Event timestamps
   - Anonymous performance data
   - Location: `~/Library/Application Support/CopyPrompt/logs.json`

### What We Never Store

- ❌ Personal information (name, email, etc.)
- ❌ IP addresses
- ❌ Device identifiers
- ❌ Usage patterns
- ❌ Crash reports (unless you manually send them)

## Network Access

### Technical Implementation

CopyPrompt is built with **zero network capabilities**:

```xml
<!-- From CopyPrompt.entitlements -->
<key>com.apple.security.network.client</key>
<false/>
<key>com.apple.security.network.server</key>
<false/>
```

This means:
- The app **cannot** make HTTP/HTTPS requests
- The app **cannot** open network sockets
- The app **cannot** send or receive data over any network
- This is enforced by macOS at the system level

### Verification

You can verify this yourself:

```bash
# Check entitlements
codesign -d --entitlements - /Applications/CopyPrompt.app

# Monitor network activity (install Little Snitch or Wireshark)
# You will see zero network connections from CopyPrompt
```

## App Sandboxing

### What is Sandboxing?

CopyPrompt runs in a secure sandbox enforced by macOS:

- **File Access**: Limited to its own container
- **System Access**: Cannot access system files
- **Other Apps**: Cannot access other applications' data
- **Microphone/Camera**: No access
- **Location**: No access

### Container Path

The app can only read/write within:
```
~/Library/Containers/com.copyprompt.CopyPrompt/
~/Library/Application Support/CopyPrompt/
```

Everything else is off-limits.

## Optional Features

### Local Metrics (Opt-In)

If you enable "Local metrics" in Settings:

- **What's Collected**: Performance timing data (TTC, search duration)
- **How It's Used**: Displayed to you in the "View Stats" screen
- **Where It's Stored**: `~/Library/Application Support/CopyPrompt/logs.json`
- **Who Sees It**: Only you. It never leaves your device.
- **How to Disable**: Toggle off in Settings, click "Reset Metrics"

Even with metrics enabled, **no data is transmitted anywhere**.

### Launch on Login

If you enable "Launch on login":

- Uses macOS ServiceManagement API (SMAppService)
- Registers with macOS to launch at login
- No data collected or transmitted
- Can be disabled anytime in Settings

## Data Security

### Encryption

- **At Rest**: Data stored in your Mac's encrypted file system (if FileVault is enabled)
- **In Transit**: N/A - no network transmission
- **In Memory**: Standard macOS memory protection

### Backups

CopyPrompt creates local backups:
- `data.json.bak` - Created before each save
- Used for automatic recovery if main file is corrupted
- Stored in the same sandboxed container
- Never transmitted anywhere

### Data Migration

Schema versioning is included for future updates:
- Migrations happen locally
- Old data format is preserved during upgrade
- Backup is created before migration

## Third-Party Services

**We use zero third-party services.**

- ❌ No analytics (Google Analytics, Mixpanel, etc.)
- ❌ No crash reporting (Sentry, Bugsnag, etc.)
- ❌ No cloud sync (iCloud, Dropbox, etc.)
- ❌ No advertising
- ❌ No tracking pixels

## Your Rights

### Data Access

Your data is stored in plain JSON format:
```bash
# View your data
cat ~/Library/Application\ Support/CopyPrompt/data.json
```

### Data Portability

Export your data:
1. Navigate to `~/Library/Application Support/CopyPrompt/`
2. Copy `data.json`
3. Use it however you want (it's your data!)

### Data Deletion

Delete all data:
```bash
# Remove all CopyPrompt data
rm -rf ~/Library/Application\ Support/CopyPrompt/
rm ~/Library/Preferences/com.copyprompt.CopyPrompt.plist
```

Or simply delete the app and its data is gone.

## Children's Privacy

CopyPrompt does not collect data from anyone, including children under 13. Since there is no data collection, COPPA compliance is inherent.

## Changes to This Policy

If we ever change this privacy policy:

1. We'll update the "Last Updated" date above
2. Changes will be noted in release notes
3. Significant changes will be shown in the app

We will **never** add data collection without:
- Updating this policy
- Making it opt-in
- Providing clear notice

## Contact

For privacy questions or concerns:

- **GitHub Issues**: https://github.com/yourusername/promptDock/issues
- **GitHub Discussions**: https://github.com/yourusername/promptDock/discussions

## Legal Stuff

### Disclaimer

CopyPrompt is provided "as is" without warranty of any kind. We are not responsible for data loss (though we make backups).

### Jurisdiction

This privacy policy is governed by the laws of [Your Jurisdiction].

## Verification

### Open Source (Planned)

We plan to open-source CopyPrompt so you can:
- Review the code yourself
- Verify our privacy claims
- Contribute improvements
- Build your own version

### Security Audit

You can audit the app yourself:

```bash
# Verify signature
codesign -dv --verbose=4 /Applications/CopyPrompt.app

# Check entitlements
codesign -d --entitlements - /Applications/CopyPrompt.app

# Monitor file access
sudo fs_usage -f filesys CopyPrompt

# Monitor network (should be none)
sudo tcpdump -i any host <your IP> and process CopyPrompt
```

## Summary

**We don't collect your data because we can't.**

It's not just policy—it's architecture. The app is sandboxed with no network access, making data collection technically impossible.

Your prompts, your preferences, your metrics (if enabled) all stay on your Mac. Forever.

---

**Questions?** See [README.md](README.md) or open an issue on GitHub.
