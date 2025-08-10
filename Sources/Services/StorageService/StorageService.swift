import Foundation
import UIKit
import Photos

struct Identification: Identifiable, Codable {
    let id: UUID
    let date: Date
    let bestLabel: String
    let confidence: Float
    let thumbFileURL: URL
}

final class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let historyFileName = "history.json"
    private let feedbackFileName = "feedback.json"
    private let thumbnailsDirName = "Thumbnails"

    private init() {
        ensureThumbnailsDir()
    }

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var historyURL: URL { documentsURL.appendingPathComponent(historyFileName) }
    private var feedbackURL: URL { documentsURL.appendingPathComponent(feedbackFileName) }
    private var thumbnailsDirURL: URL { documentsURL.appendingPathComponent(thumbnailsDirName, isDirectory: true) }

    private func ensureThumbnailsDir() {
        if !fileManager.fileExists(atPath: thumbnailsDirURL.path) {
            try? fileManager.createDirectory(at: thumbnailsDirURL, withIntermediateDirectories: true)
        }
    }

    func loadHistory() -> [Identification] {
        guard let data = try? Data(contentsOf: historyURL) else { return [] }
        return (try? JSONDecoder().decode([Identification].self, from: data)) ?? []
    }

    func saveHistory(_ items: [Identification]) {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: historyURL, options: [.atomic])
        } catch {
            print("Failed to save history: \(error)")
        }
    }

    @discardableResult
    func saveToHistory(image: UIImage, label: String, confidence: Float) -> Identification? {
        guard let pngData = image.pngData() else { return nil }
        let id = UUID()
        let thumbURL = thumbnailsDirURL.appendingPathComponent("\(id.uuidString).png")
        do {
            try pngData.write(to: thumbURL, options: .atomic)
            var current = loadHistory()
            let record = Identification(id: id, date: Date(), bestLabel: label, confidence: confidence, thumbFileURL: thumbURL)
            current.insert(record, at: 0)
            saveHistory(current)
            return record
        } catch {
            print("Failed to save thumbnail: \(error)")
            return nil
        }
    }

    func saveFeedback(speciesId: String, positive: Bool) {
        struct Feedback: Codable { let date: Date; let speciesId: String; let positive: Bool }
        var list: [Feedback] = []
        if let data = try? Data(contentsOf: feedbackURL), let existing = try? JSONDecoder().decode([Feedback].self, from: data) { list = existing }
        list.append(Feedback(date: Date(), speciesId: speciesId, positive: positive))
        if let data = try? JSONEncoder().encode(list) { try? data.write(to: feedbackURL, options: .atomic) }
    }

    func savePreviewToPhotosIfNeeded(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}