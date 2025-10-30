
# **CopyPrompt v1.0 — Comprehensive PRD**

**Owner:** You
**Version:** 1.0 (Final Draft)
**Last Updated:** Oct 25, 2025

---

## **Overview**

**CopyPrompt** is a native macOS menu bar utility that allows instant access to stored AI prompts. It eliminates context-switching by enabling fuzzy search, hover-highlight selection, and one-click/Enter-to-copy interactions—all in under 3 seconds.

---

## **Problem Statement**

Power users working heavily with AI often reuse prompts but must manually search and copy them from `.txt` files.
This process interrupts creative flow and productivity.

**CopyPrompt solves this by:**

* Providing fast, local prompt access from the macOS menu bar.
* Allowing fuzzy search, hover selection, and instant copy to clipboard.
* Maintaining an elegant, translucent, system-native appearance.

---

## **Goals & Success Metrics**

| Type           | Metric                                                                 | Target     |
| -------------- | ---------------------------------------------------------------------- | ---------- |
| **North Star** | Time-to-Copy (TTC)                                                     | ≤ 3s (p95) |
| **Usage**      | % of prompt retrievals via CopyPrompt                                  | ≥ 90%      |
| **Experience** | Personal satisfaction rating                                           | ≥ 9/10     |
| **Guardrails** | CPU < 10% spike; RAM < 100 MB; 0 network calls; WCAG 2.2 AA compliance |            |

---

## **User Persona**

**Primary User:** You — a solo AI power user.

* Needs: fast recall, minimal visuals, native UX consistency.
* Behavior: adds/edit prompts occasionally; retrieves many daily.
* Accessibility: full keyboard navigation, VoiceOver labels, and high-contrast visuals.

---

## **Jobs To Be Done (JTBD)**

> When I need to reuse an AI prompt, I want to find and copy it instantly so I can stay in flow without switching context.

---

## **Scope**

### ✅ In-Scope (MVP)

* Menu bar app (NSStatusItem)
* Translucent dropdown with fuzzy search-as-you-type
* List view (Title + truncated Body)
* Hover highlight only
* Enter or Click → Copy (auto-close window)
* Add/Edit/Delete prompts via **separate Settings window**
* Add prompt form (minimal, single dialog)
* Save on Enter; confirm before delete
* Drag reorder (defines pinned items)
* Divider between pinned & others
* Search field with [×] clear button
* Max 10 visible prompts before scroll
* Launch on login
* Plain text clipboard copy
* Fixed width window
* Local JSON storage (simplest native persistence)

### ❌ Out-of-Scope

* Cloud sync or sharing
* Export/backup
* Rich text clipboard
* Variable templates / folders
* Team collaboration

---

## **Prioritization (MoSCoW)**

| Feature                    | Must | Should | Could | Won’t |
| -------------------------- | ---- | ------ | ----- | ----- |
| Menu bar dropdown          | ✅    |        |       |       |
| Fuzzy search-as-you-type   | ✅    |        |       |       |
| Click/Enter → Copy         | ✅    |        |       |       |
| Auto-close after copy      | ✅    |        |       |       |
| Hover highlight            | ✅    |        |       |       |
| Add/Edit/Delete (Settings) | ✅    |        |       |       |
| Drag reorder               | ✅    |        |       |       |
| Divider line               | ✅    |        |       |       |
| Launch on login            | ✅    |        |       |       |
| Clear (×) in search        | ✅    |        |       |       |
| Fixed width                | ✅    |        |       |       |
| JSON storage               | ✅    |        |       |       |
| Plain text clipboard       | ✅    |        |       |       |
| Accessibility compliance   | ✅    |        |       |       |
| Dark/Light auto mode       |      | ✅      |       |       |
| Keyboard nav (↑↓ Esc)      |      | ✅      |       |       |
| Cloud sync                 |      |        |       | ❌     |

---

## **User Stories & Acceptance Criteria**

### **1. Open & Search**

* **Story:** As a user, I want instant search filtering so I can find prompts fast.
* **AC:**

  * Given the app runs in the menu bar
  * When I click the icon
  * Then the translucent dropdown opens with focus in search field.
  * When I type, the list filters in ≤ 50 ms per keystroke.

### **2. Copy to Clipboard**

* **Story:** As a user, I want to copy a prompt with one action so I stay focused.
* **AC:**

  * Hover → highlight row.
  * Click or press Enter → copies full body text → auto-closes window.
  * Topmost result copies on Enter if none selected.

### **3. Add & Edit Prompts**

* **Story:** As a user, I can manage prompts easily from Settings.
* **AC:**

  * Settings window lists prompts (Title, Body).
  * Add New opens single-field form (Title + Body).
  * Enter saves immediately.
  * Delete requires confirmation.

### **4. Reorder & Organization**

* **Story:** As a user, I can reorder prompts to set priority.
* **AC:**

  * Drag and drop rows to reorder.
  * Reorder persists locally.
  * Divider automatically separates top N “pinned” items.

### **5. System & Accessibility**

* **AC:**

  * App launches on login.
  * Esc closes menu; clicking outside closes too.
  * VoiceOver reads labels (icon, search, list, row titles).
  * All elements meet WCAG 2.2 AA contrast.

---

## **UX Flows**

