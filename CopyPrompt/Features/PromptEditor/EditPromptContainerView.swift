import SwiftUI

struct EditPromptContainerView: View {
    @ObservedObject var promptStore: PromptStore
    let promptId: UUID
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        if let prompt = promptStore.prompts.first(where: { $0.id == promptId }) {
            PromptEditorView(
                prompt: prompt,
                isNew: false,
                onSave: { updatedPrompt in
                    try? promptStore.update(updatedPrompt)
                    onSave()
                },
                onCancel: onCancel
            )
        } else {
            VStack {
                Text("Prompt not found")
                    .foregroundColor(.secondary)
                Button("Cancel") {
                    onCancel()
                }
            }
            .frame(width: 360, height: 420)
        }
    }
}
