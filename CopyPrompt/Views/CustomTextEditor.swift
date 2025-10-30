import SwiftUI
import AppKit

/// A custom TextEditor that properly handles Enter key presses for multiline input
/// This wrapper uses NSTextView directly to prevent SwiftUI sheet dismissal on Enter
struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont = .systemFont(ofSize: 12)

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.font = font
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.drawsBackground = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.string = text

        // Important: Set field editor to false to prevent form submission behavior
        textView.isFieldEditor = false

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView

        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        // Override to ensure Enter key creates new lines
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            print("""
            [HYPOTHESIS 2 TEST]
            textView:doCommandBy called!
            - selector: \(commandSelector)
            - is insertNewline: \(commandSelector == #selector(NSResponder.insertNewline(_:)))
            - textView is first responder: \(textView.window?.firstResponder == textView)
            """)

            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                print("  ✅ Intercepting insertNewline - adding newline manually")
                // Insert a newline character instead of submitting
                textView.insertNewline(nil)
                return true
            }
            return false
        }
    }
}