### **Primary Flow**

```
Click menu bar icon
  ↓
Dropdown opens (search focused)
  ↓
Type → List filters (live)
  ↓
Hover row (highlight)
  ↓
Click/Enter → Copy to clipboard
  ↓
Auto-close → Return to workflow
```

### **Settings Flow**

```
Menu → Settings
  ↓
List of prompts
  ↓
Select → Edit (Enter = save)
  ↓
Add New → Save (Enter)
  ↓
Delete → Confirm dialog
```

---

## **UI Spec (ASCII)**

```
╔════════════════════════════════════╗
║ 🔍 Search prompts...         [×]    ║
╠════════════════════════════════════╣
║ Pinned                             ║
║ ───────────────────────────────── ║
║ ▸ Debug Helper – "Explain code…"   ║
║ ▸ Summarizer  – "Summarize text…"  ║
║                                   ↓║
║ ───────────────────────────────── ║
║ Others                             ║
║ ▸ Rewrite Tone – "Make it polite…" ║
║ ▸ Idea Expander – "Add examples…"  ║
╚════════════════════════════════════╝
```

* Hover-only highlight (menu-style)
* Max 10 visible rows → vertical scroll
* Divider between pinned/unpinned

---

## **Functional Requirements**

| Function        | Description                                                                |
| --------------- | -------------------------------------------------------------------------- |
| Search          | Fuzzy search-as-you-type, diacritic-insensitive                            |
| Copy            | Plain text to NSPasteboard                                                 |
| Add/Edit/Delete | Managed via separate Settings window                                       |
| Storage         | Local JSON file under `~/Library/Application Support/CopyPrompt/data.json` |
| Reorder         | Drag-and-drop; persisted                                                   |
| Launch          | Uses ServiceManagement (SMAppService)                                      |
| Window          | Fixed width, translucent NSPanel                                           |
| Accessibility   | VoiceOver + keyboard nav                                                   |
| Performance     | Menu open <150 ms; copy <50 ms                                             |

---

## **Non-Functional Requirements**

| Category          | Target                           |
| ----------------- | -------------------------------- |
| **Performance**   | Menu open <150 ms; search <50 ms |
| **Memory**        | <100 MB steady-state             |
| **CPU**           | <10% spikes                      |
| **Reliability**   | No data loss on quit             |
| **Security**      | Sandboxed; no network access     |
| **Privacy**       | 100% local; no analytics         |
| **Accessibility** | WCAG 2.2 AA                      |
| **Compatibility** | macOS 14+ (Sequoia tested)       |
| **Localization**  | English; UTF-8 safe              |

---

## **Analytics (Optional Local Logs)**

* Track TTC, copy count, crashes (no content logging).
* Stored locally; user-inspectable JSON logs.
* Opt-in toggle in Settings.

---

## **Security & Privacy**

* Local-only app; no external calls.
* Hardened runtime; notarized build.
* JSON file stored in App Support; no PII.
* No clipboard snooping; only writes when user copies.

---

## **Dependencies**

* Swift + SwiftUI + AppKit (for NSStatusItem & NSPanel)
* JSONEncoder/Decoder for local storage
* NSPasteboard for clipboard
* ServiceManagement for launch-on-login
* No external frameworks.

---

## **Risks & Mitigations**

| Risk                           | Impact | Mitigation                       |
| ------------------------------ | ------ | -------------------------------- |
| Data loss on quit              | Low    | Save on every edit; atomic write |
| Visual contrast (translucency) | Medium | Test on light/dark wallpapers    |
| Large library (>500 prompts)   | Low    | Optimize JSON load; lazy filter  |
| Accidental deletes             | Low    | Confirm dialog                   |
| Future Apple API changes       | Low    | Target Ventura+ modern APIs      |

---

## **Release Plan**

| Phase     | Duration | Deliverables                           |
| --------- | -------- | -------------------------------------- |
| Prototype | 2 days   | Hardcoded list + copy UX               |
| MVP       | 1 week   | Full CRUD, search, JSON store, reorder |
| Polish    | 2–3 days | Vibrancy tuning, accessibility, QA     |
| QA/UAT    | 1 day    | Verify TTC, contrast, save/load        |
| Launch    | —        | Signed, notarized DMG                  |

---

## **Launch Checklist**

* [x] Notarized build signed with Apple Dev ID
* [x] WCAG 2.2 AA accessibility verified
* [x] Data persistence tested (save/edit/delete)
* [x] TTC <3 s verified on 200 prompts
* [x] Launch on login confirmed
* [x] Privacy disclaimer shown once

---

## **Appendix: Data Schema**

```json
{
  "prompts": [
    {
      "id": "uuid",
      "title": "Summarizer",
      "body": "Summarize the following text in 3 bullet points...",
      "position": 0,
      "updatedAt": "2025-10-25T12:00:00Z"
    }
  ]
}
```

---

✅ **Final Implementation Notes**

* Minimal “Add Prompt” UI in Settings:
  `+ New` → inline fields (Title, Body) → Enter saves → auto-updates list.
* JSON file is simplest and fully native (no Core Data overhead).
* macOS Sequoia support ensured (13+ APIs stable).
* Plain text clipboard only for maximum reliability.
* Fixed-size window aligns with CopyClip UX.

