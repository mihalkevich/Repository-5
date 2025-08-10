import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationView {
                CaptureView()
                    .navigationTitle("Capture")
            }
            .tabItem {
                Label("Capture", systemImage: "camera")
            }

            NavigationView {
                HistoryView()
                    .navigationTitle("History")
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
    }
}

#Preview {
    RootView()
}