import Foundation
import Vision
import CoreML
import UIKit

final class MLService {
    enum MLServiceError: Error { case modelUnavailable, processingFailed }

    private let visionModel: VNCoreMLModel?
    private let processingQueue = DispatchQueue(label: "com.leaflens.mlservice.queue")

    init(model: MLModel?) {
        if let model {
            self.visionModel = try? VNCoreMLModel(for: model)
        } else {
            self.visionModel = nil
        }
    }

    func identify(image: UIImage, completion: @escaping (Result<IdentificationResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(MLServiceError.processingFailed)); return
        }

        if let visionModel {
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let error { completion(.failure(error)); return }
                guard let observations = request.results as? [VNClassificationObservation],
                      let best = observations.first else {
                    completion(.failure(MLServiceError.processingFailed)); return
                }
                let speciesId = best.identifier
                let species = SpeciesDB.shared.speciesById[speciesId]
                let result = IdentificationResult(
                    speciesId: speciesId,
                    speciesCommonName: species?.commonName ?? speciesId,
                    speciesScientificName: species?.scientificName ?? speciesId,
                    confidence: Double(best.confidence),
                    date: Date(),
                    previewImage: image,
                    previewImagePath: nil
                )
                completion(.success(result))
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            processingQueue.async {
                do { try handler.perform([request]) } catch { completion(.failure(error)) }
            }
        } else {
            // Stub behavior without a model: return a dummy species with medium confidence
            let fallbackId = "oak"
            let species = SpeciesDB.shared.speciesById[fallbackId]
            let result = IdentificationResult(
                speciesId: fallbackId,
                speciesCommonName: species?.commonName ?? "Oak",
                speciesScientificName: species?.scientificName ?? "Quercus robur",
                confidence: 0.5,
                date: Date(),
                previewImage: image,
                previewImagePath: nil
            )
            processingQueue.asyncAfter(deadline: .now() + 0.8) {
                completion(.success(result))
            }
        }
    }
}