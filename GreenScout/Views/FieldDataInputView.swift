//
//  FieldDataInputView.swift
//  GreenScout
//
//  Input form for field data and chemical calculations
//

import SwiftUI

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct FieldDataInputView: View {
    let prefilledGreenCoverage: Double?
    
    @State private var fieldArea: String = ""
    @State private var selectedUnit: AreaUnit = .hectares
    @State private var cropType: CropType = .pasture
    @State private var chemicalConcentration: String = "100"
    @State private var tankSize: Double = 1000
    @State private var sprayVolume: Double = 100
    @State private var productName: String = "Herbicide"
    @State private var fieldName: String = ""
    @State private var notes: String = ""
    @State private var greenCoverageOverride: Double?
    
    // Navigation states
    @State private var showingImageAnalysis = false
    @State private var showingResults = false
    @State private var calculationResult: CalculationResult?
    
    // Access to the view model
    @StateObject private var imageViewModel = ImageAnalysisViewModel()
    
    init(prefilledGreenCoverage: Double? = nil) {
        self.prefilledGreenCoverage = prefilledGreenCoverage
    }
    
    // Validation
    private var isValidInput: Bool {
        guard let area = Double(fieldArea), area > 0,
              let concentration = Double(chemicalConcentration), concentration > 0 else {
            return false
        }
        return true
    }
    
    private var greenCoveragePercent: Double? {
        // Use override if set, otherwise use prefilled value, otherwise use analyzed value
        greenCoverageOverride ?? prefilledGreenCoverage ?? imageViewModel.analysisResults?.greenPercentage
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Field Information") {
                    TextField("Field Name", text: $fieldName)
                        .textContentType(.name)
                    
                    HStack {
                        TextField("Field Size", text: $fieldArea)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(AreaUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .fixedSize()
                    }
                    
                    Picker("Crop Type", selection: $cropType) {
                        ForEach(CropType.allCases, id: \.self) { crop in
                            Text(crop.rawValue).tag(crop)
                        }
                    }
                }
                
                Section("Chemical Information") {
                    TextField("Product Name", text: $productName)
                    
                    HStack {
                        TextField("Concentration", text: $chemicalConcentration)
                            .keyboardType(.decimalPad)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Application Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Tank Size")
                            Spacer()
                            Text("\(Int(tankSize)) L")
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .monospacedDigit()
                        }
                        
                        Slider(value: $tankSize, in: 300...10000, step: 100)
                            .accentColor(.green)
                        
                        HStack {
                            Text("300 L")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("10,000 L")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Spray Volume")
                            Spacer()
                            Text("\(Int(sprayVolume)) L/ha")
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .monospacedDigit()
                        }
                        
                        Slider(value: $sprayVolume, in: 20...500, step: 10)
                            .accentColor(.green)
                        
                        HStack {
                            Text("20 L/ha")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("500 L/ha")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Green Coverage Analysis") {
                    if let greenPercent = greenCoveragePercent {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Coverage: \(greenPercent, specifier: "%.1f")%")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(DensityLevel.from(greenCoverage: greenPercent).description)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        Button("Re-analyze Image") {
                            showingImageAnalysis = true
                        }
                    } else {
                        Button(action: {
                            showingImageAnalysis = true
                        }) {
                            Label("Analyze Field Image", systemImage: "camera.fill")
                        }
                        
                        Text("Analyze an image to determine green coverage percentage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                Section {
                    Button(action: calculateChemical) {
                        HStack {
                            Image(systemName: "function")
                            Text("Calculate Requirements")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidInput || greenCoveragePercent == nil)
                }
            }
            .navigationTitle("Chemical Calculator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                    .font(.body.bold())
                }
            }
            .sheet(isPresented: $showingImageAnalysis) {
                // This would show the existing ContentView for image selection and analysis
                ContentView()
            }
            .sheet(isPresented: $showingResults) {
                if let result = calculationResult {
                    CalculationResultView(result: result, fieldName: fieldName)
                }
            }
        }
    }
    
    private func calculateChemical() {
        guard let area = Double(fieldArea),
              let concentration = Double(chemicalConcentration),
              let greenPercent = greenCoveragePercent else { return }
        
        let fieldData = FieldData(
            area: area,
            areaUnit: selectedUnit,
            greenCoveragePercent: greenPercent,
            cropType: cropType,
            applicationDate: Date()
        )
        
        calculationResult = ChemicalCalculator.performCalculation(
            fieldData: fieldData,
            chemicalConcentration: concentration,
            sprayVolume: sprayVolume,
            tankSize: tankSize,
            productName: productName
        )
        
        showingResults = true
    }
}

// Extension to add description to DensityLevel
extension DensityLevel {
    var description: String {
        switch self {
        case .light:
            return "Light Coverage"
        case .medium:
            return "Medium Coverage"
        case .heavy:
            return "Heavy Coverage"
        }
    }
}

struct FieldDataInputView_Previews: PreviewProvider {
    static var previews: some View {
        FieldDataInputView()
    }
}
