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

            NavigationView {
                AboutView()
                    .navigationTitle("About")
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
    }
}

#Preview {
    RootView()
}