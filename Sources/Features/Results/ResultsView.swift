import SwiftUI
import UIKit

struct ResultsView: View {
    let result: ClassificationResult?
    let sourceImage: UIImage?

    @State private var selectedCandidateId: String?
    @State private var savedMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let candidates = result?.candidates {
                    Text("Кандидаты")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    ForEach(candidates.prefix(3)) { cand in
                        Button {
                            selectedCandidateId = cand.id
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: cand.species?.iconName ?? "leaf")
                                    .foregroundColor(.green)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(cand.commonName)
                                        .font(.headline)
                                    Text(cand.scientificName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.0f%%", cand.confidence * 100))
                                    .font(.headline)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.secondary.opacity(selectedCandidateId == cand.id ? 0.2 : 0.1))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                    if let best = result?.best {
                        HStack(spacing: 12) {
                            Button("Похоже") {
                                StorageService.shared.saveFeedback(speciesId: best.id, positive: true)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Не похоже") {
                                StorageService.shared.saveFeedback(speciesId: best.id, positive: false)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal)
                    }

                    Button {
                        guard let image = sourceImage else { return }
                        let chosen = result?.best
                        let id = chosen?.id ?? "unknown"
                        let label = chosen?.commonName ?? id
                        let conf = chosen?.confidence ?? 0
                        if let identification = StorageService.shared.saveToHistory(image: image, label: label, confidence: conf) {
                            savedMessage = "Сохранено: \(identification.bestLabel)"
                        }
                    } label: {
                        Label("Сохранить в Историю", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }

                if let speciesId = result?.best?.id, let species = SpeciesDB.shared.speciesById[speciesId] {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(species.ruName ?? species.commonName)
                            .font(.title3).bold()
                        Text(species.scientificName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let habitat = species.habitat {
                            Text("Где встречается: \(habitat)")
                        }
                        Text(species.description)
                        if let tips = species.photoTips {
                            Text("Советы по фото: \(tips)")
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
                    .padding(.horizontal)
                }

                if let msg = savedMessage {
                    Text(msg)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Результаты")
    }
}

#Preview {
    ResultsView(result: ClassificationResult(candidates: [
        ClassificationCandidate(id: "oak", commonName: "Дуб", scientificName: "Quercus robur", confidence: 0.76),
        ClassificationCandidate(id: "maple", commonName: "Клён", scientificName: "Acer platanoides", confidence: 0.18),
        ClassificationCandidate(id: "birch", commonName: "Берёза", scientificName: "Betula pendula", confidence: 0.06)
    ]), sourceImage: nil)
}