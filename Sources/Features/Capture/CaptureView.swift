import SwiftUI
import UIKit
import PhotosUI
import AVFoundation

struct CaptureView: View {
    @State private var showCamera = false
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?

    @State private var sourceUIImage: UIImage?
    @State private var classification: ClassificationResult?
    @State private var isClassifying = false
    @State private var errorMessage: String?

    @State private var navigateToResults = false

    private let mlService = MLService(model: MLService.loadModel())

    var body: some View {
        VStack(spacing: 16) {
            Group {
                if let image = sourceUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 240)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "leaf")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("Нет изображения")
                                    .foregroundColor(.secondary)
                            }
                        )
                }
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button { showCamera = true } label: { Label("Снять", systemImage: "camera") }
                    .buttonStyle(.borderedProminent)

                Button { showPicker = true } label: { Label("Из Фото", systemImage: "photo") }
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            if isClassifying { ProgressView("Распознаю...") }
            if let errorMessage { Text(errorMessage).foregroundColor(.red) }

            NavigationLink(destination: ResultsView(result: classification, sourceImage: sourceUIImage), isActive: $navigateToResults) { EmptyView() }

            Spacer()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(onCapture: { cg in
                showCamera = false
                handleCaptured(cgImage: cg)
            }, onCancel: {
                showCamera = false
            })
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images, photoLibrary: .shared())
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                await MainActor.run { self.sourceUIImage = uiImage }
                if let cg = uiImage.cgImage { self.handleCaptured(cgImage: cg) }
            }
        }
        .navigationTitle("Capture")
    }

    private func handleCaptured(cgImage: CGImage) {
        isClassifying = true
        errorMessage = nil
        sourceUIImage = sourceUIImage ?? UIImage(cgImage: cgImage)
        mlService.classify(cgImage: cgImage) { result in
            DispatchQueue.main.async {
                self.isClassifying = false
                switch result {
                case .success(let classification):
                    self.classification = classification
                    self.navigateToResults = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationView { CaptureView() }
}