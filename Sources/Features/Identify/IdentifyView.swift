import SwiftUI
import Vision
import CoreML

struct IdentifyView: View {
    var image: UIImage?
    var onResult: (IdentificationResult) -> Void

    @State private var isRunning: Bool = false
    @State private var result: IdentificationResult?
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
                ResultsView(result: result)
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
        guard let image else { return }
        isRunning = true
        errorMessage = nil

        mlService.identify(image: image) { result in
            DispatchQueue.main.async {
                self.isRunning = false
                switch result {
                case .success(let identification):
                    self.result = identification
                    onResult(identification)
                    StorageService.shared.appendToHistory(identification)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    IdentifyView(image: nil) { _ in }
}