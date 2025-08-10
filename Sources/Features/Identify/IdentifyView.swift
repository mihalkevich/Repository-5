import SwiftUI
import UIKit
import Vision
import CoreML

struct IdentifyView: View {
    var image: UIImage?

    @State private var isRunning: Bool = false
    @State private var result: ClassificationResult?
    @State private var errorMessage: String?

    private let mlService = MLService(model: nil)

    var body: some View {
        VStack(spacing: 16) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            if isRunning {
                ProgressView("Identifying...")
            } else if let result {
                ResultsView(result: result, sourceImage: image)
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Spacer()

            Button {
                runIdentification()
            } label: {
                Label("Run Identification", systemImage: "leaf.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(image == nil || isRunning)
        }
        .padding(.top, 16)
        .navigationTitle("Identify")
    }

    private func runIdentification() {
        guard let image, let cg = image.cgImage else { return }
        isRunning = true
        errorMessage = nil

        mlService.classify(cgImage: cg) { result in
            DispatchQueue.main.async {
                self.isRunning = false
                switch result {
                case .success(let classification):
                    self.result = classification
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    IdentifyView(image: nil)
}