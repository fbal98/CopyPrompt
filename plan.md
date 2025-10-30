**Progress:** 100%

**At-a-Glance Checklist**
- [x] P1-T1: Initialize Xcode macOS app project
- [x] P1-T2: Configure bundle ID, signing, sandbox, hardened runtime
- [x] P1-T3: Add dev tooling (SwiftLint, SwiftFormat) and CI skeleton
- [x] P2-T1: Implement menu bar status item and translucent panel
- [x] P2-T2: Build search UI (field, list, divider, scroll, clear ×)
- [x] P2-T3: Implement fuzzy, diacritic-insensitive search engine
- [x] P3-T1: Copy to clipboard on click/Enter (+ auto-close)
- [x] P3-T2: Keyboard navigation (↑/↓, Enter, Esc)
- [x] P3-T3: Hover highlight behavior and selection model
- [x] P4-T1: Define data model (Prompt) and schema
- [x] P4-T2: Implement JSON persistence (atomic read/write, app support path)
- [x] P4-T3: Settings window: list + Add/Edit/Delete (+ confirm)
- [x] P4-T4: Drag reorder + pinned divider + persistence
- [x] P5-T1: Launch-on-login via SMAppService (toggle in Settings)
- [x] P5-T2: Accessibility (VoiceOver labels, contrast, focus order)
- [x] P5-T3: App sandbox/privacy configuration and safeguards (no network)
- [x] P6-T1: Performance budgets and TTC instrumentation (local, opt-in)
- [x] P6-T2: Error handling, JSON recovery, and data migration stub
- [x] P6-T3: Memory/CPU profiling and optimizations
- [x] P7-T1: App icon and visual polish (vibrancy, dark/light)
- [x] P7-T2: Release build, signing, notarization, DMG packaging
- [x] P7-T3: Launch checklist verification and release artifacts
- [x] P8-T1: QA pass (WCAG 2.2 AA, TTC ≤ 3s p95, flows)
- [x] P8-T2: Docs (README, Privacy note) and versioning

**Phases**

**P1 — Project Setup**
- Goal: Create a minimal, signed, sandboxed macOS app project with dev tooling.
- Depends on: —
- Task List:
  - [x] [P1-T1](#p1-t1): Initialize Xcode macOS app project
  - [x] [P1-T2](#p1-t2): Configure bundle ID, signing, sandbox, hardened runtime
  - [x] [P1-T3](#p1-t3): Add dev tooling (SwiftLint, SwiftFormat) and CI skeleton

<a id="p1-t1"></a>
**P1-T1: Initialize Xcode macOS app project**
- Why: Establish the foundation for a macOS menu bar utility built with SwiftUI + AppKit.
- Inputs: PRD (`PRD.md`), Xcode 15+/macOS 14+.
- Outputs: `PromptDock.xcodeproj`, target `PromptDock`, minimal app that launches.
- Concrete Steps:
  1) Open Xcode → File → New → App; Name: “PromptDock”; Interface: SwiftUI; Life Cycle: SwiftUI App; Language: Swift; Platform: macOS.
  2) Save in repo root; ensure source control is on; target macOS 14.0.
  3) Create `PromptDock.entitlements` file.
  4) Add `Info.plist` overrides as needed (e.g., `LSApplicationCategoryType`).
- Acceptance Criteria:
  - App builds and runs (empty window or no window).
  - Project committed to repo; files under the repo root.

<a id="p1-t2"></a>
**P1-T2: Configure bundle ID, signing, sandbox, hardened runtime**
- Why: Required for distribution, sandboxed operation, and notarization.
- Inputs: Apple Developer Team, Bundle ID (e.g., `com.yourname.PromptDock`).
- Outputs: Signed, sandboxed target; Hardened Runtime enabled; entitlements present.
- Concrete Steps:
  1) In target Signing & Capabilities: set Team; set Bundle ID.
  2) Add capabilities: App Sandbox (no network, file write to App Support via container), User Selected File read/write OFF.
  3) Enable Hardened Runtime in Signing settings (Release).
  4) Create `PromptDock.entitlements` with `com.apple.security.app-sandbox` true.
- Acceptance Criteria:
  - Release build signs successfully.
  - `codesign -dv --verbose=4` shows Hardened Runtime and entitlements.

