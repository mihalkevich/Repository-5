import SwiftUI

struct HistoryView: View {
    @State private var items: [HistoryItem] = []

    var body: some View {
        List(items) { item in
            VStack(alignment: .leading, spacing: 4) {
                Text(item.result.speciesCommonName)
                    .font(.headline)
                Text(item.result.speciesScientificName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(item.result.date.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            items = StorageService.shared.loadHistory()
        }
        .refreshable {
            items = StorageService.shared.loadHistory()
        }
    }
}

#Preview {
    HistoryView()
}