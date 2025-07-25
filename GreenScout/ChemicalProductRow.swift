import SwiftUI

struct ChemicalProductRow: View {
    let chemical: ChemicalProduct
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(chemical.name)
                    .font(.headline)
                Spacer()
                if chemical.restrictedUse {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            Text("\(chemical.activeIngredient) - \(chemical.concentration, specifier: "%.1f")%")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(chemical.manufacturer)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Rate: \(chemical.minApplicationRate, specifier: "%.1f")-\(chemical.maxApplicationRate, specifier: "%.1f") L/ha")
                    .font(.caption2)
                Spacer()
                if let cost = chemical.costPerLiter {
                    Text("$\(cost, specifier: "%.2f")/L")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// Preview provider for SwiftUI canvas
struct ChemicalProductRow_Previews: PreviewProvider {
    static var previews: some View {
        ChemicalProductRow(
            chemical: ChemicalProduct(
                name: "Roundup PowerMAX",
                manufacturer: "Bayer",
                activeIngredient: "Glyphosate",
                concentration: 54.0,
                productType: .herbicide,
                minApplicationRate: 1.5,
                maxApplicationRate: 3.0,
                restrictedUse: true,
                costPerLiter: 25.50
            ),
            onSelect: {
                print("Chemical selected")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
