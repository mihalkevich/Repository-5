import SwiftUI
import PhotosUI
import AVFoundation

struct CaptureView: View {
    var onImagePicked: (UIImage) -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCameraUnavailableAlert: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 240)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "leaf")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No image selected")
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding(.horizontal)
            }

            HStack(spacing: 12) {
                Button {
                    requestCameraAccessAndPresent()
                } label: {
                    Label("Camera", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)

                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label("Library", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            if selectedImage != nil {
                Button {
                    if let selectedImage { onImagePicked(selectedImage) }
                } label: {
                    Label("Use Photo", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding(.top, 16)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.selectedImage = uiImage
                    }
                }
            }
        }
        .alert("Camera Unavailable", isPresented: $showingCameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Camera is not available or permission denied.")
        }
    }

    private func requestCameraAccessAndPresent() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentSimpleSystemCameraFallback()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        presentSimpleSystemCameraFallback()
                    } else {
                        showingCameraUnavailableAlert = true
                    }
                }
            }
        default:
            showingCameraUnavailableAlert = true
        }
    }

    private func presentSimpleSystemCameraFallback() {
        // Placeholder: In a full app, present a custom camera with AVCaptureSession.
        showingCameraUnavailableAlert = true
    }
}

#Preview {
    CaptureView { _ in }
}