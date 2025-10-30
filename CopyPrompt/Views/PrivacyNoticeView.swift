import SwiftUI

struct PrivacyNoticeView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)

            Text("Privacy First")
                .font(.system(size: 24, weight: .bold))

            VStack(alignment: .leading, spacing: 12) {
                PrivacyFeatureRow(
                    icon: "internaldrive",
                    title: "Local Only",
                    description: "All your prompts are stored locally on your Mac. Nothing ever leaves your device."
                )

                PrivacyFeatureRow(
                    icon: "network.slash",
                    title: "No Network Access",
                    description: "This app is sandboxed with no network capabilities. Your data stays private."
                )

                PrivacyFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Analytics",
                    description: "We don't track your usage or collect any data. What you do is your business."
                )

                PrivacyFeatureRow(
                    icon: "checkmark.shield",
                    title: "App Sandboxed",
                    description: "The app runs in a secure sandbox and can only access its own data folder."
                )
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            Text("Your prompts are saved to:\n~/Library/Application Support/CopyPrompt/")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onDismiss) {
                Text("Got It")
                    .frame(minWidth: 120)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
            .accessibilityLabel("Dismiss privacy notice")
        }
        .padding(30)
        .frame(width: 500)
    }
}

struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
    }
}

#Preview {
    PrivacyNoticeView(onDismiss: {})
}