<a id="p1-t3"></a>
**P1-T3: Add dev tooling (SwiftLint, SwiftFormat) and CI skeleton**
- Why: Maintain code quality and consistency from the start.
- Inputs: Homebrew, optional GitHub Actions.
- Outputs: Config files: `.swiftlint.yml`, `.swiftformat`, optional `.github/workflows/ci.yml`.
- Concrete Steps:
  1) Install tools: `brew install swiftlint swiftformat`.
  2) Add basic `.swiftlint.yml` and `.swiftformat` to repo root.
  3) Add Run Script phases in Xcode for lint/format (non-fatal in Debug).
  4) Optional: Add CI workflow to run `xcodebuild build` and SwiftLint.
- Acceptance Criteria:
  - `swiftlint` and `swiftformat` run locally without errors.
  - CI builds the Debug scheme.

**P2 — Core Menu App & UI Shell**
- Goal: Implement status item + translucent dropdown panel and basic search UI.
- Depends on: P1.
- Task List:
  - [x] [P2-T1](#p2-t1): Implement menu bar status item and translucent panel
  - [x] [P2-T2](#p2-t2): Build search UI (field, list, divider, scroll, clear ×)
  - [x] [P2-T3](#p2-t3): Implement fuzzy, diacritic-insensitive search engine

<a id="p2-t1"></a>
**P2-T1: Implement menu bar status item and translucent panel**
- Why: Primary interaction model per PRD via NSStatusItem + NSPanel.
- Inputs: AppKit (NSStatusBar, NSStatusItem, NSPanel), SwiftUI hosting.
- Outputs: Clickable menu bar icon opens fixed-width translucent panel (search focused).
- Concrete Steps:
  1) Create `StatusBarController` bridging AppKit in Swift.
  2) Create `TranslucentPanel` using `NSPanel` + `NSVisualEffectView`.
  3) Host SwiftUI root view with `NSHostingView` inside the panel.
  4) Focus the search field on open; close on outside click.
- Code Snippet (sketch):
  ```swift
  final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private lazy var panel = TranslucentPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 420))
    func setup() {
      statusItem.button?.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "PromptDock")
      statusItem.button?.target = self
      statusItem.button?.action = #selector(toggle)
    }
    @objc private func toggle() { /* show/hide panel near status item */ }
  }
  ```
- Acceptance Criteria:
  - Clicking the icon opens the panel within 150 ms; search field focused.
  - Panel auto-closes when clicking outside or pressing Esc.

<a id="p2-t2"></a>
**P2-T2: Build search UI (field, list, divider, scroll, clear ×)**
- Why: Core UX for fast filtering and copy.
- Inputs: SwiftUI views; `List`/`ScrollView`; custom row.
- Outputs: Search field with clear (×), list capped to 10 visible rows, pinned divider.
- Concrete Steps:
  1) Create `SearchView` with `TextField`, clear button, and `ScrollView` of rows.
  2) Render “Pinned” divider above top N; “Others” divider below.
  3) Limit visible rows to 10 before vertical scrolling.
  4) Ensure hover highlight visuals (menu-style) and fixed width.
- Acceptance Criteria:
  - Clear (×) empties field and resets list.
  - Dividers render/persist correctly.

<a id="p2-t3"></a>
**P2-T3: Implement fuzzy, diacritic-insensitive search engine**
- Why: PRD requires fast (≤50 ms/keystroke) fuzzy search.
- Inputs: `Prompt` array; debounce optional (small delay) while keeping feel instant.
- Outputs: Pure Swift fuzzy matcher returning sorted indices.
- Concrete Steps:
  1) Normalize strings (lowercase, folding diacritics) with `folding(options:.diacriticInsensitive, locale: .current)`.
  2) Implement light-weight subsequence and score-based match (title-weighted > body).
  3) Unit test matcher with 200+ items, target ≤50 ms per keystroke.
  4) Update UI on each keystroke; no allocations hot-path.
- Acceptance Criteria:
  - Matcher returns expected top results; meets performance budget on 500 prompts.

