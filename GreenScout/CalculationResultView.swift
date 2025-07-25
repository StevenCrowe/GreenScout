//
//  CalculationResultView.swift
//  GreenScout
//
//  View for displaying chemical calculation results and mixing instructions
//

import SwiftUI

struct CalculationResultView: View {
    let result: CalculationResult
    let fieldName: String
    
    @State private var showingShareSheet = false
    @State private var showingSaveConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    // For saving calculations
    @AppStorage("savedCalculations") private var savedCalculationsData: Data = Data()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Field Info Header
                    FieldHeader(fieldName: fieldName)
                    
                    // Summary Card
                    ChemicalRequirementsCard(result: result)
                    
                    // Application Details
                    ApplicationDetailsCard(result: result)
                    
                    // Mixing Instructions
                    MixingInstructionsCard(mixingInstructions: result.mixingInstructions)
                    
                    // Action Buttons
                    ActionButtonsView(
                        onSave: saveCalculation,
                        onShare: { showingShareSheet = true }
                    )
                }
            }
            .navigationTitle("Calculation Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareText()])
        }
        .alert("Calculation Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text("Your calculation has been saved for future reference.")
        }
    }
    
    private func colorForCoverage(_ percentage: Double) -> Color {
        switch percentage {
        case ..<30:
            return .orange
        case 30..<70:
            return .yellow
        default:
            return .green
        }
    }
    
    private func saveCalculation() {
        let savedCalc = SavedCalculation(
            fieldName: fieldName.isEmpty ? "Field \(Date().formatted(date: .abbreviated, time: .omitted))" : fieldName,
            result: result
        )
        
        // Save to UserDefaults (in a real app, use Core Data or similar)
        var savedCalculations = loadSavedCalculations()
        savedCalculations.append(savedCalc)
        
        if let encoded = try? JSONEncoder().encode(savedCalculations) {
            savedCalculationsData = encoded
            showingSaveConfirmation = true
        }
    }
    
    private func loadSavedCalculations() -> [SavedCalculation] {
        if let decoded = try? JSONDecoder().decode([SavedCalculation].self, from: savedCalculationsData) {
            return decoded
        }
        return []
    }
    
    private func generateShareText() -> String {
        """
        GreenScout Chemical Calculation
        
        Field: \(fieldName.isEmpty ? "Unnamed Field" : fieldName)
        Date: \(Date().formatted(date: .abbreviated, time: .shortened))
        
        Field Details:
        • Size: \(String(format: "%.1f", result.fieldData.area)) \(result.fieldData.areaUnit.rawValue)
        • Green Coverage: \(String(format: "%.1f", result.fieldData.greenCoveragePercent))%
        • Crop Type: \(result.fieldData.cropType.rawValue)
        
        Chemical Requirements:
        • Chemical: \(String(format: "%.1f", result.totalChemicalNeeded)) L
        • Water: \(String(format: "%.0f", result.waterVolume)) L
        • Total Volume: \(String(format: "%.0f", result.totalChemicalNeeded + result.waterVolume)) L
        
        Application Settings:
        • Rate: \(String(format: "%.2f", result.applicationRate)) L/ha
        • Pressure: \(result.sprayPressure)
        • Nozzle: \(result.nozzleType)
        
        Mixing Instructions:
        \(result.mixingInstructions.map { instruction in
            var text = "Step \(instruction.step): \(instruction.instruction)"
            if let amount = instruction.amount, let unit = instruction.unit {
                text += " - \(String(format: "%.1f", amount)) \(unit)"
            }
            return text
        }.joined(separator: "\n"))
        """
    }
}

// Helper view for detail rows
struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .font(.callout)
    }
}

// Field Header View
struct FieldHeader: View {
    let fieldName: String
    
    var body: some View {
        if !fieldName.isEmpty {
            Text(fieldName)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
        }
    }
}

// Chemical Requirements Card
struct ChemicalRequirementsCard: View {
    let result: CalculationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Chemical Requirements")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                // Chemical Volume
                VolumeInfo(
                    title: "Chemical",
                    icon: "drop.fill",
                    value: result.totalChemicalNeeded,
                    specifier: "%.1f",
                    unit: "L",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 50)
                
                // Water Volume
                VolumeInfo(
                    title: "Water",
                    icon: "drop",
                    value: result.waterVolume,
                    specifier: "%.0f",
                    unit: "L",
                    color: .cyan
                )
            }
            
            // Total Volume
            HStack {
                Text("Total Spray Volume:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(String(format: "%.0f", result.totalChemicalNeeded + result.waterVolume)) L")
                    .fontWeight(.semibold)
            }
            .font(.callout)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Volume Info Component
struct VolumeInfo: View {
    let title: String
    let icon: String
    let value: Double
    let specifier: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(color)
            Text("\(String(format: specifier, value)) \(unit)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Application Details Card
struct ApplicationDetailsCard: View {
    let result: CalculationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Application Details")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                DetailRow(
                    label: "Field Size",
                    value: String(format: "%.1f %@", result.fieldData.area, result.fieldData.areaUnit.rawValue)
                )
                
                DetailRow(
                    label: "Green Coverage",
                    value: "\(String(format: "%.1f", result.fieldData.greenCoveragePercent))%",
                    color: colorForCoverage(result.fieldData.greenCoveragePercent)
                )
                
                DetailRow(
                    label: "Density Level",
                    value: DensityLevel.from(greenCoverage: result.fieldData.greenCoveragePercent).description
                )
                
                DetailRow(
                    label: "Application Rate",
                    value: "\(String(format: "%.2f", result.applicationRate)) L/ha"
                )
                
                DetailRow(
                    label: "Spray Pressure",
                    value: result.sprayPressure
                )
                
                DetailRow(
                    label: "Nozzle Type",
                    value: result.nozzleType
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func colorForCoverage(_ percentage: Double) -> Color {
        switch percentage {
        case ..<30:
            return .orange
        case 30..<70:
            return .yellow
        default:
            return .green
        }
    }
}

// Mixing Instructions Card
struct MixingInstructionsCard: View {
    let mixingInstructions: [MixingInstruction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mixing Instructions")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(mixingInstructions, id: \.step) { instruction in
                MixingInstructionRow(instruction: instruction, isLast: instruction.step == mixingInstructions.count)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Mixing Instruction Row
struct MixingInstructionRow: View {
    let instruction: MixingInstruction
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 15) {
                // Step number
                Text("\(instruction.step)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.green))
                
                // Instruction text
                VStack(alignment: .leading, spacing: 4) {
                    Text(instruction.instruction)
                        .font(.body)
                    
                    if let amount = instruction.amount,
                       let unit = instruction.unit {
                        Text("\(String(format: "%.1f", amount)) \(unit)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if !isLast {
                Divider()
                    .padding(.leading, 40)
            }
        }
    }
}

// Action Buttons View
struct ActionButtonsView: View {
    let onSave: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onSave) {
                Label("Save", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

struct CalculationResultView_Previews: PreviewProvider {
    static var previews: some View {
        let fieldData = FieldData(
            area: 10,
            areaUnit: .hectares,
            greenCoveragePercent: 45,
            cropType: .wheat,
            applicationDate: Date()
        )
        
        let result = ChemicalCalculator.performCalculation(
            fieldData: fieldData,
            chemicalConcentration: 100,
            sprayVolume: 100,
            tankSize: 1000,
            productName: "Test Herbicide"
        )
        
        CalculationResultView(result: result, fieldName: "North Field")
    }
}
