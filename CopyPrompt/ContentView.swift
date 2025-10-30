import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "doc.on.doc")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("CopyPrompt")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
