import SwiftUI

struct ResultsView: View {
    let result: IdentificationResult
    @State private var speciesDescription: String?

    var body: some View {
        VStack(spacing: 16) {
            Text(result.speciesCommonName)
                .font(.title)
                .fontWeight(.semibold)
            Text(result.speciesScientificName)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let speciesDescription {
                Text(speciesDescription)
                    .font(.body)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            if let preview = result.previewImage {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            Spacer()
        }
        .task {
            if let species = SpeciesDB.shared.speciesById[result.speciesId] {
                speciesDescription = species.description
            }
        }
    }
}

#Preview {
    ResultsView(result: .init(speciesId: "oak", speciesCommonName: "Oak", speciesScientificName: "Quercus robur", confidence: 0.92, date: Date(), previewImage: nil, previewImagePath: nil))
}