**P3 — Interaction: Copy & Navigation**
- Goal: Make copying and navigation instantaneous and predictable.
- Depends on: P2.
- Task List:
  - [x] [P3-T1](#p3-t1): Copy to clipboard on click/Enter (+ auto-close)
  - [x] [P3-T2](#p3-t2): Keyboard navigation (↑/↓, Enter, Esc)
  - [x] [P3-T3](#p3-t3): Hover highlight behavior and selection model

<a id="p3-t1"></a>
**P3-T1: Copy to clipboard on click/Enter (+ auto-close)**
- Why: Core value—one action to copy, then return to workflow.
- Inputs: Selected or topmost result; NSPasteboard.
- Outputs: Plain text body copied; panel closes.
- Concrete Steps:
  1) Implement `Clipboard.copy(_ text: String)` using `NSPasteboard.general`.
  2) Wire row click and Enter key to copy selected/top result.
  3) Close panel immediately after copy; clear selection state.
- Acceptance Criteria:
  - Copy executes <50 ms; always plain text; panel closes.

<a id="p3-t2"></a>
**P3-T2: Keyboard navigation (↑/↓, Enter, Esc)**
- Why: Accessibility and speed without mouse.
- Inputs: Focused list; key handlers.
- Outputs: Predictable selection movement and activation.
- Concrete Steps:
  1) Maintain `selectedIndex` bound to list.
  2) Handle ↑/↓ to move selection; Enter to copy; Esc to close.
  3) When none selected, Enter copies topmost result.
- Acceptance Criteria:
  - Behavior matches PRD; no focus traps; VoiceOver compatible.

<a id="p3-t3"></a>
**P3-T3: Hover highlight behavior and selection model**
- Why: Visual confirmation of target action; menu-style UX.
- Inputs: Pointer hover events.
- Outputs: Hovered row highlights; keyboard selection also highlighted.
- Concrete Steps:
  1) Add hover tracking to rows; update `hoveredIndex`.
  2) Resolve visual state precedence: hovered > selected.
  3) Ensure no flicker while scrolling.
- Acceptance Criteria:
  - Smooth highlight on hover; consistent with Apple menu style.

**P4 — Persistence & Settings**
- Goal: Local JSON storage with CRUD and reorder in a Settings window.
- Depends on: P2, P3.
- Task List:
  - [x] [P4-T1](#p4-t1): Define data model (Prompt) and schema
  - [x] [P4-T2](#p4-t2): Implement JSON persistence (atomic read/write, app support path)
  - [x] [P4-T3](#p4-t3): Settings window: list + Add/Edit/Delete (+ confirm)
  - [x] [P4-T4](#p4-t4): Drag reorder + pinned divider + persistence

<a id="p4-t1"></a>
**P4-T1: Define data model (Prompt) and schema**
- Why: Single source of truth for prompts.
- Inputs: PRD schema in Appendix; Swift Codable.
- Outputs: `Prompt` struct and container `PromptList`.
- Concrete Steps:
  1) Create `Prompt` with `id: UUID`, `title: String`, `body: String`, `position: Int`, `updatedAt: Date`.
  2) Add `PromptList { var prompts: [Prompt] }`.
  3) Unit tests for encoding/decoding stability.
- Code Snippet:
  ```swift
  struct Prompt: Identifiable, Codable, Equatable { let id: UUID; var title: String; var body: String; var position: Int; var updatedAt: Date }
  struct PromptList: Codable { var prompts: [Prompt] }
  ```
- Acceptance Criteria:
  - JSON round-trips without loss; matches PRD example.

<a id="p4-t2"></a>
**P4-T2: Implement JSON persistence (atomic read/write, app support path)**
- Why: Reliable local storage under App Support.
- Inputs: FileManager, JSONEncoder/Decoder; path: `~/Library/Application Support/PromptDock/data.json`.
- Outputs: `PromptStore` service with load/save and autosave on edits.
- Concrete Steps:
  1) Resolve container path via `FileManager.urls(for:in:)` with `.applicationSupportDirectory` + `PromptDock`.
  2) Ensure directory exists; write atomically with `Data.write(options: .atomic)`.
  3) Save after every edit/reorder; debounce saves during rapid changes.
  4) Handle corruption by backup+restore (`data.json.bak`).
- Acceptance Criteria:
  - No data loss on quit; files created; backups rotate.

<a id="p4-t3"></a>
**P4-T3: Settings window: list + Add/Edit/Delete (+ confirm)**
- Why: Manage prompts outside the fast-copy flow.
- Inputs: SwiftUI window scene; editable list.
- Outputs: Dedicated Settings window with CRUD and confirm on delete.
- Concrete Steps:
  1) Add `SettingsWindow` with list (Title, Body) and buttons: `+ New`, `Delete`.
  2) Add inline editor or modal sheet for Add/Edit; Enter saves immediately.
  3) Prompt delete confirmation.
