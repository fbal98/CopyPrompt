import SwiftUI

struct NewPromptContainerView: View {
    @ObservedObject var promptStore: PromptStore
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        PromptEditorView(
            prompt: createNewPrompt(),
            isNew: true,
            onSave: { prompt in
                try? promptStore.add(prompt)
                onSave()
            },
            onCancel: onCancel
        )
    }

    private func createNewPrompt() -> Prompt {
        let newPosition = promptStore.prompts.count
        return Prompt(
            title: "",
            body: "",
            position: newPosition
        )
    }
}
