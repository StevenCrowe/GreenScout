import SwiftUI

struct ChemicalProductDetailView: View {
    let chemical: ChemicalProduct
    @Environment(\.dismiss) var dismiss
    @State private var showingCompatibilityInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(chemical.productType.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            if chemical.restrictedUse {
                                Label("Restricted Use", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Text(chemical.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(chemical.manufacturer)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Active Ingredient Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Active Ingredient", systemImage: "atom")
                                .font(.headline)
                            
                            HStack {
                                Text(chemical.activeIngredient)
                                    .font(.body)
                                Spacer()
                                Text("\(chemical.concentration, specifier: "%.1f")%")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Application Rates Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Application Rates", systemImage: "drop.fill")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Minimum Rate:")
                                    Spacer()
                                    Text("\(chemical.minApplicationRate, specifier: "%.1f") L/ha")
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Maximum Rate:")
                                    Spacer()
                                    Text("\(chemical.maxApplicationRate, specifier: "%.1f") L/ha")
                                        .fontWeight(.medium)
                                }
                                
                                if chemical.minApplicationRate > 0 {
                                    HStack {
                                        Text("Coverage (1000L tank):")
                                        Spacer()
                                        Text("\(Int(1000 / chemical.maxApplicationRate)) - \(Int(1000 / chemical.minApplicationRate)) ha")
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }
                                    .font(.caption)
                                }
                            }
                            .font(.callout)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Safety & Restrictions Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Safety & Restrictions", systemImage: "shield.fill")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.orange)
                                    Text("Withdrawal Period:")
                                    Spacer()
                                    Text("\(chemical.withdrawalPeriod) days")
                                        .fontWeight(.medium)
                                }
                                
                                if !chemical.compatibleWith.isEmpty {
                                    HStack {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(.green)
                                        Text("Compatible Products:")
                                        Spacer()
                                        Text("\(chemical.compatibleWith.count)")
                                            .fontWeight(.medium)
                                        Button(action: { showingCompatibilityInfo = true }) {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                            .font(.callout)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Cost Section
                    if let cost = chemical.costPerLiter {
                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Cost Analysis", systemImage: "dollarsign.circle.fill")
                                    .font(.headline)
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Price per Liter:")
                                        Spacer()
                                        Text("$\(cost, specifier: "%.2f")")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                    }
                                    
                                    HStack {
                                        Text("Cost per Hectare (min):")
                                        Spacer()
                                        Text("$\(cost * chemical.minApplicationRate, specifier: "%.2f")")
                                            .fontWeight(.medium)
                                    }
                                    
                                    HStack {
                                        Text("Cost per Hectare (max):")
                                        Spacer()
                                        Text("$\(cost * chemical.maxApplicationRate, specifier: "%.2f")")
                                            .fontWeight(.medium)
                                    }
                                }
                                .font(.callout)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Notes Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Application Notes", systemImage: "note.text")
                                .font(.headline)
                            
                            Text("Always follow label directions. Consider weather conditions, crop stage, and pest pressure when selecting application rates.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCompatibilityInfo) {
            // Compatibility list would go here
            Text("Compatibility Information")
                .padding()
        }
    }
}

struct ChemicalProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChemicalProductDetailView(
            chemical: ChemicalProduct(
                name: "Roundup PowerMAX",
                manufacturer: "Bayer",
                activeIngredient: "Glyphosate",
                concentration: 54.0,
                productType: ChemicalType.herbicide,
                minApplicationRate: 1.5,
                maxApplicationRate: 3.0,
                compatibleWith: ["chem123", "chem456"],
                restrictedUse: true,
                withdrawalPeriod: 7,
                costPerLiter: 25.50
            )
        )
    }
}
