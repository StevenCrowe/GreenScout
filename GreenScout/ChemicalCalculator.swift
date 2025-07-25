//
//  ChemicalCalculator.swift
//  GreenScout
//
//  Core calculation logic for chemical recommendations
//

import Foundation

// MARK: - Calculation Result Structure
struct ChemicalCalculationResult {
    let chemicalVolume: Double
    let waterVolume: Double
    let totalSprayVolume: Double
    let tankLoads: Int
    let applicationRate: Double
    let densityLevel: DensityLevel
}

// MARK: - Chemical Calculator
class ChemicalCalculator {
    
    // Standard spray volumes per hectare for different application types
    struct SprayVolumes {
        static let standard = 100.0 // L/ha
        static let lowVolume = 50.0 // L/ha
        static let highVolume = 200.0 // L/ha
    }
    
    // Tank sizes commonly used
    struct TankSizes {
        static let small = 500.0 // L
        static let standard = 1000.0 // L
        static let large = 2000.0 // L
    }
    
    static func calculateChemicalRequirement(
        fieldData: FieldData,
        chemicalConcentration: Double = 100.0, // % active ingredient
        sprayVolume: Double = SprayVolumes.standard,
        tankSize: Double = TankSizes.standard
    ) -> ChemicalCalculationResult {
        
        // Convert area to hectares if needed
        let areaInHectares = fieldData.area * fieldData.areaUnit.toHectaresMultiplier
        
        // Determine density level based on green coverage
        let densityLevel = DensityLevel.from(greenCoverage: fieldData.greenCoveragePercent)
        
        // Base calculation
        let baseRate = fieldData.cropType.baseApplicationRate
        let adjustedRate = baseRate * densityLevel.multiplier
        
        // Adjust for chemical concentration
        let concentrationAdjustment = 100.0 / chemicalConcentration
        let finalRate = adjustedRate * concentrationAdjustment
        
        // Total chemical needed
        let totalChemicalVolume = finalRate * areaInHectares
        
        // Water calculation
        let totalSprayVolume = sprayVolume * areaInHectares
        let totalWaterVolume = max(0, totalSprayVolume - totalChemicalVolume)
        
        // Tank calculations
        let tankLoads = ceil(totalSprayVolume / tankSize)
        
        return ChemicalCalculationResult(
            chemicalVolume: totalChemicalVolume,
            waterVolume: totalWaterVolume,
            totalSprayVolume: totalSprayVolume,
            tankLoads: Int(tankLoads),
            applicationRate: finalRate,
            densityLevel: densityLevel
        )
    }
    
    // Generate mixing instructions based on calculation
    static func generateMixingInstructions(
        result: ChemicalCalculationResult,
        tankSize: Double = TankSizes.standard,
        productName: String = "Herbicide"
    ) -> [MixingInstruction] {
        
        var instructions: [MixingInstruction] = []
        
        // Calculate per-tank amounts
        let tanksNeeded = Double(result.tankLoads)
        let chemicalPerTank = result.chemicalVolume / tanksNeeded
        let _ = result.waterVolume / tanksNeeded
        
        // Half-fill instruction
        instructions.append(MixingInstruction(
            step: 1,
            instruction: "Half-fill spray tank with clean water",
            amount: tankSize / 2,
            unit: "L"
        ))
        
        // Start agitation
        instructions.append(MixingInstruction(
            step: 2,
            instruction: "Start agitation system",
            amount: nil,
            unit: nil
        ))
        
        // Add chemical
        instructions.append(MixingInstruction(
            step: 3,
            instruction: "Add \(productName) to tank",
            amount: chemicalPerTank,
            unit: "L"
        ))
        
        // Top up with water
        instructions.append(MixingInstruction(
            step: 4,
            instruction: "Top up with water to total volume",
            amount: tankSize,
            unit: "L"
        ))
        
        // Final agitation
        instructions.append(MixingInstruction(
            step: 5,
            instruction: "Continue agitation for 2-3 minutes before spraying",
            amount: nil,
            unit: nil
        ))
        
        // Multiple tanks instruction
        if result.tankLoads > 1 {
            instructions.append(MixingInstruction(
                step: 6,
                instruction: "Repeat for \(result.tankLoads) tank loads total",
                amount: nil,
                unit: nil
            ))
        }
        
        return instructions
    }
    
    // Generate spray parameters based on conditions
    static func getSprayParameters(for densityLevel: DensityLevel) -> (pressure: String, nozzleType: String) {
        switch densityLevel {
        case .light:
            return ("2.0-2.5 bar", "Flat fan 110°")
        case .medium:
            return ("2.5-3.0 bar", "Flat fan 110°")
        case .heavy:
            return ("3.0-3.5 bar", "Flat fan 80°")
        }
    }
    
    // Create complete calculation result
    static func performCalculation(
        fieldData: FieldData,
        chemicalConcentration: Double = 100.0,
        sprayVolume: Double = SprayVolumes.standard,
        tankSize: Double = TankSizes.standard,
        productName: String = "Herbicide"
    ) -> CalculationResult {
        
        // Perform base calculation
        let calcResult = calculateChemicalRequirement(
            fieldData: fieldData,
            chemicalConcentration: chemicalConcentration,
            sprayVolume: sprayVolume,
            tankSize: tankSize
        )
        
        // Generate mixing instructions
        let mixingInstructions = generateMixingInstructions(
            result: calcResult,
            tankSize: tankSize,
            productName: productName
        )
        
        // Get spray parameters
        let sprayParams = getSprayParameters(for: calcResult.densityLevel)
        
        return CalculationResult(
            fieldData: fieldData,
            totalChemicalNeeded: calcResult.chemicalVolume,
            waterVolume: calcResult.waterVolume,
            mixingInstructions: mixingInstructions,
            applicationRate: calcResult.applicationRate,
            sprayPressure: sprayParams.pressure,
            nozzleType: sprayParams.nozzleType,
            calculatedAt: Date()
        )
    }
}
