import SwiftUI
import CoreLocation

struct ComplianceDashboardView: View {
    @StateObject private var complianceChecker = ComplianceChecker()
    @State private var selectedChemical: ChemicalProduct?
    @State private var applicationRate: Double = 0.0
    @State private var currentWeather = WeatherConditions(
        temperature: 22.0,
        windSpeed: 10.0,
        humidity: 65.0,
        precipitation: 0.0
    )
    @State private var showingChemicalPicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Chemical Selection
                    chemicalSelectionCard
                    
                    // Application Details
                    if selectedChemical != nil {
                        applicationDetailsCard
                    }
                    
                    // Weather Conditions
                    weatherConditionsCard
                    
                    // Safety Warnings
                    if !complianceChecker.warnings.isEmpty {
                        SafetyWarningListView(complianceChecker: complianceChecker)
                    }
                    
                    // Compliance Status
                    complianceStatusCard
                }
                .padding()
            }
            .navigationTitle("Safety & Compliance")
            .sheet(isPresented: $showingChemicalPicker) {
                ChemicalProductListView_Selection(
                    onSelect: { chemical in
                        selectedChemical = chemical
                        showingChemicalPicker = false
                        checkCompliance()
                    }
                )
            }
        }
    }
    
    var chemicalSelectionCard: some View {
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
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    var applicationDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Application Details")
                .font(.headline)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Application Rate")
                    Spacer()
                    TextField("L/ha", value: $applicationRate, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        .onChange(of: applicationRate) { _ in
                            checkCompliance()
                        }
                }
                
                if let chemical = selectedChemical {
                    HStack {
                        Text("Recommended Range")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f - %.1f L/ha", chemical.minApplicationRate, chemical.maxApplicationRate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    var weatherConditionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weather Conditions")
                    .font(.headline)
                Spacer()
                Button("Update") {
                    // In real app, would fetch current weather
                    checkCompliance()
                }
                .font(.caption)
            }
            
            VStack(spacing: 12) {
                weatherRow(icon: "thermometer", label: "Temperature", value: String(format: "%.1f°C", currentWeather.temperature))
                weatherRow(icon: "wind", label: "Wind Speed", value: String(format: "%.1f km/h", currentWeather.windSpeed))
                weatherRow(icon: "humidity", label: "Humidity", value: String(format: "%.0f%%", currentWeather.humidity))
                weatherRow(icon: "cloud.rain", label: "Precipitation", value: String(format: "%.1f mm", currentWeather.precipitation))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    var complianceStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: complianceChecker.warnings.isEmpty ? "checkmark.circle.fill" : 
                      (complianceChecker.hasBlockingWarnings ? "xmark.circle.fill" : "exclamationmark.circle.fill"))
                    .font(.largeTitle)
                    .foregroundColor(complianceChecker.warnings.isEmpty ? .green : 
                                   (complianceChecker.hasBlockingWarnings ? .red : .orange))
                
                VStack(alignment: .leading) {
                    Text(complianceChecker.warnings.isEmpty ? "All Clear" : 
                         (complianceChecker.hasBlockingWarnings ? "Application Not Recommended" : "Proceed with Caution"))
                        .font(.headline)
                    Text(complianceStatusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if selectedChemical != nil && !complianceChecker.hasBlockingWarnings {
                Button(action: proceedWithApplication) {
                    Text("Proceed to Application")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(complianceChecker.warnings.isEmpty ? Color.green : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    func weatherRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
    
    var complianceStatusMessage: String {
        if complianceChecker.warnings.isEmpty {
            return "All safety and compliance checks passed"
        } else if complianceChecker.hasBlockingWarnings {
            return "Critical issues detected. Please review warnings."
        } else {
            return "\(complianceChecker.warnings.count) warning(s) detected"
        }
    }
    
    func checkCompliance() {
        guard let chemical = selectedChemical else { return }
        
        complianceChecker.checkApplicationCompliance(
            chemical: chemical,
            applicationRate: applicationRate,
            weather: currentWeather,
            location: nil // Would use actual location in real app
        )
    }
    
    func proceedWithApplication() {
        // Navigate to application recording view
        print("Proceeding with application...")
    }
}

struct ComplianceDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ComplianceDashboardView()
    }
}
