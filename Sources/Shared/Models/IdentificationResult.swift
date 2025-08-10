import Foundation
import UIKit

struct IdentificationResult: Codable {
    let speciesId: String
    let speciesCommonName: String
    let speciesScientificName: String
    let confidence: Double
    let date: Date

    // Not codable directly; image is transient. Persist via previewImagePath if needed.
    var previewImage: UIImage?
    let previewImagePath: String?
}