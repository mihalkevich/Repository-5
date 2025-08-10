import Foundation

final class SpeciesDB {
    static let shared = SpeciesDB()

    private(set) var speciesById: [String: Species] = [:]

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "species", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let list = try JSONDecoder().decode([Species].self, from: data)
            self.speciesById = Dictionary(uniqueKeysWithValues: list.map { ($0.speciesId, $0) })
        } catch {
            print("Failed to load species DB: \(error)")
        }
    }
}