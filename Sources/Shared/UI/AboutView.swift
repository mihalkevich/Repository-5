import SwiftUI

struct AboutView: View {
    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(v) (\(b))"
    }

    var body: some View {
        List {
            Section("LeafLens") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(version).foregroundColor(.secondary)
                }
            }
            Section("Privacy") {
                Text("All processing is on-device. No tracking, no data collection.")
            }
            Section("Links") {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Support", destination: URL(string: "https://example.com/support")!)
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    NavigationView { AboutView() }
}