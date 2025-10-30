import SwiftUI

@main
struct CopyPromptApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Hidden window to provide SwiftUI context for openSettings
        Window("Settings Bridge", id: "settings-bridge") {
            SettingsBridgeView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Settings {
            SettingsView(promptStore: appDelegate.promptStore)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add New Prompt") {
                    appDelegate.openNewPrompt()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

// Bridge view to handle settings opening from AppKit
struct SettingsBridgeView: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Color.clear
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenSettingsWindow"))) { _ in
                openSettings()
            }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, SettingsWindowDelegate {
    var statusBarController: StatusBarController?
    let promptStore = PromptStore()
    private var privacyNoticeWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load prompts from disk
        do {
            try promptStore.load()
        } catch {
            print("Failed to load prompts: \(error)")
        }

        statusBarController = StatusBarController(promptStore: promptStore)
        statusBarController?.setup()

        // Set self as the delegate for opening new prompts
        statusBarController?.menuManager?.settingsWindowDelegate = self

        // Show privacy notice on first run
        showPrivacyNoticeIfNeeded()
    }

    func openNewPrompt() {
        openNewPromptEditor()
    }

    func openNewPromptEditor() {
        openSettings()

        // Post notification to trigger new prompt in SettingsView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: NSNotification.Name("OpenNewPrompt"), object: nil)
        }
    }

    func openSettings() {
        // Activate app (required for LSUIElement apps to show windows)
        NSApp.activate(ignoringOtherApps: true)

        // Open the hidden bridge window first (required for openSettings environment)
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "settings-bridge" }) {
            window.orderFrontRegardless()
        }

        // Use notification to trigger openSettings from SwiftUI context
        NotificationCenter.default.post(name: NSNotification.Name("OpenSettingsWindow"), object: nil)
    }

    private func showPrivacyNoticeIfNeeded() {
        let hasSeenPrivacyNotice = UserDefaults.standard.bool(forKey: "hasSeenPrivacyNotice")

        if !hasSeenPrivacyNotice {
            let privacyView = PrivacyNoticeView {
                UserDefaults.standard.set(true, forKey: "hasSeenPrivacyNotice")
                self.privacyNoticeWindow?.close()
                self.privacyNoticeWindow = nil
            }

            let hosting = NSHostingController(rootView: privacyView)
            let window = NSWindow(contentViewController: hosting)
            window.title = "Privacy Notice"
            window.styleMask = [.titled, .closable]
            window.center()
            window.level = .floating
            window.makeKeyAndOrderFront(nil)

            privacyNoticeWindow = window
        }
    }
}
