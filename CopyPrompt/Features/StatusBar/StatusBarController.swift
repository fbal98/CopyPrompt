import AppKit
import SwiftUI

class StatusBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var panel: TranslucentPanel?
    private let promptStore: PromptStore
    var menuManager: AppMenuManager?
    private var contextMenu: NSMenu?

    init(promptStore: PromptStore) {
        self.promptStore = promptStore
    }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Setup menu manager
        menuManager = AppMenuManager(promptStore: promptStore)
        contextMenu = menuManager?.createMenu()

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "CopyPrompt")
            button.action = #selector(togglePanel)
            button.target = self

            // Enable right-click menu
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // DO NOT set statusItem?.menu - this would override our custom click handling

        panel = TranslucentPanel(
            promptStore: promptStore,
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
    }

    @objc private func togglePanel(_ sender: Any?) {
        guard let panel else { return }

        // Check if this is a right-click event
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            // Right-click: close panel if open, then show context menu
            if panel.isVisible {
                panel.orderOut(nil)
            }
            if let button = statusItem?.button, let menu = contextMenu {
                menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
            }
            return
        }

        // Left-click: toggle panel
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            positionPanelBelowStatusItem()
            panel.makeKeyAndOrderFront(nil)
        }
    }

    private func positionPanelBelowStatusItem() {
        guard let button = statusItem?.button,
              let panel,
              let screen = NSScreen.main else { return }

        let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
        let panelWidth = panel.frame.width
        let panelHeight = panel.frame.height

        let xPosition = buttonFrame.midX - (panelWidth / 2)
        let yPosition = buttonFrame.minY - panelHeight

        let screenFrame = screen.visibleFrame
        let clampedX = max(screenFrame.minX, min(xPosition, screenFrame.maxX - panelWidth))

        panel.setFrameOrigin(NSPoint(x: clampedX, y: yPosition))
    }
}
