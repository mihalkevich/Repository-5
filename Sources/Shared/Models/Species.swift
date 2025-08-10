import Foundation

public struct Species: Codable, Identifiable {
    public var id: String { speciesId }
    public let speciesId: String
    public let commonName: String
    public let scientificName: String
    public let description: String
    public let ruName: String?
    public let habitat: String?
    public let photoTips: String?
    public let iconName: String?
}