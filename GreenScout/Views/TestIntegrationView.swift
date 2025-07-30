import SwiftUI

struct TestIntegrationView: View {
    @StateObject private var store = ChemicalStore.shared
    @StateObject private var complianceChecker = ComplianceChecker()
    @State private var showingTestResults = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Test Data") {
                    Button("Load Sample Chemicals") {
                        TestDataProvider.createSampleChemicals()
                    }
                    .foregroundColor(.blue)
                    
                    Text("Chemicals loaded: \(store.chemicals.count)")
                        .foregroundColor(.secondary)
                }
                
                Section("Test Components") {
                    NavigationLink("Chemical List", destination: ChemicalProductListView())
                    NavigationLink("Compliance Dashboard", destination: ComplianceDashboardView())
                    NavigationLink("Chemical Calculator", destination: ChemicalCalculatorView())
                }
                
                Section("Test Compliance") {
                    Button("Test Safety Warnings") {
                        testComplianceChecker()
                        showingTestResults = true
                    }
                    .foregroundColor(.orange)
                }
                
                if showingTestResults && !complianceChecker.warnings.isEmpty {
                    Section("Test Results") {
                        SafetyWarningListView(complianceChecker: complianceChecker)
                    }
                }
            }
            .navigationTitle("GreenScout Test")
        }
    }
    
    func testComplianceChecker() {
        // Create test conditions
        let testWeather = WeatherConditions(
            temperature: 35.0,  // High temp
            windSpeed: 20.0,    // High wind
            humidity: 45.0,
            precipitation: 0.0
        )
        
        // Create a test chemical
        let testChemical = ChemicalProduct(
            name: "Test Chemical",
            manufacturer: "Test Co",
            activeIngredient: "Test Active",
            concentration: 500.0,
            productType: .herbicide,
            minApplicationRate: 2.0,
            maxApplicationRate: 4.0,
            compatibleWith: [],
            restrictedUse: true,
            withdrawalPeriod: 14,
            costPerLiter: 50.0
        )
        
        // Test with excessive rate
        complianceChecker.checkApplicationCompliance(
            chemical: testChemical,
            applicationRate: 5.0,  // Exceeds max
            weather: testWeather,
            location: nil
        )
    }
}

struct TestIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        TestIntegrationView()
    }
}
