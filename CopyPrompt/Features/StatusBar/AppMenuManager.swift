import AppKit

class AppMenuManager {
    private let promptStore: PromptStore
    weak var settingsWindowDelegate: SettingsWindowDelegate?

    init(promptStore: PromptStore) {
        self.promptStore = promptStore
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Add New Prompt
        let newPromptItem = NSMenuItem(
            title: "Add New Prompt",
            action: #selector(addNewPrompt),
            keyEquivalent: "n"
        )
        newPromptItem.target = self
        menu.addItem(newPromptItem)

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Separator
        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit CopyPrompt",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func addNewPrompt() {
        settingsWindowDelegate?.openNewPromptEditor()
    }

    @objc private func openSettings() {
        settingsWindowDelegate?.openSettings()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// Protocol for communicating with Settings window
protocol SettingsWindowDelegate: AnyObject {
    func openNewPromptEditor()
    func openSettings()
}
