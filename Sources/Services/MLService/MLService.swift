import Foundation
import Vision
import CoreML
import UIKit

struct ClassificationCandidate: Codable, Identifiable {
    let id: String
    let commonName: String
    let scientificName: String
    let confidence: Float
    var species: Species? { SpeciesDB.shared.speciesById[id] }
}

struct ClassificationResult: Codable {
    let candidates: [ClassificationCandidate]
    var best: ClassificationCandidate? { candidates.sorted { $0.confidence > $1.confidence }.first }
}

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

    // New API: classify CGImage and return top-3 candidates
    func classify(cgImage: CGImage, completion: @escaping (Result<ClassificationResult, Error>) -> Void) {
        if let visionModel {
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let error { completion(.failure(error)); return }
                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion(.failure(MLServiceError.processingFailed)); return
                }
                let top = observations.prefix(3).map { obs -> ClassificationCandidate in
                    let id = obs.identifier
                    let species = SpeciesDB.shared.speciesById[id]
                    return ClassificationCandidate(
                        id: id,
                        commonName: species?.ruName ?? species?.commonName ?? id,
                        scientificName: species?.scientificName ?? id,
                        confidence: obs.confidence
                    )
                }
                completion(.success(ClassificationResult(candidates: Array(top))))
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            processingQueue.async {
                do { try handler.perform([request]) } catch { completion(.failure(error)) }
            }
        } else {
            // Stub: return three deterministic examples
            let ids = ["oak", "maple", "birch"]
            let candidates: [ClassificationCandidate] = ids.enumerated().map { index, id in
                let species = SpeciesDB.shared.speciesById[id]
                let conf: Float = [0.76, 0.18, 0.06][index]
                return ClassificationCandidate(
                    id: id,
                    commonName: species?.ruName ?? species?.commonName ?? id,
                    scientificName: species?.scientificName ?? id,
                    confidence: conf
                )
            }
            processingQueue.asyncAfter(deadline: .now() + 0.5) {
                completion(.success(ClassificationResult(candidates: candidates)))
            }
        }
    }

    // Legacy API kept for compatibility
    func identify(image: UIImage, completion: @escaping (Result<IdentificationResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(MLServiceError.processingFailed)); return
        }
        classify(cgImage: cgImage) { result in
            switch result {
            case .success(let classification):
                let best = classification.best
                let speciesId = best?.id ?? "unknown"
                let species = SpeciesDB.shared.speciesById[speciesId]
                let identification = IdentificationResult(
                    speciesId: speciesId,
                    speciesCommonName: best?.commonName ?? species?.commonName ?? speciesId,
                    speciesScientificName: best?.scientificName ?? species?.scientificName ?? speciesId,
                    confidence: Double(best?.confidence ?? 0),
                    date: Date(),
                    previewImage: image,
                    previewImagePath: nil
                )
                completion(.success(identification))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}