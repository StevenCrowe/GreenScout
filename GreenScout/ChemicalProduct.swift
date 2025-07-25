import Foundation
import SwiftUI

// Chemical Product model - compatible with iOS 15+
class ChemicalProduct: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    @Published var manufacturer: String
    @Published var activeIngredient: String
    @Published var concentration: Double
    @Published var productType: ChemicalType
    @Published var minApplicationRate: Double
    @Published var maxApplicationRate: Double
    @Published var compatibleWith: [String]
    @Published var restrictedUse: Bool
    @Published var withdrawalPeriod: Int
    @Published var costPerLiter: Double?
    
    init(
        id: UUID = UUID(),
        name: String,
        manufacturer: String,
        activeIngredient: String,
        concentration: Double,
        productType: ChemicalType = .herbicide,
        minApplicationRate: Double = 1.0,
        maxApplicationRate: Double = 4.0,
        compatibleWith: [String] = [],
        restrictedUse: Bool = false,
        withdrawalPeriod: Int = 0,
        costPerLiter: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.activeIngredient = activeIngredient
        self.concentration = concentration
        self.productType = productType
        self.minApplicationRate = minApplicationRate
        self.maxApplicationRate = maxApplicationRate
        self.compatibleWith = compatibleWith
        self.restrictedUse = restrictedUse
        self.withdrawalPeriod = withdrawalPeriod
        self.costPerLiter = costPerLiter
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, manufacturer, activeIngredient, concentration
        case productType, minApplicationRate, maxApplicationRate
        case compatibleWith, restrictedUse, withdrawalPeriod, costPerLiter
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        manufacturer = try container.decode(String.self, forKey: .manufacturer)
        activeIngredient = try container.decode(String.self, forKey: .activeIngredient)
        concentration = try container.decode(Double.self, forKey: .concentration)
        productType = try container.decode(ChemicalType.self, forKey: .productType)
        minApplicationRate = try container.decode(Double.self, forKey: .minApplicationRate)
        maxApplicationRate = try container.decode(Double.self, forKey: .maxApplicationRate)
        compatibleWith = try container.decode([String].self, forKey: .compatibleWith)
        restrictedUse = try container.decode(Bool.self, forKey: .restrictedUse)
        withdrawalPeriod = try container.decode(Int.self, forKey: .withdrawalPeriod)
        costPerLiter = try container.decodeIfPresent(Double.self, forKey: .costPerLiter)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(activeIngredient, forKey: .activeIngredient)
        try container.encode(concentration, forKey: .concentration)
        try container.encode(productType, forKey: .productType)
        try container.encode(minApplicationRate, forKey: .minApplicationRate)
        try container.encode(maxApplicationRate, forKey: .maxApplicationRate)
        try container.encode(compatibleWith, forKey: .compatibleWith)
        try container.encode(restrictedUse, forKey: .restrictedUse)
        try container.encode(withdrawalPeriod, forKey: .withdrawalPeriod)
        try container.encodeIfPresent(costPerLiter, forKey: .costPerLiter)
    }
}

enum ChemicalType: String, CaseIterable, Codable {
    case herbicide = "Herbicide"
    case insecticide = "Insecticide"
    case fungicide = "Fungicide"
    case fertilizer = "Fertilizer"
    case growthRegulator = "Growth Regulator"
}

// Chemical Store for managing products without SwiftData
class ChemicalStore: ObservableObject {
    @Published var chemicals: [ChemicalProduct] = []
    
    static let shared = ChemicalStore()
    
    private let saveKey = "SavedChemicals"
    
    init() {
        loadChemicals()
    }
    
    func addChemical(_ chemical: ChemicalProduct) {
        chemicals.append(chemical)
        saveChemicals()
    }
    
    func deleteChemical(_ chemical: ChemicalProduct) {
        chemicals.removeAll { $0.id == chemical.id }
        saveChemicals()
    }
    
    func updateChemical(_ chemical: ChemicalProduct) {
        if let index = chemicals.firstIndex(where: { $0.id == chemical.id }) {
            chemicals[index] = chemical
            saveChemicals()
        }
    }
    
    private func saveChemicals() {
        if let encoded = try? JSONEncoder().encode(chemicals) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadChemicals() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ChemicalProduct].self, from: data) {
            chemicals = decoded
        }
    }
}
