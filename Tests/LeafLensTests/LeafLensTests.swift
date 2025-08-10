import Foundation
import XCTest

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
}

private struct TestSpecies: Codable {
    let speciesId: String
    let commonName: String
    let scientificName: String
    let description: String
}