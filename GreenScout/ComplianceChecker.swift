import Foundation
import CoreLocation

class ComplianceChecker: ObservableObject {
    @Published var warnings: [SafetyWarning] = []
    
    // Weather thresholds
    let maxWindSpeed: Double = 15.0 // km/h
    let maxTemperature: Double = 30.0 // °C
    let minTemperature: Double = 5.0 // °C
    
    // Buffer zones (meters)
    let waterBufferZone: Double = 30.0
    let sensitiveAreaBuffer: Double = 50.0
    
    func checkApplicationCompliance(
        chemical: ChemicalProduct,
        applicationRate: Double,
        weather: WeatherConditions,
        location: CLLocation? = nil
    ) {
        warnings.removeAll()
        
        // Check application rate
        if applicationRate > chemical.maxApplicationRate {
            warnings.append(.excessiveRate(
                applied: applicationRate,
                maximum: chemical.maxApplicationRate
            ))
        }
        
        // Check weather conditions
        if weather.windSpeed > maxWindSpeed {
            warnings.append(.highWind(speed: weather.windSpeed))
        }
        
        if weather.temperature > maxTemperature {
            warnings.append(.highTemperature(temp: weather.temperature))
        }
        
        // Check restricted use
        if chemical.restrictedUse {
            warnings.append(.restrictedUseProduct)
        }
        
        // Check pre-harvest interval
        if chemical.withdrawalPeriod > 0 {
            warnings.append(.preHarvestInterval(days: chemical.withdrawalPeriod))
        }
        
        // Check proximity to water (would need actual water body data)
        if let location = location {
            // This is a placeholder - in real app would check against water body database
            if isNearWaterSource(location: location) {
                warnings.append(.nearWaterSource)
            }
        }
    }
    
    private func isNearWaterSource(location: CLLocation) -> Bool {
        // Placeholder implementation
        // In real app, would check against geographic water body data
        return false
    }
    
    var hasBlockingWarnings: Bool {
        warnings.contains { $0.severity == .critical }
    }
    
    var sortedWarnings: [SafetyWarning] {
        warnings.sorted { warning1, warning2 in
            let severity1 = warning1.severity
            let severity2 = warning2.severity
            
            if severity1 == severity2 {
                return warning1.message < warning2.message
            }
            
            // Sort by severity: critical first, then warning, then caution
            switch (severity1, severity2) {
            case (.critical, _):
                return true
            case (_, .critical):
                return false
            case (.warning, .caution):
                return true
            case (.caution, .warning):
                return false
            default:
                return false
            }
        }
    }
}

// Weather conditions model
struct WeatherConditions {
    var temperature: Double // Celsius
    var windSpeed: Double // km/h
    var humidity: Double // percentage
    var precipitation: Double // mm
}
