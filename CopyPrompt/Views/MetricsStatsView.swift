import SwiftUI

struct MetricsStatsView: View {
    let stats: MetricsStats
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Performance Metrics")
                .font(.system(size: 20, weight: .semibold))

            VStack(spacing: 16) {
                StatRow(
                    label: "Time-to-Copy (p50)",
                    value: formatDuration(stats.ttcP50),
                    status: getStatus(stats.ttcP50, threshold: 2.0)
                )

                StatRow(
                    label: "Time-to-Copy (p95)",
                    value: formatDuration(stats.ttcP95),
                    status: getStatus(stats.ttcP95, threshold: 3.0)
                )

                Divider()

                StatRow(
                    label: "Avg Search Time",
                    value: formatDuration(stats.avgSearchTime, unit: "ms"),
                    status: getStatus(stats.avgSearchTime, threshold: 0.05)
                )

                Divider()

                StatRow(
                    label: "Total Events",
                    value: "\(stats.totalEvents)",
                    status: .neutral
                )
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            Text("Performance Targets:\n• Time-to-Copy p95 ≤ 3s\n• Search keystroke ≤ 50ms")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
        .padding(30)
        .frame(width: 400)
    }

    private func formatDuration(_ duration: TimeInterval?, unit: String = "s") -> String {
        guard let duration = duration else { return "N/A" }

        if unit == "ms" {
            return String(format: "%.1f ms", duration * 1000)
        } else {
            return String(format: "%.2f s", duration)
        }
    }

    private func getStatus(_ value: TimeInterval?, threshold: TimeInterval) -> StatStatus {
        guard let value = value else { return .neutral }
        return value <= threshold ? .good : .warning
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let status: StatStatus

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 6) {
                if status != .neutral {
                    Image(systemName: status == .good ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(status == .good ? .green : .orange)
                }

                Text(value)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
    }
}

enum StatStatus {
    case good
    case warning
    case neutral
}

#Preview {
    MetricsStatsView(
        stats: MetricsStats(
            ttcP50: 1.2,
            ttcP95: 2.8,
            avgSearchTime: 0.035,
            totalEvents: 142
        )
    )
}