- Acceptance Criteria:
  - CRUD persists to JSON; Enter saves; UI updates instantly.

<a id="p4-t4"></a>
**P4-T4: Drag reorder + pinned divider + persistence**
- Why: User-defined priority; divider between pinned and others.
- Inputs: Reorder gesture; `position` field.
- Outputs: Drag-and-drop reorder stored in `position`; top N considered “Pinned”.
- Concrete Steps:
  1) Enable drag handles to reorder in Settings list.
  2) Update `position` consistently; reindex to keep dense order.
  3) Expose `Pinned count (N)` preference; default N=3 unless changed.
- Acceptance Criteria:
  - Reorder persists across launches; divider reflects N.

**P5 — System Integration & Safety**
- Goal: Integrate login item, accessibility, and sandbox/privacy safeguards.
- Depends on: P4.
- Task List:
  - [x] [P5-T1](#p5-t1): Launch-on-login via SMAppService (toggle in Settings)
  - [x] [P5-T2](#p5-t2): Accessibility (VoiceOver labels, contrast, focus order)
  - [x] [P5-T3](#p5-t3): App sandbox/privacy configuration and safeguards (no network)

<a id="p5-t1"></a>
**P5-T1: Launch-on-login via SMAppService (toggle in Settings)**
- Why: Required “Launch on login” per PRD.
- Inputs: ServiceManagement SMAppService API.
- Outputs: Toggle in Settings; enable/disable login item.
- Concrete Steps:
  1) Add checkbox “Launch on login”.
  2) Call `SMAppService.mainApp.register()/unregister()` accordingly.
  3) Persist preference in `UserDefaults`.
- Acceptance Criteria:
  - Login on next session when enabled; survives reboots.

<a id="p5-t2"></a>
**P5-T2: Accessibility (VoiceOver labels, contrast, focus order)**
- Why: PRD requires WCAG 2.2 AA + VoiceOver labels.
- Inputs: Accessibility Inspector; system appearance.
- Outputs: Labeled controls; proper focus chain; sufficient contrast.
- Concrete Steps:
  1) Add `accessibilityLabel` to icon, search, list, rows.
  2) Verify contrast on light/dark wallpapers; adjust materials if needed.
  3) Ensure keyboard-only navigation works end-to-end.
- Acceptance Criteria:
  - Passes WCAG AA checks; VoiceOver announces elements meaningfully.

<a id="p5-t3"></a>
**P5-T3: App sandbox/privacy configuration and safeguards (no network)**
- Why: Security & privacy promises in PRD.
- Inputs: Entitlements, runtime checks.
- Outputs: App sandboxed with no network entitlement; privacy note on first run.
- Concrete Steps:
  1) Verify network client entitlements are absent.
  2) Show one-time privacy notice (“Local only; no analytics unless enabled”).
  3) Confirm file access restricted to container App Support.
- Acceptance Criteria:
  - Network calls impossible; privacy note appears once; container paths only.

**P6 — Performance, Reliability, and Telemetry (Local)**
- Goal: Meet strict TTC, performance, and reliability targets with opt-in local logs.
- Depends on: P5.
- Task List:
  - [x] [P6-T1](#p6-t1): Performance budgets and TTC instrumentation (local, opt-in)
  - [x] [P6-T2](#p6-t2): Error handling, JSON recovery, and data migration stub
  - [x] [P6-T3](#p6-t3): Memory/CPU profiling and optimizations

<a id="p6-t1"></a>
**P6-T1: Performance budgets and TTC instrumentation (local, opt-in)**
- Why: Validate ≤3s Time-to-Copy (p95) and per-keystroke ≤50 ms.
- Inputs: Simple timer logs; local JSON log file.
- Outputs: Toggle “Enable local metrics (no content)” in Settings.
- Concrete Steps:
  1) Add lightweight timing around open, search, copy actions.
  2) Write summary stats to `~/Library/Application Support/PromptDock/logs.json`.
  3) Surface `Reset Metrics` button.
- Acceptance Criteria:
  - Metrics off by default; when on, TTC p95 ≤3s under 200+ prompts.

