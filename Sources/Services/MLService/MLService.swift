import Foundation
import Vision
import CoreML
import UIKit
import CoreImage

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

    private static let ciContext = CIContext(options: [.cacheIntermediates: false, .useSoftwareRenderer: false])

    private let visionModel: VNCoreMLModel?
    private let processingQueue = DispatchQueue(label: "com.leaflens.mlservice.queue")
    private let stubDelay: TimeInterval
    private let targetLongSide: CGFloat = 512

    init(model: MLModel?, stubDelay: TimeInterval = 0.05) {
        if let model {
            self.visionModel = try? VNCoreMLModel(for: model)
        } else {
            self.visionModel = nil
        }
        self.stubDelay = stubDelay
    }

    static func loadModel() -> MLModel? {
        guard let url = Bundle.main.url(forResource: "PlantClassifier", withExtension: "mlmodelc") else {
            return nil
        }
        return try? MLModel(contentsOf: url)
    }

    private func downscaleForModel(_ cgImage: CGImage) -> CGImage {
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let longSide = max(width, height)
        guard longSide > targetLongSide else { return cgImage }
        let scale = targetLongSide / longSide
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.lanczosScaleTransform()
        filter.inputImage = ciImage
        filter.scale = Float(scale)
        filter.aspectRatio = 1.0
        guard let output = filter.outputImage else { return cgImage }
        let rect = CGRect(x: 0, y: 0, width: width * scale, height: height * scale)
        guard let scaledCG = MLService.ciContext.createCGImage(output, from: rect) else { return cgImage }
        return scaledCG
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
            // Run on background to avoid blocking UI, and downscale before inference
            Task.detached { [processingQueue] in
                autoreleasepool {
                    let scaled = self.downscaleForModel(cgImage)
                    let handler = VNImageRequestHandler(cgImage: scaled, options: [:])
                    processingQueue.async {
                        do { try handler.perform([request]) } catch { completion(.failure(error)) }
                    }
                    // scaled goes out of scope here
                }
            }
        } else {
            // Stub: return three deterministic examples fast
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
            processingQueue.asyncAfter(deadline: .now() + stubDelay) {
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