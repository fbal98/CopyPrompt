import AppKit
import SwiftUI

enum PanelMode: Equatable {
    case search
    case newPrompt
    case editPrompt(UUID)
}

// Container view that manages mode switching between search and new prompt
struct PanelContainerView: View {
    @ObservedObject var promptStore: PromptStore
    @State private var mode: PanelMode = .search
    let onClose: () -> Void

    var body: some View {
        Group {
            switch mode {
            case .search:
                SearchContainerView(
                    promptStore: promptStore,
                    onAddNewPrompt: {
                        mode = .newPrompt
                    },
                    onEditPrompt: { promptId in
                        mode = .editPrompt(promptId)
                    },
                    onClose: onClose
                )
            case .newPrompt:
                NewPromptContainerView(
                    promptStore: promptStore,
                    onSave: {
                        mode = .search
                    },
                    onCancel: {
                        mode = .search
                    }
                )
            case let .editPrompt(promptId):
                EditPromptContainerView(
                    promptStore: promptStore,
                    promptId: promptId,
                    onSave: {
                        mode = .search
                    },
                    onCancel: {
                        mode = .search
                    }
                )
            }
        }
    }
}

class TranslucentPanel: NSPanel {
    private var hostingView: NSHostingView<PanelContainerView>?
    private let promptStore: PromptStore

    init(
        promptStore: PromptStore,
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        self.promptStore = promptStore

        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: backingStoreType,
            defer: flag
        )

        // Hide window control buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        isFloatingPanel = true
        level = .popUpMenu
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        setupContent()
    }

    private func setupContent() {
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow

        let containerView = PanelContainerView(
            promptStore: promptStore,
            onClose: { [weak self] in
                self?.orderOut(nil)
            }
        )

        let hosting = NSHostingView(rootView: containerView)
        hosting.translatesAutoresizingMaskIntoConstraints = false

        visualEffect.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            hosting.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
        ])

        contentView = visualEffect
        hostingView = hosting
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        false
    }

    override func resignKey() {
        print("""
        [HYPOTHESIS 4/5 TEST - CRITICAL]
        TranslucentPanel resignKey() called!
        - Current first responder: \(String(describing: firstResponder))
        - Stack trace:
        """)
        Thread.callStackSymbols.forEach { print("  \($0)") }

        super.resignKey()
        // Close the panel when it loses focus
        print("  ⚠️ CLOSING PANEL due to resignKey")
        orderOut(nil)
    }

    override func becomeKey() {
        super.becomeKey()
        print("""
        [DIAGNOSTIC]
        TranslucentPanel becomeKey() called
        - First responder: \(String(describing: firstResponder))
        """)
    }

    override func makeFirstResponder(_ responder: NSResponder?) -> Bool {
        let result = super.makeFirstResponder(responder)
        print("""
        [DIAGNOSTIC]
        TranslucentPanel makeFirstResponder called
        - New responder: \(String(describing: responder))
        - Result: \(result)
        """)
        return result
    }
}
