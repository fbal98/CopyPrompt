import AppKit
import SwiftUI

/// Diagnostic NSWindow subclass to test HYPOTHESIS 1: performKeyEquivalent override
class DiagnosticSheetWindow: NSWindow {
    var diagnosticLog: [String] = []

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let log = """
        [HYPOTHESIS 1 TEST]
        performKeyEquivalent called:
        - keyCode: \(event.keyCode)
        - characters: \(event.characters ?? "nil")
        - modifiers: \(event.modifierFlags)
        - super.performKeyEquivalent result: \(super.performKeyEquivalent(with: event))
        """
        print(log)
        diagnosticLog.append(log)

        // Test: If keyCode is 36 (Return), do NOT call super
        if event.keyCode == 36 {
            print("  ⚠️ RETURN KEY DETECTED - Blocking super.performKeyEquivalent")
            // Let it pass through to the responder chain
            return false
        }

        return super.performKeyEquivalent(with: event)
    }

    override func keyDown(with event: NSEvent) {
        let log = """
        [HYPOTHESIS 4 TEST]
        keyDown called:
        - keyCode: \(event.keyCode)
        - characters: \(event.characters ?? "nil")
        - firstResponder: \(String(describing: firstResponder))
        """
        print(log)
        diagnosticLog.append(log)

        super.keyDown(with: event)
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            let log = """
            [EVENT FLOW TEST]
            sendEvent (keyDown):
            - keyCode: \(event.keyCode)
            - firstResponder: \(String(describing: firstResponder))
            - firstResponder type: \(type(of: firstResponder))
            """
            print(log)
            diagnosticLog.append(log)
        }

        super.sendEvent(event)
    }
}

/// Wrapper to intercept and log sheet presentation
struct DiagnosticSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .background(
                SheetPresenterView(
                    isPresented: $isPresented,
                    sheetContent: sheetContent
                )
            )
    }
}

struct SheetPresenterView<SheetContent: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.parentView = view
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented && context.coordinator.sheetWindow == nil {
            context.coordinator.presentSheet()
        } else if !isPresented && context.coordinator.sheetWindow != nil {
            context.coordinator.dismissSheet()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, sheetContent: sheetContent)
    }

    class Coordinator: NSObject, NSWindowDelegate {
        @Binding var isPresented: Bool
        let sheetContent: () -> SheetContent
        weak var parentView: NSView?
        var sheetWindow: DiagnosticSheetWindow?

        init(isPresented: Binding<Bool>, sheetContent: @escaping () -> SheetContent) {
            self._isPresented = isPresented
            self.sheetContent = sheetContent
        }

        func presentSheet() {
            guard let parentView = parentView,
                  let parentWindow = parentView.window else {
                print("[DIAGNOSTIC] Cannot present - no parent window")
                return
            }

            print("[DIAGNOSTIC] Creating diagnostic sheet window")

            let hosting = NSHostingController(rootView: sheetContent())
            let window = DiagnosticSheetWindow(contentViewController: hosting)
            window.styleMask = [.titled, .closable, .resizable]
            window.delegate = self
            window.title = "Diagnostic Sheet"

            print("""
            [HYPOTHESIS 3 TEST]
            Default button status:
            - window.defaultButtonCell: \(String(describing: window.defaultButtonCell))
            """)

            // Test HYPOTHESIS 3: Clear default button
            window.defaultButtonCell = nil

            sheetWindow = window

            parentWindow.beginSheet(window) { response in
                print("[DIAGNOSTIC] Sheet closed with response: \(response)")
                self.isPresented = false
            }

            // Test HYPOTHESIS 4: Check first responder after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("""
                [HYPOTHESIS 4 TEST]
                First responder after sheet appears:
                - \(String(describing: window.firstResponder))
                - Type: \(type(of: window.firstResponder))
                """)
            }
        }

        func dismissSheet() {
            guard let window = sheetWindow,
                  let parentWindow = parentView?.window else { return }

            print("[DIAGNOSTIC] Dismissing sheet")
            print("[DIAGNOSTIC] Logged events:")
            window.diagnosticLog.forEach { print($0) }

            parentWindow.endSheet(window)
            sheetWindow = nil
        }

        func windowWillClose(_ notification: Notification) {
            print("[DIAGNOSTIC] Window will close")
            isPresented = false
        }
    }
}
