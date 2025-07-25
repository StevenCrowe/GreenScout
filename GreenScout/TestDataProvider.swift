import Foundation

class TestDataProvider {
    static func createSampleChemicals() {
        let store = ChemicalStore.shared
        let chemicals = [
            ChemicalProduct(
                name: "Roundup PowerMAX",
                manufacturer: "Bayer",
                activeIngredient: "Glyphosate",
                concentration: 540.0,
                productType: .herbicide,
                minApplicationRate: 1.5,
                maxApplicationRate: 4.0,
                compatibleWith: [],
                restrictedUse: false,
                withdrawalPeriod: 7,
                costPerLiter: 45.50
            ),
            ChemicalProduct(
                name: "Karate Zeon",
                manufacturer: "Syngenta",
                activeIngredient: "Lambda-cyhalothrin",
                concentration: 250.0,
                productType: .insecticide,
                minApplicationRate: 0.05,
                maxApplicationRate: 0.1,
                compatibleWith: [],
                restrictedUse: true,
                withdrawalPeriod: 14,
                costPerLiter: 125.00
            ),
            ChemicalProduct(
                name: "Amistar Xtra",
                manufacturer: "Syngenta",
                activeIngredient: "Azoxystrobin + Cyproconazole",
                concentration: 280.0,
                productType: .fungicide,
                minApplicationRate: 0.5,
                maxApplicationRate: 1.0,
                compatibleWith: [],
                restrictedUse: false,
                withdrawalPeriod: 21,
                costPerLiter: 85.75
            ),
            ChemicalProduct(
                name: "Moddus",
                manufacturer: "Syngenta",
                activeIngredient: "Trinexapac-ethyl",
                concentration: 250.0,
                productType: .growthRegulator,
                minApplicationRate: 0.2,
                maxApplicationRate: 0.4,
                compatibleWith: [],
                restrictedUse: false,
                withdrawalPeriod: 0,
                costPerLiter: 95.00
            )
        ]
        
        // Add all chemicals to store
        for chemical in chemicals {
            store.addChemical(chemical)
        }
    }
}
