import SwiftUI

struct RootView: View {
    @State private var selectedImage: UIImage?
    @State private var latestResult: IdentificationResult?

    var body: some View {
        TabView {
            NavigationView {
                CaptureView(onImagePicked: { image in
                    selectedImage = image
                })
                .navigationTitle("Capture")
                .toolbar {
                    NavigationLink(destination: IdentifyView(image: selectedImage, onResult: { result in
                        latestResult = result
                    })) {
                        Text("Identify")
                    }
                    .disabled(selectedImage == nil)
                }
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