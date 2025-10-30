import SwiftUI

struct PromptEditorView: View {
    @State private var title: String
    @State private var promptBody: String
    private let originalPrompt: Prompt
    private let isNew: Bool
    let onSave: (Prompt) -> Void
    let onCancel: () -> Void

    init(prompt: Prompt, isNew: Bool, onSave: @escaping (Prompt) -> Void, onCancel: @escaping () -> Void) {
        originalPrompt = prompt
        self.isNew = isNew
        _title = State(initialValue: prompt.title)
        _promptBody = State(initialValue: prompt.body)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isNew ? "New Prompt" : "Edit Prompt")
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("Prompt title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        // Do nothing - prevent default submit behavior
                    }
                    .accessibilityLabel("Prompt title")
                    .accessibilityValue(title.isEmpty ? "Empty" : title)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Body")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                CustomTextEditor(text: $promptBody, font: .systemFont(ofSize: 12))
                    .frame(minHeight: 200)
                    .border(Color.secondary.opacity(0.2), width: 1)
                    .accessibilityLabel("Prompt body")
                    .accessibilityValue(promptBody.isEmpty ? "Empty" : promptBody)
            }

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                .accessibilityLabel("Cancel editing")

                Spacer()

                Button("Save") {
                    save()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(title.isEmpty)
                .accessibilityLabel("Save prompt")
                .accessibilityHint(title.isEmpty ? "Title is required" : "Saves the prompt with Command+S")
            }
        }
        .padding(20)
        .frame(width: 500)
        .onSubmit {
            // Prevent any form submission behavior
        }
    }

    private func save() {
        var updatedPrompt = originalPrompt
        updatedPrompt.title = title
        updatedPrompt.body = promptBody
        updatedPrompt.updatedAt = Date()
        onSave(updatedPrompt)
    }
}