<a id="p6-t2"></a>
**P6-T2: Error handling, JSON recovery, and data migration stub**
- Why: Protect against data loss and future changes.
- Inputs: I/O errors, corrupted JSON, schema version.
- Outputs: Backup/restore, safe writes, schema versioning field.
- Concrete Steps:
  1) On save, also write `data.json.bak`.
  2) On load failure, attempt to parse backup and notify user.
  3) Add `schemaVersion` to container for future migrations.
- Acceptance Criteria:
  - Corruption recovers automatically from backup; user data preserved.

<a id="p6-t3"></a>
**P6-T3: Memory/CPU profiling and optimizations**
- Why: Meet <100 MB RAM and <10% CPU spikes.
- Inputs: Instruments (Time Profiler, Allocations).
- Outputs: Profiling notes and fixes (lazy filtering, caching normalized strings).
- Concrete Steps:
  1) Profile open/search/copy flows with 500 prompts.
  2) Cache normalized text; avoid intermediate arrays in hot path.
  3) Ensure SwiftUI updates minimal via `@StateObject`/`@ObservedObject` boundaries.
- Acceptance Criteria:
  - Meets performance and memory targets on reference machine.

**P7 — Packaging & Release**
- Goal: Produce signed, notarized DMG with polished UI and assets.
- Depends on: P6.
- Task List:
  - [x] [P7-T1](#p7-t1): App icon and visual polish (vibrancy, dark/light)
  - [x] [P7-T2](#p7-t2): Release build, signing, notarization, DMG packaging
  - [x] [P7-T3](#p7-t3): Launch checklist verification and release artifacts

<a id="p7-t1"></a>
**P7-T1: App icon and visual polish (vibrancy, dark/light)**
- Why: Final look-and-feel and discoverable brand.
- Inputs: AppIcon set; NSVisualEffectView materials.
- Outputs: AppIcon asset; tuned translucency for light/dark.
- Concrete Steps:
  1) Add `AppIcon.appiconset` to Assets.
  2) Test vibrancy/contrast on varying wallpapers; adjust materials.
  3) Ensure dark/light adapt automatically.
- Acceptance Criteria:
  - Crisp icons; readable controls in both appearances.

<a id="p7-t2"></a>
**P7-T2: Release build, signing, notarization, DMG packaging**
- Why: Secure distribution aligned with Apple requirements.
- Inputs: Developer ID certs; notarytool credentials.
- Outputs: Signed app bundle, notarized, stapled; DMG.
- Concrete Steps:
  1) Build Release: `xcodebuild -scheme PromptDock -configuration Release -derivedDataPath build`.
  2) Verify signature: `codesign -dv --verbose=4 build/Release/PromptDock.app`.
  3) Notarize: `xcrun notarytool submit PromptDock.zip --keychain-profile YOUR_PROFILE --wait`; then `xcrun stapler staple PromptDock.app`.
  4) Package DMG (e.g., `create-dmg`): `create-dmg PromptDock.dmg build/Release/PromptDock.app`.
- Acceptance Criteria:
  - Notarization success; stapled; DMG mounts and launches on a clean Mac.

<a id="p7-t3"></a>
**P7-T3: Launch checklist verification and release artifacts**
- Why: Ensure PRD launch checklist is satisfied.
- Inputs: PRD Launch Checklist section.
- Outputs: Completed checklist; release notes; version 1.0 tag.
- Concrete Steps:
  1) Walk the PRD checklist; verify each item.
  2) Create `RELEASE_NOTES.md` and Git tag `v1.0.0`.
  3) Attach DMG and checksum to release.
- Acceptance Criteria:
  - All launch checklist items checked; public artifact archived.

**P8 — QA & Documentation**
- Goal: Validate end-to-end quality and provide clear docs and privacy notes.
- Depends on: P7.
- Task List:
  - [x] [P8-T1](#p8-t1): QA pass (WCAG 2.2 AA, TTC ≤ 3s p95, flows)
  - [x] [P8-T2](#p8-t2): Docs (README, Privacy note) and versioning

<a id="p8-t1"></a>
**P8-T1: QA pass (WCAG 2.2 AA, TTC ≤ 3s p95, flows)**
- Why: Confirm the product meets the PRD acceptance criteria.
- Inputs: Accessibility Inspector; local logs; manual test scripts.
- Outputs: QA report with screenshots and metrics.
- Concrete Steps:
  1) Test primary and settings flows; record TTC with 200 prompts.
  2) Run VoiceOver; verify labels and navigation.
  3) Verify launch-on-login and persistence across reboots.
