import SwiftUI
import UIKit

struct HistoryView: View {
    @State private var items: [Identification] = []

    var body: some View {
        List(items) { item in
            HStack(spacing: 12) {
                if let img = UIImage(contentsOfFile: item.thumbFileURL.path) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.bestLabel)
                        .font(.headline)
                    Text(String(format: "%.0f%%", item.confidence * 100))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(item.date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            items = StorageService.shared.loadHistory()
        }
        .refreshable {
            items = StorageService.shared.loadHistory()
        }
        .navigationTitle("History")
    }
}

#Preview {
    HistoryView()
}