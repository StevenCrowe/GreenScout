import SwiftUI

struct AddChemicalProductView: View {
    @StateObject private var chemicalStore = ChemicalStore.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var manufacturer = ""
    @State private var activeIngredient = ""
    @State private var concentration = 0.0
    @State private var productType = ChemicalType.herbicide
    @State private var minApplicationRate = 0.0
    @State private var maxApplicationRate = 0.0
    @State private var restrictedUse = false
    @State private var withdrawalPeriod = 0
    @State private var costPerLiter = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var isFormValid: Bool {
        !name.isEmpty && 
        !manufacturer.isEmpty && 
        !activeIngredient.isEmpty &&
        concentration > 0 &&
        minApplicationRate > 0 &&
        maxApplicationRate >= minApplicationRate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Product Name", text: $name)
                    TextField("Manufacturer", text: $manufacturer)
                    
                    Picker("Product Type", selection: $productType) {
                        ForEach(ChemicalType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Active Ingredient")) {
                    TextField("Active Ingredient", text: $activeIngredient)
                    
                    HStack {
                        Text("Concentration")
                        Spacer()
                        TextField("0.0", value: $concentration, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("%")
                    }
                }
                
                Section(header: Text("Application Rates")) {
                    HStack {
                        Text("Minimum Rate")
                        Spacer()
                        TextField("0.0", value: $minApplicationRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("L/ha")
                    }
                    
                    HStack {
                        Text("Maximum Rate")
                        Spacer()
                        TextField("0.0", value: $maxApplicationRate, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("L/ha")
                    }
                }
                
                Section(header: Text("Safety & Restrictions")) {
                    Toggle("Restricted Use Product", isOn: $restrictedUse)
                    
                    HStack {
                        Text("Withdrawal Period")
                        Spacer()
                        TextField("0", value: $withdrawalPeriod, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("days")
                    }
                }
                
                Section(header: Text("Cost (Optional)")) {
                    HStack {
                        Text("Cost per Liter")
                        Spacer()
                        Text("$")
                        TextField("0.00", text: $costPerLiter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                if isFormValid && maxApplicationRate > 0 {
                    Section(header: Text("Summary")) {
                        VStack(alignment: .leading, spacing: 8) {
                            if let cost = Double(costPerLiter), cost > 0 {
                                Text("Cost per hectare: $\(cost * minApplicationRate, specifier: "%.2f") - $\(cost * maxApplicationRate, specifier: "%.2f")")
                                    .font(.caption)
                            }
                            
                            Text("Tank coverage (1000L): \(Int(1000 / maxApplicationRate)) - \(Int(1000 / minApplicationRate)) ha")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Chemical Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProduct()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveProduct() {
        // Validate application rates
        guard maxApplicationRate >= minApplicationRate else {
            alertMessage = "Maximum application rate must be greater than or equal to minimum rate."
            showingAlert = true
            return
        }
        
        // Create new product
        let newProduct = ChemicalProduct(
            name: name,
            manufacturer: manufacturer,
            activeIngredient: activeIngredient,
            concentration: concentration,
            productType: productType,
            minApplicationRate: minApplicationRate,
            maxApplicationRate: maxApplicationRate,
            restrictedUse: restrictedUse,
            withdrawalPeriod: withdrawalPeriod,
            costPerLiter: Double(costPerLiter)
        )
        
        // Save to store
        chemicalStore.addChemical(newProduct)
        dismiss()
    }
}

struct AddChemicalProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddChemicalProductView()
    }
}