- Acceptance Criteria:
  - All PRD ACs pass; TTC p95 ≤ 3s; accessibility verified.

<a id="p8-t2"></a>
**P8-T2: Docs (README, Privacy note) and versioning**
- Why: Ensure maintainability and user trust.
- Inputs: PRD; implementation details.
- Outputs: `README.md`, `PRIVACY.md`, updated version in Info.plist.
- Concrete Steps:
  1) Document install, usage, settings, keyboard shortcuts, data paths.
  2) Privacy note: local-only by default; optional local metrics.
  3) Bump `CFBundleShortVersionString` and `CFBundleVersion`.
- Acceptance Criteria:
  - Docs committed; version matches release.

**Mapping Table — Component Mapping**

| Source / Legacy Item | New Implementation / Module | Key Parameters / Props | State / Effects / Dependencies | Notes |
| --- | --- | --- | --- | --- |
| Text files w/ prompts (manual) | `PromptStore` (JSON at App Support) | Path, autosave debounce | Depends on FileManager, Codable | Atomic writes + backup |
| Finder clipboard actions | `Clipboard` utility | Plain text only | Uses `NSPasteboard` | No rich text |
| Manual search | `FuzzySearchEngine` | query, items | Memoize normalized text | Title weight > body |
| Menu navigation | `StatusBarController` + `TranslucentPanel` | fixed width, focus search | NSStatusItem, NSPanel | Esc/Outside → close |
| App preferences | `SettingsViewModel` + `SettingsView` | pinned N, login toggle | UserDefaults, SMAppService | Confirm deletes |

**Logic / Utility Mapping Table**

| Function / Script | Purpose | Signature / Usage | Notes |
| --- | --- | --- | --- |
| `PromptStore.load()` | Load JSON | `func load() throws -> PromptList` | Creates dir if missing |
| `PromptStore.save(_:)` | Save JSON atomically | `func save(_ list: PromptList) throws` | Also writes `.bak` |
| `FuzzySearchEngine.match(query:items:)` | Rank prompts by score | `func match(_ q: String, in items: [Prompt]) -> [Prompt]` | Diacritic-insensitive |
| `Clipboard.copy(_:)` | Copy body text | `func copy(_ text: String)` | Plain text NSPasteboard |
| `Reorder.apply(drag:)` | Update `position` | `func reindex(_ items:[Prompt]) -> [Prompt]` | Dense, stable order |
| `LoginItem.toggle(_:)` | Manage login item | `func setEnabled(_ on: Bool) throws` | SMAppService |
| `Metrics.log(event:)` | Local metrics | `func log(_ e: Metrics.Event)` | Off by default |

**Data / State Model**

```swift
struct Prompt: Identifiable, Codable, Equatable {
  let id: UUID
  var title: String
  var body: String
  var position: Int
  var updatedAt: Date
}
struct PromptList: Codable { var prompts: [Prompt] }
final class AppState: ObservableObject {
  @Published var query: String = ""
  @Published var results: [Prompt] = []
  @Published var selectedIndex: Int? = nil
  @Published var hoveredIndex: Int? = nil
  @Published var pinnedCount: Int = 3
}
```

**Styling / Configuration Plan**
- Environment: Xcode 15+, Swift 5.9/5.10, macOS 14+ target.
- Visuals: `NSVisualEffectView` with suitable material (e.g., `.hudWindow`/`.menu`), high-contrast colors on text/rows.
- Appearance: Auto dark/light via system; test contrast on multiple wallpapers.
- Accessibility: Labels on icon, search, rows; keyboard focus order; VoiceOver verified.
- Sandbox: App Sandbox true; no network entitlements; storage in container App Support.
- Preferences: `UserDefaults` for small settings (pinned N, metrics opt-in, login toggle).

**File / Folder Scaffold**

