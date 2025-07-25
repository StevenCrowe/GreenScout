//
//  CalculationModels.swift
//  GreenScout
//
//  Data models for chemical calculation engine
//

import Foundation

// MARK: - Data Models
struct FieldData {
    let area: Double // in hectares
    let areaUnit: AreaUnit // hectares, acres
    let greenCoveragePercent: Double // from image analysis
    let cropType: CropType
    let applicationDate: Date
}

enum AreaUnit: String, CaseIterable {
    case hectares = "Hectares"
    case acres = "Acres"
    
    var toHectaresMultiplier: Double {
        switch self {
        case .hectares: return 1.0
        case .acres: return 0.404686 // 1 acre = 0.404686 hectares
        }
    }
}

enum CropType: String, CaseIterable {
    case pasture = "Pasture"
    case wheat = "Wheat"
    case corn = "Corn/Maize"
    case barley = "Barley"
    case canola = "Canola"
    case other = "Other"

    var baseApplicationRate: Double {
        // Base rate in L/ha
        switch self {
        case .pasture: return 1.5
        case .wheat: return 2.0
        case .corn: return 2.5
        case .barley: return 1.8
        case .canola: return 2.2
        case .other: return 2.0
        }
    }
}

enum DensityLevel {
    case light // < 30% green
    case medium // 30-70% green
    case heavy // > 70% green

    var multiplier: Double {
        switch self {
        case .light: return 0.7
        case .medium: return 1.0
        case .heavy: return 1.3
        }
    }
    
    static func from(greenCoverage: Double) -> DensityLevel {
        switch greenCoverage {
        case ..<30: return .light
        case 30..<70: return .medium
        default: return .heavy
        }
    }
}

// MARK: - Calculation Results
struct CalculationResult {
    let fieldData: FieldData
    let totalChemicalNeeded: Double // in Liters
    let waterVolume: Double // in Liters
    let mixingInstructions: [MixingInstruction]
    let applicationRate: Double // L/ha
    let sprayPressure: String
    let nozzleType: String
    let calculatedAt: Date
}

struct MixingInstruction {
    let step: Int
    let instruction: String
    let amount: Double?
    let unit: String?
}

// MARK: - Saved Calculation
struct SavedCalculation: Codable, Identifiable {
    let id: UUID
    let fieldName: String
    let result: CalculationResult
    let savedAt: Date
    let notes: String?
    
    init(fieldName: String, result: CalculationResult, notes: String? = nil) {
        self.id = UUID()
        self.fieldName = fieldName
        self.result = result
        self.savedAt = Date()
        self.notes = notes
    }
}

// Make CalculationResult Codable for saving
extension CalculationResult: Codable {
    enum CodingKeys: String, CodingKey {
        case fieldData, totalChemicalNeeded, waterVolume
        case mixingInstructions, applicationRate, sprayPressure
        case nozzleType, calculatedAt
    }
}

// Make other structs Codable
extension FieldData: Codable {}
extension MixingInstruction: Codable {}

// Make enums Codable
extension AreaUnit: Codable {}
extension CropType: Codable {}
