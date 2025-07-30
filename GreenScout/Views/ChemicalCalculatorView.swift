import SwiftUI

struct ChemicalCalculatorView: View {
    @EnvironmentObject var imageAnalysis: ImageAnalysisViewModel
    @State private var fieldArea: Double = 0.0
    @State private var selectedChemical: ChemicalProduct?
    @State private var applicationRate: Double = 0.0
    @State private var tankSize: Double = 100.0
    @State private var calculationResult: ChemicalCalculationResult?
    @State private var showingChemicalPicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Field Data Input
                    fieldDataSection
                    
                    // Chemical Selection
                    chemicalSelectionSection
                    
                    // Application Parameters
                    applicationParametersSection
                    
                    // Calculate Button
                    if selectedChemical != nil && fieldArea > 0 && applicationRate > 0 {
                        calculateButton
                    }
                    
                    // Results Display
                    if let result = calculationResult {
                        resultsSection(result)
                    }
                }
                .padding()
            }
            .navigationTitle("Chemical Calculator")
            .sheet(isPresented: $showingChemicalPicker) {
                ChemicalProductListView_Selection(
                    onSelect: { chemical in
                        selectedChemical = chemical
                        applicationRate = chemical.minApplicationRate
                    }
                )
            }
        }
    }
    
    var fieldDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Field Information")
                .font(.headline)
            
            HStack {
                Text("Field Area")
                Spacer()
                TextField("hectares", value: $fieldArea, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 120)
            }
            
            if let fieldData = imageAnalysis.prepareForChemicalCalculation() {
                HStack {
                    Text("Green Coverage")
                    Spacer()
                    Text(String(format: "%.1f%%", fieldData.greenCoveragePercent))
                        .foregroundColor(.green)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    var chemicalSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chemical Product")
                .font(.headline)
            
            Button(action: { showingChemicalPicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedChemical?.name ?? "Select Chemical")
                            .foregroundColor(selectedChemical == nil ? .secondary : .primary)
                        if let chemical = selectedChemical {
                            Text("\(chemical.activeIngredient) - " + String(format: "%.1f%%", chemical.concentration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    var applicationParametersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Application Parameters")
                .font(.headline)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Application Rate")
                    Spacer()
                    TextField("L/ha", value: $applicationRate, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                if let chemical = selectedChemical {
                    HStack {
                        Text("Recommended")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f - %.1f L/ha", chemical.minApplicationRate, chemical.maxApplicationRate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Tank Size")
                    Spacer()
                    TextField("L", value: $tankSize, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    var calculateButton: some View {
        Button(action: performCalculation) {
            Text("Calculate Requirements")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    func resultsSection(_ result: ChemicalCalculationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Calculation Results")
                    .font(.headline)
                Spacer()
                Button("Save") {
                    saveCalculation()
                }
                .font(.caption)
            }
            
            VStack(spacing: 8) {
                resultRow(label: "Total Chemical Required", value: String(format: "%.1f L", result.chemicalVolume))
                resultRow(label: "Total Water Required", value: String(format: "%.1f L", result.waterVolume))
                resultRow(label: "Number of Tanks", value: "\(result.tankLoads)")
                resultRow(label: "Total Spray Volume", value: String(format: "%.1f L", result.totalSprayVolume))
                resultRow(label: "Application Rate", value: String(format: "%.2f L/ha", result.applicationRate))
                
                if let cost = selectedChemical?.costPerLiter {
                    Divider()
                    resultRow(label: "Total Chemical Cost", value: String(format: "$%.2f", result.chemicalVolume * cost))
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    func performCalculation() {
        guard let chemical = selectedChemical else { return }
        
        // Create field data for calculation
        let greenCoverage = imageAnalysis.prepareForChemicalCalculation()?.greenCoveragePercent ?? 50.0
        let fieldData = FieldData(
            area: fieldArea,
            areaUnit: .hectares,
            greenCoveragePercent: greenCoverage,
            cropType: .pasture,
            applicationDate: Date()
        )
        
        // Calculate using the ChemicalCalculator
        let result = ChemicalCalculator.calculateChemicalRequirement(
            fieldData: fieldData,
            chemicalConcentration: chemical.concentration,
            sprayVolume: ChemicalCalculator.SprayVolumes.standard,
            tankSize: tankSize
        )
        
        calculationResult = result
    }
    
    func saveCalculation() {
        // Save to Core Data
        print("Saving calculation...")
    }
}

struct ChemicalCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        ChemicalCalculatorView()
            .environmentObject(ImageAnalysisViewModel())
    }
}
