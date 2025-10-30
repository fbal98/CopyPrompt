import SwiftUI

struct SearchView: View {
    @Binding var query: String
    @Binding var selectedIndex: Int?
    @State private var hoveredIndex: Int?

    let results: [SearchResult]
    let pinnedCount: Int
    let onSelect: (SearchResult) -> Void
    let onEdit: (UUID) -> Void
    let onDelete: (UUID) -> Void
    let onTogglePin: (UUID) -> Void
    let onClose: () -> Void
    let onAddNewPrompt: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            searchField
            Divider()
            resultsList
        }
        .frame(width: 360, height: 420)
    }

    private func copyAndClose(_ result: SearchResult) {
        Clipboard.copy(result.body)
        onSelect(result)
        onClose()
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .imageScale(.medium)
                .accessibilityHidden(true)

            TextField("Search prompts...", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .accessibilityLabel("Search prompts")
                .accessibilityValue(query.isEmpty ? "Empty" : query)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
                .accessibilityHint("Clears the search field")
            }

            Button(action: onAddNewPrompt) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add new prompt")
            .accessibilityHint("Opens new prompt editor")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                if !results.isEmpty {
                    let pinnedResults = Array(results.prefix(pinnedCount))
                    let otherResults = Array(results.dropFirst(pinnedCount))

                    if !pinnedResults.isEmpty {
                        Section {
                            ForEach(Array(pinnedResults.enumerated()), id: \.element.id) { index, result in
                                SearchRowView(
                                    result: result,
                                    isSelected: selectedIndex == index,
                                    isHovered: hoveredIndex == index,
                                    isPinned: true,
                                    onEdit: { onEdit(result.id) },
                                    onDelete: { onDelete(result.id) },
                                    onTogglePin: { onTogglePin(result.id) }
                                )
                                .onTapGesture {
                                    copyAndClose(result)
                                }
                                .onHover { hovering in
                                    hoveredIndex = hovering ? index : nil
                                }
                            }
                        } header: {
                            SectionHeaderView(title: "Pinned")
                        }
                    }

                    if !otherResults.isEmpty {
                        Section {
                            ForEach(Array(otherResults.enumerated()), id: \.element.id) { index, result in
                                let adjustedIndex = index + pinnedCount
                                SearchRowView(
                                    result: result,
                                    isSelected: selectedIndex == adjustedIndex,
                                    isHovered: hoveredIndex == adjustedIndex,
                                    isPinned: false,
                                    onEdit: { onEdit(result.id) },
                                    onDelete: { onDelete(result.id) },
                                    onTogglePin: { onTogglePin(result.id) }
                                )
                                .onTapGesture {
                                    copyAndClose(result)
                                }
                                .onHover { hovering in
                                    hoveredIndex = hovering ? adjustedIndex : nil
                                }
                            }
                        } header: {
                            SectionHeaderView(title: "Others")
                        }
                    }
                } else if !query.isEmpty {
                    emptyState
                }
            }
        }
        .frame(maxHeight: 10 * 44)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("No results")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct SectionHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.background)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) section")
        .accessibilityAddTraits(.isHeader)
    }
}

struct SearchResult: Identifiable {
    let id: UUID
    let title: String
    let body: String
}

#Preview {
    SearchView(
        query: .constant("test"),
        selectedIndex: .constant(nil),
        results: [
            SearchResult(id: UUID(), title: "Test Prompt 1", body: "This is a test prompt"),
            SearchResult(id: UUID(), title: "Test Prompt 2", body: "Another test prompt"),
            SearchResult(id: UUID(), title: "Test Prompt 3", body: "Yet another test"),
        ],
        pinnedCount: 1,
        onSelect: { _ in },
        onEdit: { _ in },
        onDelete: { _ in },
        onTogglePin: { _ in },
        onClose: {},
        onAddNewPrompt: {}
    )
}
