import Foundation
import UIKit
import Photos

struct HistoryItem: Codable, Identifiable {
    let id: UUID
    let result: IdentificationResult
}

final class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let historyFileName = "history.json"

    private init() {}

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var historyURL: URL { documentsURL.appendingPathComponent(historyFileName) }

    func loadHistory() -> [HistoryItem] {
        guard let data = try? Data(contentsOf: historyURL) else { return [] }
        return (try? JSONDecoder().decode([HistoryItem].self, from: data)) ?? []
    }

    func saveHistory(_ items: [HistoryItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: historyURL, options: [.atomic])
        } catch {
            print("Failed to save history: \(error)")
        }
    }

    func appendToHistory(_ result: IdentificationResult) {
        var current = loadHistory()
        let item = HistoryItem(id: UUID(), result: result)
        current.insert(item, at: 0)
        saveHistory(current)
    }

    func savePreviewToPhotosIfNeeded(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}