```
promptDock/
├─ PRD.md                         (existing)
├─ plan.md                        (this plan)
├─ PromptDock.xcodeproj/          (new)
├─ PromptDock/
│  ├─ App.swift                   (SwiftUI App entry)
│  ├─ Info.plist                  
│  ├─ PromptDock.entitlements     
│  ├─ Assets.xcassets/
│  │  └─ AppIcon.appiconset/
│  ├─ Features/
│  │  ├─ StatusBar/
│  │  │  ├─ StatusBarController.swift
│  │  │  └─ TranslucentPanel.swift
│  │  ├─ Search/
│  │  │  ├─ SearchView.swift
│  │  │  └─ SearchRowView.swift
│  │  ├─ Settings/
│  │  │  ├─ SettingsView.swift
│  │  │  └─ SettingsViewModel.swift
│  ├─ Services/
│  │  ├─ PromptStore.swift
│  │  ├─ FuzzySearchEngine.swift
│  │  ├─ Clipboard.swift
│  │  ├─ LoginItem.swift
│  │  └─ Metrics.swift
│  ├─ Models/
│  │  ├─ Prompt.swift
│  │  └─ PromptList.swift
│  └─ AppState/
│     └─ AppState.swift
├─ Scripts/
│  ├─ package_dmg.sh
│  └─ notarize.sh
├─ .swiftlint.yml
└─ .swiftformat
```

**Commands & Tooling**
- Install tooling:
  - `brew install swiftlint swiftformat create-dmg`
- Build (after project exists):
  - `xcodebuild -scheme PromptDock -configuration Debug build`
- Run tests (add tests later):
  - `xcodebuild -scheme PromptDock -configuration Debug test`
- Lint & format:
  - `swiftlint --fix || true`
  - `swiftformat .`
- Release build and sign:
  - `xcodebuild -scheme PromptDock -configuration Release -derivedDataPath build`
- Notarize & staple (example):
  - `ditto -c -k --sequesterRsrc --keepParent build/Release/PromptDock.app PromptDock.zip`
  - `xcrun notarytool submit PromptDock.zip --keychain-profile YOUR_PROFILE --wait`
  - `xcrun stapler staple build/Release/PromptDock.app`
- Package DMG:
  - `create-dmg PromptDock.dmg build/Release/PromptDock.app`

**Risk Register (Top 5)**
- JSON corruption → Mitigation: atomic writes + `.bak` restore; migration version field.
- Search performance on 500+ prompts → Mitigation: normalization cache, lightweight scoring, Instruments tuning.
- Visual contrast on varied wallpapers → Mitigation: test materials; fallback backgrounds on low contrast.
- Launch-on-login variability across OS versions → Mitigation: SMAppService checks + user guidance.
- Accessibility gaps (labels/focus) → Mitigation: early audits; explicit labels; keyboard-first tests.

**Backout / Rollback Strategy**
- Keep previous DMG and signed app bundles; versioned releases.
- Maintain `data.json.bak` and timestamped backups; restore on failure.
- Feature-level backouts by disabling login item and metrics toggles.
- Revert via Git tag to last good commit; rebuild Release from that tag.

**Definition of Done**
- Per Phase:
  - P1: Project builds; signing/sandbox set; lint/format available.
  - P2: Status item opens translucent panel; search UI rendered.
  - P3: Copy via click/Enter works; keyboard + hover interactions stable.
  - P4: JSON CRUD + reorder persist; divider logic functions.
  - P5: Login-on-login toggle works; accessibility labels in place; sandbox verified.
  - P6: TTC p95 ≤3s; search ≤50 ms/keystroke; recovery in place.
  - P7: Notarized, stapled app; DMG packaged; visuals polished.
  - P8: QA report complete; docs published; version set.
- Overall Project DoD:
  - Meets all PRD functional/non-functional requirements and launch checklist.
  - No network access; local-only; accessibility WCAG 2.2 AA.
  - Installer DMG and release notes available.

**Next Actions (Start Now)**
1) P1-T1: Initialize project
   - Command: `open -a Xcode .` → Create macOS App “PromptDock” (SwiftUI, Swift) in this repo.
   - Path: `./PromptDock.xcodeproj`
2) P1-T3: Install dev tooling
   - Commands:
     - `brew install swiftlint swiftformat`
     - `touch .swiftlint.yml .swiftformat`
3) P2-T1: Add status item + panel
   - Files to create:
     - `PromptDock/Features/StatusBar/StatusBarController.swift`
     - `PromptDock/Features/StatusBar/TranslucentPanel.swift`
   - Tip: Wire status item action to show the panel and focus search.

**Unresolved Questions**
- What is the default count for “Pinned” (N)? Proposed: 3.
- Fixed panel width target? Proposed: 360 px.
- Should top result auto-select on type, or only copy on Enter when none selected? PRD says copy top result if none selected—confirm.
- App icon style preference (glyph, color)?
- Exact location and retention policy for local metrics logs?

