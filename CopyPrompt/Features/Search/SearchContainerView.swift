import SwiftUI

struct SearchContainerView: View {
    @ObservedObject var promptStore: PromptStore
    @ObservedObject var preferences = AppPreferences.shared
    @State private var query: String = ""
    @State private var panelOpenTime: Date?
    @State private var selectedIndex: Int?
    @State private var eventMonitor: Any?
    let onAddNewPrompt: () -> Void
    let onEditPrompt: (UUID) -> Void
    let onClose: () -> Void

    private var filteredResults: [SearchResult] {
        let prompts: [Prompt]

        if query.isEmpty {
            prompts = promptStore.prompts
        } else {
            prompts = FuzzySearchEngine.search(query: query, in: promptStore.prompts)
        }

        return prompts.map { prompt in
            SearchResult(
                id: prompt.id,
                title: prompt.title,
                body: prompt.body
            )
        }
    }

    var body: some View {
        SearchView(
            query: $query,
            selectedIndex: $selectedIndex,
            results: filteredResults,
            pinnedCount: preferences.pinnedCount,
            onSelect: { result in
                handleSelection(result)
            },
            onEdit: { resultId in
                onEditPrompt(resultId)
            },
            onDelete: { resultId in
                if let prompt = promptStore.prompts.first(where: { $0.id == resultId }) {
                    try? promptStore.delete(prompt)
                }
            },
            onTogglePin: { resultId in
                if let prompt = promptStore.prompts.first(where: { $0.id == resultId }) {
                    let currentIndex = promptStore.prompts.firstIndex(where: { $0.id == resultId }) ?? 0
                    if currentIndex < preferences.pinnedCount {
                        // Currently pinned, unpin it
                        try? promptStore.unpin(prompt, preferences: preferences)
                    } else {
                        // Currently unpinned, pin it
                        try? promptStore.pin(prompt, preferences: preferences)
                    }
                }
            },
            onClose: onClose,
            onAddNewPrompt: onAddNewPrompt
        )
        .onAppear {
            panelOpenTime = Date()
            installKeyboardHandling()
        }
        .onDisappear {
            removeKeyboardHandling()
        }
        .onChange(of: query) { _ in
            measureSearchPerformance()
        }
    }

    private func installKeyboardHandling() {
        print("[EVENT MONITOR] Installing in SearchContainerView")
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            return self.handleKeyEvent(event)
        }
    }

    private func removeKeyboardHandling() {
        if let monitor = eventMonitor {
            print("[EVENT MONITOR] Removing from SearchContainerView")
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        print("[SEARCH] Handling key event - keyCode: \(event.keyCode)")

        switch event.keyCode {
        case 36: // Return
            if !filteredResults.isEmpty {
                let index = selectedIndex ?? 0
                guard index < filteredResults.count else { return nil }
                let result = filteredResults[index]
                copyAndClose(result)
                return nil
            }
        case 53: // Escape
            onClose()
            return nil
        case 125: // Down arrow
            moveSelectionDown()
            return nil
        case 126: // Up arrow
            moveSelectionUp()
            return nil
        default:
            break
        }
        return event
    }

    private func moveSelectionDown() {
        guard !filteredResults.isEmpty else { return }

        if let current = selectedIndex {
            if current < filteredResults.count - 1 {
                selectedIndex = current + 1
            }
        } else {
            selectedIndex = 0
        }
    }

    private func moveSelectionUp() {
        guard !filteredResults.isEmpty else { return }

        if let current = selectedIndex {
            if current > 0 {
                selectedIndex = current - 1
            }
        } else {
            selectedIndex = filteredResults.count - 1
        }
    }

    private func copyAndClose(_ result: SearchResult) {
        Clipboard.copy(result.body)
        handleSelection(result)
        onClose()
    }

    private func handleSelection(_ result: SearchResult) {
        if let openTime = panelOpenTime {
            let duration = Date().timeIntervalSince(openTime)
            Metrics.shared.log(
                eventType: "time-to-copy",
                duration: duration,
                metadata: [
                    "promptId": result.id.uuidString,
                    "queryLength": "\(query.count)"
                ]
            )
        }
    }

    private func measureSearchPerformance() {
        let startTime = Date()

        // Trigger search computation
        _ = filteredResults

        let duration = Date().timeIntervalSince(startTime)

        Metrics.shared.log(
            eventType: "search-keystroke",
            duration: duration,
            metadata: [
                "queryLength": "\(query.count)",
                "resultCount": "\(filteredResults.count)",
                "totalPrompts": "\(promptStore.prompts.count)"
            ]
        )
    }
}
