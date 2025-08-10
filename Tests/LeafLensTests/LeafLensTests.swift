import Foundation
import XCTest
@testable import LeafLens

final class LeafLensTests: XCTestCase {
    func testSpeciesJSONDecoding() throws {
        let url = URL(fileURLWithPath: #file)
            .deletingLastPathComponent() // LeafLensTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // workspace root
            .appendingPathComponent("Sources/Services/SpeciesDB/species.json")
        let data = try Data(contentsOf: url)
        let list = try JSONDecoder().decode([TestSpecies].self, from: data)
        XCTAssertFalse(list.isEmpty)
    }

    func testPerformance_MockClassification10x() async throws {
        // Force mock by not providing a model
        let service = MLService(model: nil, stubDelay: 0.01)
        let dummyImage = UIImage(systemName: "leaf") ?? UIImage()
        guard let cg = dummyImage.cgImage else { return }

        let start = Date()
        let group = DispatchGroup()
        for _ in 0..<10 {
            group.enter()
            service.classify(cgImage: cg) { _ in group.leave() }
        }
        group.wait()
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertLessThan(elapsed, 3.0, "10 classifications should complete under 3s (mock)")
    }
}

private struct TestSpecies: Codable {
    let speciesId: String
    let commonName: String
    let scientificName: String
    let description: String
}