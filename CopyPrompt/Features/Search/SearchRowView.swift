import SwiftUI

struct SearchRowView: View {
    let result: SearchResult
    let isSelected: Bool
    let isHovered: Bool
    let isPinned: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTogglePin: () -> Void

    private var isHighlighted: Bool {
        isHovered || isSelected
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(result.body)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(height: 44)
        .background(
            isHighlighted ?
                Color.accentColor.opacity(0.15) :
                Color.clear
        )
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                onTogglePin()
            } label: {
                if isPinned {
                    Label("Unpin", systemImage: "pin.slash")
                } else {
                    Label("Pin", systemImage: "pin")
                }
            }

            Divider()

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.title), \(result.body)")
        .accessibilityHint("Click to copy this prompt to clipboard")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    VStack(spacing: 0) {
        SearchRowView(
            result: SearchResult(
                id: UUID(),
                title: "Example Prompt",
                body: "This is an example prompt body text that might be quite long"
            ),
            isSelected: false,
            isHovered: false,
            isPinned: false,
            onEdit: {},
            onDelete: {},
            onTogglePin: {}
        )

        SearchRowView(
            result: SearchResult(
                id: UUID(),
                title: "Hovered Example",
                body: "This row is being hovered over"
            ),
            isSelected: false,
            isHovered: true,
            isPinned: true,
            onEdit: {},
            onDelete: {},
            onTogglePin: {}
        )

        SearchRowView(
            result: SearchResult(
                id: UUID(),
                title: "Selected Example",
                body: "This row is selected"
            ),
            isSelected: true,
            isHovered: false,
            isPinned: false,
            onEdit: {},
            onDelete: {},
            onTogglePin: {}
        )
    }
    .frame(width: 360)
}
