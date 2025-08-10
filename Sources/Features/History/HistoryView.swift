import SwiftUI
import UIKit

struct HistoryView: View {
    @State private var items: [Identification] = []
    @State private var query: String = ""
    @State private var showExporter: Bool = false
    @State private var exportText: String = ""

    var filtered: [Identification] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.bestLabel.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack {
            List {
                ForEach(filtered) { item in
                    NavigationLink {
                        let candidates = [item.bestLabel].compactMap { idOrLabel -> ClassificationCandidate? in
                            // Map from label to species if possible
                            if let species = SpeciesDB.shared.speciesById[idOrLabel] {
                                return ClassificationCandidate(id: species.speciesId, commonName: species.ruName ?? species.commonName, scientificName: species.scientificName, confidence: item.confidence)
                            } else {
                                // Fallback without species match
                                return ClassificationCandidate(id: idOrLabel, commonName: idOrLabel, scientificName: idOrLabel, confidence: item.confidence)
                            }
                        }
                        ResultsView(result: ClassificationResult(candidates: candidates), sourceImage: UIImage(contentsOfFile: item.thumbFileURL.path), readOnly: true)
                    } label: {
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
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск по названию")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    exportText = makeReport(limit: 20)
                    showExporter = true
                } label: {
                    Label("Экспорт", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showExporter) {
            ActivityView(activityItems: [exportText])
        }
        .task { items = StorageService.shared.loadHistory() }
        .refreshable { items = StorageService.shared.loadHistory() }
        .navigationTitle("History")
    }

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { filtered[$0].id }
        // Remove from persistent storage
        for id in toDelete { StorageService.shared.deleteFromHistory(id: id) }
        // Reload list (simplest to keep filtered consistent)
        items = StorageService.shared.loadHistory()
    }

    private func makeReport(limit: Int) -> String {
        let recent = Array(items.prefix(limit))
        var lines: [String] = ["# LeafLens – последние \(recent.count) определений", ""]
        for (idx, item) in recent.enumerated() {
            let line = "\(idx + 1). **\(item.bestLabel)** — \(String(format: "%.0f%%", item.confidence * 100)) — \(item.date.formatted())"
            lines.append(line)
        }
        lines.append("")
        lines.append("_Сгенерировано LeafLens_")
        return lines.joined(separator: "\n")
    }
}

#Preview {
    NavigationView { HistoryView() }
}