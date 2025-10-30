import SwiftUI

struct SettingsView: View {
    @ObservedObject var promptStore: PromptStore
    @ObservedObject var preferences = AppPreferences.shared
    @ObservedObject var loginItemManager = LoginItemManager.shared
    @ObservedObject var metrics = Metrics.shared
    @State private var editingPrompt: Prompt?
    @State private var isNewPrompt = false
    @State private var promptToDelete: Prompt?
    @State private var showDeleteConfirmation = false
    @State private var showMetricsStats = false

    private let openNewPromptPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("OpenNewPrompt"))

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            preferencesSection
            Divider()
            promptListView
        }
        .frame(minWidth: 600, minHeight: 400)
        .onReceive(openNewPromptPublisher) { _ in
            addNewPrompt()
        }
        .sheet(item: $editingPrompt) { prompt in
            PromptEditorView(
                prompt: prompt,
                isNew: isNewPrompt,
                onSave: { updatedPrompt in
                    if isNewPrompt {
                        try? promptStore.add(updatedPrompt)
                    } else {
                        try? promptStore.update(updatedPrompt)
                    }
                    editingPrompt = nil
                    isNewPrompt = false
                },
                onCancel: {
                    editingPrompt = nil
                    isNewPrompt = false
                }
            )
            .interactiveDismissDisabled()
        }
        .alert("Delete Prompt", isPresented: $showDeleteConfirmation, presenting: promptToDelete) { prompt in
            Button("Cancel", role: .cancel) {
                promptToDelete = nil
            }
            Button("Delete", role: .destructive) {
                try? promptStore.delete(prompt)
                promptToDelete = nil
            }
        } message: { prompt in
            Text("Are you sure you want to delete '\(prompt.title)'? This action cannot be undone.")
        }
    }

    private var headerView: some View {
        HStack {
            Text("Prompts")
                .font(.system(size: 20, weight: .semibold))
                .padding(.leading, 20)

            Spacer()

            Button(action: addNewPrompt) {
                Label("New", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Add new prompt")
            .accessibilityHint("Creates a new prompt")
            .padding(.trailing, 20)
        }
        .padding(.vertical, 16)
    }

    private var preferencesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Launch at login")
                    .font(.system(size: 13))

                Spacer()

                Toggle("Launch at login", isOn: $loginItemManager.isEnabled)
                    .labelsHidden()
                    .accessibilityLabel("Launch at login")
                    .accessibilityValue(loginItemManager.isEnabled ? "Enabled" : "Disabled")
            }

            Divider()

            HStack {
                Text("Pinned items:")
                    .font(.system(size: 13))

                Stepper(
                    value: $preferences.pinnedCount,
                    in: 0...10
                ) {
                    Text("\(preferences.pinnedCount)")
                        .font(.system(size: 13, weight: .medium))
                        .frame(minWidth: 20)
                }
                .accessibilityLabel("Number of pinned items")
                .accessibilityValue("\(preferences.pinnedCount) items")

                Spacer()

                Text("Top \(preferences.pinnedCount) items will appear as pinned in search")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local metrics (opt-in)")
                        .font(.system(size: 13))

                    Text("Track performance metrics locally. No data leaves your device.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("Local metrics", isOn: $metrics.isEnabled)
                    .labelsHidden()
                    .accessibilityLabel("Enable local metrics")
                    .accessibilityValue(metrics.isEnabled ? "Enabled" : "Disabled")
            }

            if metrics.isEnabled {
                HStack {
                    Button("View Stats") {
                        showMetricsStats = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button("Reset Metrics") {
                        metrics.reset()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showMetricsStats) {
            MetricsStatsView(stats: metrics.getStats())
        }
    }

    private var promptListView: some View {
        List {
            ForEach(Array(promptStore.prompts.enumerated()), id: \.element.id) { index, prompt in
                VStack(spacing: 0) {
                    PromptRowView(
                        prompt: prompt,
                        onEdit: {
                            isNewPrompt = false
                            editingPrompt = prompt
                        },
                        onDelete: {
                            promptToDelete = prompt
                            showDeleteConfirmation = true
                        }
                    )

                    if index == preferences.pinnedCount - 1 && index < promptStore.prompts.count - 1 {
                        HStack {
                            Text("PINNED")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
            }
            .onMove { source, destination in
                try? promptStore.reorder(from: source, to: destination)
            }
        }
        .listStyle(.inset)
    }

    private func addNewPrompt() {
        let newPosition = promptStore.prompts.count
        let newPrompt = Prompt(
            title: "New Prompt",
            body: "",
            position: newPosition
        )
        isNewPrompt = true
        editingPrompt = newPrompt
    }
}

struct PromptRowView: View {
    let prompt: Prompt
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                Text(prompt.body)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(prompt.title), \(prompt.body)")

            Spacer()

            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .help("Edit prompt")
                .accessibilityLabel("Edit \(prompt.title)")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete prompt")
                .accessibilityLabel("Delete \(prompt.title)")
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            onEdit()
        }
        .accessibilityElement(children: .contain)
    }
}

// PromptEditorView has been extracted to Features/PromptEditor/PromptEditorView.swift
